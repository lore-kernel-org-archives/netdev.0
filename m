From: kuznet@ms2.inr.ac.ru
Subject: Re: SCTP path mtu support needs some ip layer support.
Date: Tue, 14 Jan 2003 02:22:12 +0300 (MSK)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200301132322.CAA09642@sex.inr.ac.ru>
References: <Pine.LNX.4.33.0301131417440.1691-100000@dyn9-47-18-98.beaverton.ibm.com>
Mime-Version: 1.0
Cc: jgrimm2@us.ibm.com, davem@redhat.com, sri@us.ibm.com, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: sri@us.ibm.com (Sridhar Samudrala)
In-Reply-To: <Pine.LNX.4.33.0301131417440.1691-100000@dyn9-47-18-98.beaverton.ibm.com> from "Sridhar Samudrala" at Jan 13, 3 02:54:06 pm
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hello!

> I am not clear on your other alternative of adding a socket flag. Could you
> please elaborate on it?

Not to add any arguments just to help a broken protocol.
Simply to behave like UDP, i.e. to fragment all the oversized frames.
Probably, even new flag is not required, just check for
sk->protocol == IPPROTO_SCTP can be enough.

It is almost equivalent, it also send fragmented crap only when
mtu decreases. But this variant is _formally_ prohibited with:

>      fragmented.  Transmissions of new IP datagrams MUST have DF set.

BTW this MUST is even more ridiculous, you have to change ip_queue_xmit()
to do this, we disable pmtu discovery sometimes.


> I guess SCTP desginers have thought of this and explicitly indicate that we 

I am afraid SCTP designers thought with their spinal chrod. :-)
Relying on IP fragmentation promotes all the protocol to the status
of utter crap. So, long live TCP! :-)

Alexey
