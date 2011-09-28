From: "=?ISO-8859-15?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: [PATCH] tcp: properly update lost_cnt_hint during shifting
Date: Wed, 28 Sep 2011 14:29:34 +0300 (EEST)
Message-ID: <alpine.DEB.2.00.1109281418280.21709@wel-95.cs.helsinki.fi>
References: <4E82C0DD.6010304@intel.com> <alpine.DEB.2.00.1109281103410.21709@wel-95.cs.helsinki.fi> <4E82E0EE.1050600@intel.com> <4E82E5B5.1050206@intel.com> <alpine.DEB.2.00.1109281226480.21709@wel-95.cs.helsinki.fi> <4E82FAD6.1010708@intel.com>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="8323329-2065980787-1317209374=:21709"
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Nandita Dukkipati <nanditad@google.com>
To: "Yan, Zheng" <zheng.z.yan@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:60967 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751105Ab1I1L3g (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 Sep 2011 07:29:36 -0400
In-Reply-To: <4E82FAD6.1010708@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

--8323329-2065980787-1317209374=:21709
Content-Type: TEXT/PLAIN; charset=iso-8859-1
Content-Transfer-Encoding: 8BIT

On Wed, 28 Sep 2011, Yan, Zheng wrote:

> > But is the non-SACKed case really handled right when hint == skb by the 
> > sacktag_one. We move the seqno in between and then before(x->newseq, 
> > x->newseq) check returns false?
> > 
> you are right, thank you.
> 
> really hope my patch is correct this time :)
> ---
> diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
> index 21fab3e..a04622e 100644
> --- a/net/ipv4/tcp_input.c
> +++ b/net/ipv4/tcp_input.c
> @@ -1390,8 +1390,7 @@ static int tcp_shifted_skb(struct sock *sk, struct sk_buff *skb,
>  	BUG_ON(!pcount);
>  
>  	/* Tweak before seqno plays */
> -	if (!tcp_is_fack(tp) && tcp_is_sack(tp) && tp->lost_skb_hint &&
> -	    !before(TCP_SKB_CB(tp->lost_skb_hint)->seq, TCP_SKB_CB(skb)->seq))
> +	if (!tcp_is_fack(tp) && tcp_is_sack(tp) && tp->lost_skb_hint == skb)
>  		tp->lost_cnt_hint += pcount;
>  
>  	TCP_SKB_CB(prev)->end_seq += shifted;

It also looks a lot nicer now and more obvious. According to my current 
understanding, feel free to add this once doing the proper submission with 
Signed-off etc. (please also remove the comment too as seqnos have no 
longer any significance here):

Acked-by: Ilpo Järvinen <ilpo.jarvinen@helsinki.fi>

...but it certainly wouldn't hurt if also somebody else has pair of eyes 
to spare to confirm that we (both) are now in agreement what the code 
really says.


-- 
 i.
--8323329-2065980787-1317209374=:21709--
