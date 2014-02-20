From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [PATCH net] net: sctp: fix multihoming retransmission path
 selection to rfc4960
Date: Thu, 20 Feb 2014 12:25:21 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6D0F6C762B@AcuExch.aculab.com>
References: <1392897186-26841-1-git-send-email-dborkman@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-sctp@vger.kernel.org" <linux-sctp@vger.kernel.org>,
	Gui Jianfeng <guijianfeng@cn.fujitsu.com>
To: 'Daniel Borkmann' <dborkman@redhat.com>,
	"davem@davemloft.net" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0.aculab.com ([213.249.233.131]:46004 "HELO mx0.aculab.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1752202AbaBTM0G convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Feb 2014 07:26:06 -0500
Received: from mx0.aculab.com ([127.0.0.1])
 by localhost (mx0.aculab.com [127.0.0.1]) (amavisd-new, port 10024) with SMTP
 id 20095-08 for <netdev@vger.kernel.org>;
 Thu, 20 Feb 2014 12:26:01 +0000 (GMT)
In-Reply-To: <1392897186-26841-1-git-send-email-dborkman@redhat.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Borkmann
> 
> Problem statement: 1) both paths (primary path1 and alternate
> path2) are up after the association has been established i.e.,
> HB packets are normally exchanged, 2) path2 gets inactive after
> path_max_retrans * max_rto timed out (i.e. path2 is down completely),
> 3) now, if a transmission times out on the only surviving/active
> path1 (any ~1sec network service impact could cause this like
> a channel bonding failover), then the retransmitted packets are
> sent over the inactive path2; this happens with partial failover
> and without it.
> 
> Besides not being optimal in the above scenario, a small failure
> or timeout in the only existing path has the potential to cause
> long delays in the retransmission (depending on RTO_MAX) until
> the still active path is reselected.

The current behaviour doesn't seem very good - real networks tend
to have non-zero packet loss these days (for all sorts of reasons).

I guess that under moderate traffic flow retransmit requests from
the remote system recover the data before a timeout actually occurs.

That probably means that a path with a high error rate will continue
to be used when an alternate path would be much better.

I was wondering whether it is valid (or even reasonable) to send
the retransmit down multiple paths?  Particularly if they are
not known to be working.
Or maybe resend heartbeats in a desperate attempt to find a working
path?

Do you guys know which kernel version(s) have that patch?
We have a few customers using sctp (for m3ua) and I really ought
to keep track of the 'good' and 'bad' kernel versions.

	David
