From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: A Linux TCP SACK Question
Date: Wed, 16 Apr 2008 12:21:38 +0300 (EEST)
Message-ID: <Pine.LNX.4.64.0804161203590.17123@wrl-59.cs.helsinki.fi>
References: <Pine.LNX.4.64.0804151035060.17123@wrl-59.cs.helsinki.fi>
 <fc3c25e72104.4804a729@fnal.gov> <1e41a3230804151540i1f7cee4dva6adc6ef25dae546@mail.gmail.com>
 <20080416.012732.152357000.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: johnwheffner@gmail.com, wenji@fnal.gov,
	Netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:58524 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754815AbYDPJVo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Apr 2008 05:21:44 -0400
In-Reply-To: <20080416.012732.152357000.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 16 Apr 2008, David Miller wrote:

> From: "John Heffner" <johnwheffner@gmail.com>
> Date: Tue, 15 Apr 2008 15:40:05 -0700
> 
> > Subject: [PATCH] Increase the max_burst threshold from 3 to tp->reordering.
> > 
> > This change is necessary to allow cwnd to grow during persistent
> > reordering.  Cwnd moderation is applied when in the disorder state
> > and an ack that fills the hole comes in.  If the hole was greater
> > than 3 packets, but less than tp->reordering, cwnd will shrink when
> > it should not have.
> > 
> > Signed-off-by: John Heffner <jheffner@napa.(none)>
> 
> I think this patch is correct, or at least more correct than what
> this code is doing right now.
> 
> Any objections to my adding this to net-2.6.26?

I don't have objections.

But I want to note that tp->reordering does not consider the situation on 
that specific ACK because its value might originate a number of segments 
and even RTTs back. I think it could be possible to find a more 
appropriate value for max_burst locally to an ACK. ...Though it might be a 
bit over-engineered solution. For SACK we calculate similar metric anyway 
in tcp_clean_rtx_queue to find if tp->reordering needs to be updated at 
cumulative ACK and for NewReno min(tp->sacked_out, tp->reordering) + 3
could perhaps be used (I'm not sure if these would be foolproof in 
recovery though).

-- 
 i.
