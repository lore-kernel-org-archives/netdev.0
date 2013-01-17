From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [RFC Patch net-next] tcp: add a global sysctl to control TCP
 delayed ack
Date: Thu, 17 Jan 2013 12:34:20 +0000
Message-ID: <20130117123420.GA23639@casper.infradead.org>
References: <1358334345-28980-1-git-send-email-amwang@redhat.com>
 <AE90C24D6B3A694183C094C60CF0A2F6026B7110@saturn3.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Cong Wang <amwang@redhat.com>, netdev@vger.kernel.org,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Rick Jones <rick.jones2@hp.com>,
	Stephen Hemminger <shemminger@vyatta.com>,
	"David S. Miller" <davem@davemloft.net>
To: David Laight <David.Laight@ACULAB.COM>
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:41871 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750901Ab3AQMe3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Jan 2013 07:34:29 -0500
Content-Disposition: inline
In-Reply-To: <AE90C24D6B3A694183C094C60CF0A2F6026B7110@saturn3.aculab.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/16/13 at 12:22pm, David Laight wrote:
> A sysctl is a bit of a big hammer, it probably isn't necessary
> to disable delayed acks on all connections.
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

Not that I disagree with this fundamentally but we already
have a socket option to enable the functionality. All this
patch does is making the same functionality available to
users that are not able to make modification on the
application level.

We can argue about making it available as route metric
exclusively though.
