From: Bart De Schuymer <bdschuym@pandora.be>
Subject: Re: [PATCH][BRIDGE-NF] Fix wrong use of skb->protocol
Date: Fri, 31 Dec 2004 00:10:48 +0100
Message-ID: <1104448248.15601.55.camel@localhost.localdomain>
References: <1104432914.15601.19.camel@localhost.localdomain>
	 <20041230222415.GB19587@xi.wantstofly.org>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@oss.sgi.com,
        snort2004@mail.ru
Return-path: <netdev-bounce@oss.sgi.com>
To: Lennert Buytenhek <buytenh@wantstofly.org>
In-Reply-To: <20041230222415.GB19587@xi.wantstofly.org>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Op do, 30-12-2004 te 23:24 +0100, schreef Lennert Buytenhek:
> On Thu, Dec 30, 2004 at 07:55:14PM +0100, Bart De Schuymer wrote:
> 
> > ip_sabotage_out() needs to distinguish IPv4 and IPv6 traffic. It
> > currently does that by looking at skb->protocol. However, for locally
> > originated packets, skb->protocol is not initialized.
> > The patch below instead looks at the version number of the packet's
> > data, which should be 4 or 6.
> 
> A while ago there were a number of problems with bridging CIPE ethernet
> devices, which turned out to be the bridge code not initialising
> skb->protocol for locally originated STP frames.
> 
> At the time I was told that initialising skb->protocol for locally
> originated packets is required, so that is how I fixed it then.

Hi Lennert,

skb->protocol is not set for locally generated packets when the packet
is still in the IP stack. I don't know what happens with it after the IP
stack is finished with the packet.
The comment in skbuff.h says "packet protocol from driver", from which I
tend to conclude that skb->protocol is only set by drivers when a packet
enters the box. Too bad stuff like this isn't clearly spelled out, the
FIXME for the dst field has been sitting there for probably more than a
year too. Anyway, it wouldn't hurt if the skb->protocol field always
held the right value.

cheers,
Bart
