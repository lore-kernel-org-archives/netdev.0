From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [PATCH net] net: sctp: fix multihoming retransmission path
 selection to rfc4960
Date: Thu, 20 Feb 2014 07:40:02 -0500
Message-ID: <20140220124002.GB11199@hmsreliant.think-freely.org>
References: <1392897186-26841-1-git-send-email-dborkman@redhat.com>
 <063D6719AE5E284EB5DD2968C1650D6D0F6C762B@AcuExch.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: 'Daniel Borkmann' <dborkman@redhat.com>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-sctp@vger.kernel.org" <linux-sctp@vger.kernel.org>,
	Gui Jianfeng <guijianfeng@cn.fujitsu.com>
To: David Laight <David.Laight@ACULAB.COM>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:36105 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752948AbaBTMkQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Feb 2014 07:40:16 -0500
Content-Disposition: inline
In-Reply-To: <063D6719AE5E284EB5DD2968C1650D6D0F6C762B@AcuExch.aculab.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Feb 20, 2014 at 12:25:21PM +0000, David Laight wrote:
> From: Daniel Borkmann
> > 
> > Problem statement: 1) both paths (primary path1 and alternate
> > path2) are up after the association has been established i.e.,
> > HB packets are normally exchanged, 2) path2 gets inactive after
> > path_max_retrans * max_rto timed out (i.e. path2 is down completely),
> > 3) now, if a transmission times out on the only surviving/active
> > path1 (any ~1sec network service impact could cause this like
> > a channel bonding failover), then the retransmitted packets are
> > sent over the inactive path2; this happens with partial failover
> > and without it.
> > 
> > Besides not being optimal in the above scenario, a small failure
> > or timeout in the only existing path has the potential to cause
> > long delays in the retransmission (depending on RTO_MAX) until
> > the still active path is reselected.
> 
> The current behaviour doesn't seem very good - real networks tend
> to have non-zero packet loss these days (for all sorts of reasons).
> 
> I guess that under moderate traffic flow retransmit requests from
> the remote system recover the data before a timeout actually occurs.
> 
> That probably means that a path with a high error rate will continue
> to be used when an alternate path would be much better.
> 
Not really sure what you mean here.  Why would we use a path with a high error
rate when another one would be much better.  If we get to many retransmits on
the current active path, we select a different one, attempting to use collected
metrics to determine which path would be the most prefereable.

> I was wondering whether it is valid (or even reasonable) to send
> the retransmit down multiple paths?  Particularly if they are
> not known to be working.
Yes, quick failover defines that behavior:
http://tools.ietf.org/html/draft-nishida-tsvwg-sctp-failover-05

And if its not appropriate for your network, you can disable it via sysctl.

> Or maybe resend heartbeats in a desperate attempt to find a working
> path?
> 
> Do you guys know which kernel version(s) have that patch?
Which patch, what daniel describes above has been the behavior for some time
IIRC.

> We have a few customers using sctp (for m3ua) and I really ought
> to keep track of the 'good' and 'bad' kernel versions.
> 
> 	David
> 
> 
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-sctp" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
