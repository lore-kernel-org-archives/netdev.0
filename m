From: Andrew Shewmaker <agshew@gmail.com>
Subject: Re: [PATCH net-next 2/7] tcp: track min RTT using windowed min-filter
Date: Sun, 18 Oct 2015 21:39:07 -0700
Message-ID: <20151019043907.GA11368@mininet-vm>
References: <1445057867-32257-1-git-send-email-ycheng@google.com>
 <1445057867-32257-3-git-send-email-ycheng@google.com>
 <20151014092800.GA3748@mininet-vm>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	Neal Cardwell <ncardwell@google.com>,
	Eric Dumazet <edumazet@google.com>
To: Yuchung Cheng <ycheng@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f181.google.com ([209.85.223.181]:34263 "EHLO
	mail-io0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752583AbbJSEjR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Oct 2015 00:39:17 -0400
Received: by iow1 with SMTP id 1so177248650iow.1
        for <netdev@vger.kernel.org>; Sun, 18 Oct 2015 21:39:16 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20151014092800.GA3748@mininet-vm>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Oct 14, 2015 at 02:28:00AM -0700, Andrew Shewmaker wrote:
> On Fri, Oct 16, 2015 at 09:57:42PM -0700, Yuchung Cheng wrote:
> ...
> > diff --git a/include/linux/tcp.h b/include/linux/tcp.h
> > index 86a7eda..90edef5 100644
> > --- a/include/linux/tcp.h
> > +++ b/include/linux/tcp.h
> > @@ -217,6 +217,9 @@ struct tcp_sock {
> >  	u32	mdev_max_us;	/* maximal mdev for the last rtt period	*/
> >  	u32	rttvar_us;	/* smoothed mdev_max			*/
> >  	u32	rtt_seq;	/* sequence number to update rttvar	*/
> > +	struct rtt_meas {
> > +		u32 rtt, ts;	/* RTT in usec and sampling time in jiffies. */
> > +	} rtt_min[3];
> 
> First, thanks for all the work in this patch series. In particular,
> applying Kern's check to ca_seq_rtt_us should fix some bad behavior
> I've observed recently.

I'd have to run more tests to be sure, but net-next with this patch series
significantly improves upon the poor behavior I was seeing where randomly
dropped packets greatly limited the usefulness of RTTs as a signal of
congestion. I still see some measurements that exceed the amount of delay
possible from queue buildup, but fewer than before.

Thanks!

-Andrew
