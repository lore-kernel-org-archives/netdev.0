From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: A Linux TCP SACK Question
Date: Wed, 16 Apr 2008 18:03:55 +0300 (EEST)
Message-ID: <Pine.LNX.4.64.0804161750130.17123@wrl-59.cs.helsinki.fi>
References: <Pine.LNX.4.64.0804151035060.17123@wrl-59.cs.helsinki.fi>
 <fc3c25e72104.4804a729@fnal.gov>  <1e41a3230804151540i1f7cee4dva6adc6ef25dae546@mail.gmail.com>
  <20080416.012732.152357000.davem@davemloft.net>
 <Pine.LNX.4.64.0804161203590.17123@wrl-59.cs.helsinki.fi>
 <1e41a3230804160740g1b4f135bh2f0548e8c15bcddb@mail.gmail.com>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; boundary="-696208474-1047862597-1208357771=:17123"
Cc: David Miller <davem@davemloft.net>, wenji@fnal.gov,
	Netdev <netdev@vger.kernel.org>
To: John Heffner <johnwheffner@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:36183 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756465AbYDPPD6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Apr 2008 11:03:58 -0400
In-Reply-To: <1e41a3230804160740g1b4f135bh2f0548e8c15bcddb@mail.gmail.com>
Content-ID: <Pine.LNX.4.64.0804161757410.17123@wrl-59.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---696208474-1047862597-1208357771=:17123
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Content-Transfer-Encoding: 8BIT
Content-ID: <Pine.LNX.4.64.0804161757411.17123@wrl-59.cs.helsinki.fi>

On Wed, 16 Apr 2008, John Heffner wrote:

> On Wed, Apr 16, 2008 at 2:21 AM, Ilpo Järvinen
> <ilpo.jarvinen@helsinki.fi> wrote:
> >
> >  But I want to note that tp->reordering does not consider the situation on
> >  that specific ACK because its value might originate a number of segments
> >  and even RTTs back. I think it could be possible to find a more
> >  appropriate value for max_burst locally to an ACK. ...Though it might be a
> >  bit over-engineered solution. For SACK we calculate similar metric anyway
> >  in tcp_clean_rtx_queue to find if tp->reordering needs to be updated at
> >  cumulative ACK and for NewReno min(tp->sacked_out, tp->reordering) + 3
> >  could perhaps be used (I'm not sure if these would be foolproof in
> >  recovery though).
> 
> Reordering is generally a random process resulting from a packet
> traversing parallel queues.  (In the case of netem, the random process
> is explicitly defined by simulation.)  As reordering is created by
> packets sitting in queues, these queues *should* be able to absorb a
> burst of at least the reordering size.  That's at least my
> justification for using the reordering threshold as max_burst, along
> with the fact that it should prevent cwnd from getting clamped.

Sure, but combined with other phenomena such as ACK compression (and 
appropriate ACK pattern & pre TCP state), one might end up generating much 
larger bursts than just tp->reordering. Though it's probably not any worse 
than ACK compression already can cause e.g. after spurious RTO. And one is 
quite guaranteed to run out of something else too before things get too 
nasty.


-- 
 i.
---696208474-1047862597-1208357771=:17123--
