From: Andi Kleen <ak@suse.de>
Subject: Re: Fragment ID wrap workaround (read-only, untested).
Date: Thu, 15 Jul 2004 11:27:17 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040715092715.GA23131@wotan.suse.de>
References: <1089871078.3571.56.camel@bach> <OF339FA69C.C0404720-ON88256ED2.002C1123-88256ED2.002E61B7@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "Rusty Russell (IBM)" <rusty@au1.ibm.com>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: David Stevens <dlstevens@us.ibm.com>
Content-Disposition: inline
In-Reply-To: <OF339FA69C.C0404720-ON88256ED2.002C1123-88256ED2.002E61B7@us.ibm.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, Jul 15, 2004 at 02:28:05AM -0600, David Stevens wrote:
> My idea for solving this problem is to create an estimator for the
> reassembly timer. The fundamental problem as I see it is that the
> reassembly timer is fixed, and about 6000 times too long on a
> fast network (and worse the faster networks get).

Won't that make the worst case behaviour on a congested link much worse?

e.g. consider a very congested link with variable RTTs. Or a 
link that works relatively smoothly and suddenly the RTT increases.

Yes, running fragmentation over those is not a good idea, but
still it should not be made worse.

Your variable timer even with a smoothing algorithm in the RTT 
estimator will expire far too early and very likely drop a lot more 
fragments in this scenario than before.

In general handling a link where the RTT increases would seem
tricky with your scheme. Unlike TCP there is no retransmit
to save the day.

-Andi
