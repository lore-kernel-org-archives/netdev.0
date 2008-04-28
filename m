From: Paul Moore <paul.moore@hp.com>
Subject: Re: [PATCH net-2.6/stable] [XFRM] AUDIT: Fix flowlabel text format.
Date: Mon, 28 Apr 2008 10:14:44 -0400
Message-ID: <200804281014.44318.paul.moore@hp.com>
References: <20080427.122418.32604330.yoshfuji@linux-ipv6.org> <20080426.202558.208247674.davem@davemloft.net> <20080427.125437.59237838.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-2022-jp"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, jmorris@namei.org, netdev@vger.kernel.org,
	linux-audit@redhat.com
To: YOSHIFUJI Hideaki /
	 =?iso-2022-jp?q?=1B=24B5HF=231QL=40=1B=28B?=
	<yoshfuji@linux-ipv6.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g4t0016.houston.hp.com ([15.201.24.19]:24102 "EHLO
	g4t0016.houston.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933561AbYD1OOw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 28 Apr 2008 10:14:52 -0400
In-Reply-To: <20080427.125437.59237838.yoshfuji@linux-ipv6.org>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Saturday 26 April 2008 11:54:37 pm YOSHIFUJI Hideaki / 吉藤英明 wrote:
> [XFRM] AUDIT: Fix flowlabel text format ambibuity.
>
> Flowlabel text format was not correct and thus ambiguous.
> For example, 0x00123 or 0x01203 are formatted as 0x123.
> This is not what audit tools want.
>
> Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>

Thanks for catching this.

I'm CC'ing the audit list on this because they get nervous when people 
start changing the audit records.  However, I'll ack this patch because 
I think the previous behavior was incorrect and this should be 
considered a bugfix.

Acked-by: Paul Moore <paul.moore@hp.com>

> ---
> diff --git a/net/xfrm/xfrm_state.c b/net/xfrm/xfrm_state.c
> index 5dcc10b..fac27ce 100644
> --- a/net/xfrm/xfrm_state.c
> +++ b/net/xfrm/xfrm_state.c
> @@ -2112,7 +2112,7 @@ static void xfrm_audit_helper_pktinfo(struct
> sk_buff *skb, u16 family, iph6 = ipv6_hdr(skb);
>  		audit_log_format(audit_buf,
>  				 " src=" NIP6_FMT " dst=" NIP6_FMT
> -				 " flowlbl=0x%x%x%x",
> +				 " flowlbl=0x%x%02x%02x",
>  				 NIP6(iph6->saddr),
>  				 NIP6(iph6->daddr),
>  				 iph6->flow_lbl[0] & 0x0f,

-- 
paul moore
linux @ hp
