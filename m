From: David Stevens <dlstevens@us.ibm.com>
Subject: Re: node-local multicast issues
Date: Tue, 9 Nov 2004 15:21:54 -0800
Message-ID: <OF18E2258F.5E2E252A-ON88256F47.007FA9FD-88256F47.0080590C@us.ibm.com>
References: <1099995700.21310.8.camel@mn-2>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Cc: hessu@cs.tut.fi, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
In-Reply-To: <1099995700.21310.8.camel@mn-2>
To: Mark Borst <mark@borst.org>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

        The loopback device doesn't have IFF_MULTICAST set, so technically
it is not a multicast-capable device, and you shouldn't be able to join a 
group on it.
I think the way it ought to work is that you join the group on any device, 
with
IPV6_MULTICAST_LOOP set and local guys should hear the node-local 
multicasts,
but it shouldn't be sent on the wire. Multicasting could be supported on 
loopback, too,
but it doesn't matter all that much unless there are no multicast-capable 
real devices.
        However, it appears that node-local multicasts are being sent out 
the device,
at least on an early 2.6 kernel I did a quick test with. There probably 
isn't anything
enforcing the node-locality in the send path, which I would consider a 
bug. :-)

                                                +-DLS
