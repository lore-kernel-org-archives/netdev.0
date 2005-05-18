From: Andi Kleen <ak@muc.de>
Subject: Re: [RFC/PATCH] "strict" ipv4 reassembly
Date: Wed, 18 May 2005 03:05:01 +0200
Message-ID: <m1wtpx5ooy.fsf@muc.de>
References: <20050517232556.GA26846@gondor.apana.org.au>
	<428A871F.1000308@us.ibm.com>
	<20050518001054.GB27212@gondor.apana.org.au>
	<20050517.175126.74751342.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: niv@us.ibm.com, akepner@sgi.com, dlstevens@us.ibm.com, rick.jones2@hp.com,
        netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
In-Reply-To: <20050517.175126.74751342.davem@davemloft.net> (David S.
 Miller's message of "Tue, 17 May 2005 17:51:26 -0700 (PDT)")
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

"David S. Miller" <davem@davemloft.net> writes:

> From: Herbert Xu <herbert@gondor.apana.org.au>
> Subject: Re: [RFC/PATCH] "strict" ipv4 reassembly
> Date: Wed, 18 May 2005 10:10:54 +1000
>
>> On Tue, May 17, 2005 at 05:06:55PM -0700, Nivedita Singhvi wrote:
>> > 
>> > Mainline linux certainly has this (per-inetpeer ip_id) - but
>> > at least one distro did not (use inetpeer) :). Not sure
>> > what the current situation is.
>> 
>> What was the reason for this? Perhaps we can solve their problems
>> with inetpeer in a better way than disabling it?
>
> Andi Kleen thought inetpeer was a pig, so he removed it from SUSE's
> kernel and replaced it with a per-cpu salted IP ID generator.  The
> initial verion he wrote had serious bugs that severely decreased the
> effective ID space, and thus made the NFS corruption problem happen
> more frequently.

That's not true, there were no bugs it in. Or at least none
I know about.

However any randomized IPID scheme decreases the effective IP-ID
space slightly. The only algorithm that uses a bit space perfectly
is a counter :) However I admit the constant to regulate the grainness 
was a bit too aggressive at the beginning, which indeed triggered
the NFS corruption problem more frequently. However since the 16bit
space is more or less useless (as Artur demonstrated it cannot
even handle a single Gigabit link) it did not make that much difference anyways.

The eventual workaround for the NFS IP-ID problem that went into
the vendor kernel also did work in a different way on top 
of the algorithm.

As for the background (not for you Dave, for other readers ;-) why I
consider inetpeer useless please read the archives. As a hint just
look what kind of functionality it implements and how much of it is
actually enabled by default and think of its relationship to masquerading
(which BTW breaks most of the fancy algorithms proposed so far) 

-Andi
