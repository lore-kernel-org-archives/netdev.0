From: Cong Wang <amwang@redhat.com>
Subject: RE: [RFC Patch net-next] tcp: add a global sysctl to control TCP
 delayed ack
Date: Thu, 17 Jan 2013 17:21:46 +0800
Message-ID: <1358414506.2547.9.camel@cr0>
References: <1358334345-28980-1-git-send-email-amwang@redhat.com>
	 <AE90C24D6B3A694183C094C60CF0A2F6026B7110@saturn3.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Eric Dumazet <eric.dumazet@gmail.com>,
	Rick Jones <rick.jones2@hp.com>,
	Stephen Hemminger <shemminger@vyatta.com>,
	"David S. Miller" <davem@davemloft.net>,
	Thomas Graf <tgraf@suug.ch>
To: David Laight <David.Laight@ACULAB.COM>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:45502 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755642Ab3AQJWK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 17 Jan 2013 04:22:10 -0500
In-Reply-To: <AE90C24D6B3A694183C094C60CF0A2F6026B7110@saturn3.aculab.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2013-01-16 at 12:22 +0000, David Laight wrote:
> > According to previous discussion, it seems there is no
> > reasonable heuristics.
> > 
> > Similar to TCP_QUICK_ACK option, but for people who can't
> > modify the source code and still wants to control
> > TCP delayed ACK behavior.
> > 
> > Makes any sense?
> 
> A sysctl is a bit of a big hammer, it probably isn't necessary
> to disable delayed acks on all connections.

You mean make this sysctl per-socket? But we don't have per-socket or
per-connection sysctl for networking, do we?

> 
> IIRC the related problems I saw were really on the sending
> side when Nagle is disabled and it is doing 'slow start'.
> 
> Globally disabling on connections that have Nagle disabled
> might be a possibility - but it is the Nagle parameter
> at the other end that matters.
> 
> Perhaps the sending side, after sending 4 small frames immediately,
> could send 1 or 2 additional full sized frames in order to
> provoke an ack (IIRC an ack is sent if there are 2 full sized
> frames of data unacked).
> 
> The other problem is that 'slow start' is restarted very
> aggressively - whenever there is no unacked data.
> If you have a very low latency connection and aren't doing
> continuous bulk transfer it is restarted for every short
> burst of transmits - effectively after every received ack.
> There really ought to have to be a moderate idle time
> before 'slow start' is restarted.
> 

These situations are not easy at all to detect.

Thanks.
