From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: [RFC][PATCH 2/2] TCP: skip processing cached SACK blocks
Date: Mon, 8 Oct 2007 14:20:47 +0300 (EEST)
Message-ID: <Pine.LNX.4.64.0710081415020.31129@kivilampi-30.cs.helsinki.fi>
References: <20071004.184456.40407483.takano@axe-inc.co.jp>
 <Pine.LNX.4.64.0710041516170.31129@kivilampi-30.cs.helsinki.fi>
 <20071007.151145.32909699.takano@axe-inc.co.jp>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="-696243703-1341740210-1191842447=:31129"
Cc: Netdev <netdev@vger.kernel.org>, y-kodama@aist.go.jp
To: TAKANO Ryousei <takano@axe-inc.co.jp>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:45271 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753594AbXJHLUt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Oct 2007 07:20:49 -0400
In-Reply-To: <20071007.151145.32909699.takano@axe-inc.co.jp>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---696243703-1341740210-1191842447=:31129
Content-Type: TEXT/PLAIN; charset=iso-8859-1
Content-Transfer-Encoding: 8BIT

On Sun, 7 Oct 2007, TAKANO Ryousei wrote:
> From: "Ilpo Järvinen" <ilpo.jarvinen@helsinki.fi>
> > On Thu, 4 Oct 2007, TAKANO Ryousei wrote:
> > 
> > > @@ -1083,6 +1104,9 @@ tcp_sacktag_write_queue(struct sock *sk, struct sk_buff *ack_skb, u32 prior_snd_
> > >  		int fack_count;
> > >  		int dup_sack = (found_dup_sack && (i == first_sack_index));
> > >  
> > > +		if (sack_block_skip[i])
> > > +			continue;
> > 
> > By doing this skipping here, you actually end up crippling lost_retrans 
> > detection even more than it was broken before. ...You probably didn't just 
> > notice that during tests because of unrelated suboptimal behavior (in 
> > fastpath_skb_hint handling). ...Anyway, correctness of this should be 
> > evaluated against the fixed lost_retrans, rather than the already 
> > broken one.
> 
> You can find the result that the average goodput slightly improves
> against the only PATCH #1 (fixed lost_retrans) applied kernel.

...Yeah, sorry, I was mistaken when the slow-path is taken and when it's 
not, thought that the old (current) fastpath_skb_hint code was more 
intelligent than it currently is... :-) That continue should not be
a problem.


-- 
 i.
---696243703-1341740210-1191842447=:31129--
