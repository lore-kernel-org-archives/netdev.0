From: "David S. Miller" <davem@redhat.com>
Subject: Re: PMTU issues due to TOS field manipulation (for DSCP)
Date: Wed, 10 Dec 2003 14:51:49 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031210145149.2bd89e9b.davem@redhat.com>
References: <Pine.LNX.4.44.0312102301550.1285-100000@u.domain.uli>
	<3FD79FF1.8000505@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: ja@ssi.bg, ak@suse.de, ruddk@us.ibm.com, kuznet@ms2.inr.ac.ru,
        netdev@oss.sgi.com, chester.f.johnson@intel.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Nivedita Singhvi <niv@us.ibm.com>
In-Reply-To: <3FD79FF1.8000505@us.ibm.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


Here is my take on this, as far as Linux is concerned.

I agree with the three behaviors proposed by Julian.
However I have some slight trouble with the ignore-TOS-for-
PMTU idea, implementation wise.

Walking the routing hash table for each possible TOS value
is going to be computationally expensive, and is inviting
computational complexity DDoS attacks by bombing the machine
with PMTU ICMP messages.

That is the most obvious implementation, and I'm not saying there
are not others.  I just have no alternatives in mind right now :)

But once that issue is resolved I'm more than happy to put a patch
in which does this stuff.

We even have been speaking about this in other threads on netdev
wrt. Julian's patches.  TOS is truly a value with only network local
meaning and hops are going to modify the value on us.  I'm actually
surprised this is the first time the issue has been seriously hit.
