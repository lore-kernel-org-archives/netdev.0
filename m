From: David Stevens <dlstevens@us.ibm.com>
Subject: Re: [RFC/PATCH] "strict" ipv4 reassembly
Date: Tue, 17 May 2005 15:40:23 -0700
Message-ID: <OF16EC9302.031C4230-ON88257004.007BA491-88257004.007C8D46@us.ibm.com>
References: <428A6DAF.7040600@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
In-Reply-To: <428A6DAF.7040600@hp.com>
To: Rick Jones <rick.jones2@hp.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

> in broad handwaving terms, those N other datagrams (non-fragmented or 
fragmented
> and successfully reassembled or not I suspect) are a measure of just how 
far
> "out of order" the rest of the fragments of this datagram happen to be. 
for
> some degree of "out of orderness" we can ass-u-me the datagram is toast.

> chosing a strawman, if we've received 24000 datagrams from that 
source/dest/prot
> (perhaps even just that source) since we've started reassembling this 
datagram
> from that source/dest/prot, chances seem pretty good indeed that this 
datagram
> is toast.  a value of N even smaller than 24000 might suffice.

> the devil seems to be in the accounting.

        This assumes that you have a per-destination IP ID. If it's 
per-route,
you can send 1 packet to host A, 65534 to host B through the same route, 
and
1 to host A-- wrap on the next received packet, as far as host A is 
concerned.
(even sooner, if it's using randomized ID's or a bigger-than-1 increment).
        Since it's the other side, which need not be Linux, I think
assumptions about how ID's are generated open the possibility of breaking
something that works now.
        I think an estimator for the interarrival time of fragments for
the same packet, per destination, is what you really want here. The
problem is path changes can cause the timeout to change dramatically,
and you don't want something too short to cause you to drop packets
when there was no wrap. But if it's a conservative estimate, it beats
accidental corruption.
        I can do DoS or intentional corruption if I can generate a
fragment as soon as I know the ID (by guessing, or by getting my
fragment in after I've seen the the first one sent), so I'm not
sure that can be fixed, except by using IPsec, if it concerns you. :-)

                                                        +-DLS
