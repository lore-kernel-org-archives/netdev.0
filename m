From: Andi Kleen <ak@suse.de>
Subject: Re: Fragment ID wrap workaround (read-only, untested).
Date: Thu, 15 Jul 2004 18:27:35 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040715182735.3787c8b1.ak@suse.de>
References: <20040715092715.GA23131@wotan.suse.de>
	<OF97127705.C0C08B6A-ON88256ED2.004DB9A5-88256ED2.005146DA@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, rusty@au1.ibm.com
Return-path: <netdev-bounce@oss.sgi.com>
To: David Stevens <dlstevens@us.ibm.com>
In-Reply-To: <OF97127705.C0C08B6A-ON88256ED2.004DB9A5-88256ED2.005146DA@us.ibm.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, 15 Jul 2004 07:49:13 -0700
David Stevens <dlstevens@us.ibm.com> wrote:

> 
> > Yes, running fragmentation over those is not a good idea, but
> > still it should not be made worse.
> 
> Delivery to the user of incorrect data is the problem, and, no, it doesn't
> make that worse. :-) The scenario, to make it clear for everyone, is a]

The data corruption problem only starts to become a real issue
at Gigabit Speeds and faster. Normally such congested links are much slower

> small loss rate on a fast network leads to reassembling packets with the
> same IP ID that are not the same packet when the ID wraps before the frag
> queue timer has expired. If you're blasting away on a gigabit network (or
> faster) and you drop one fragment (or more) from a packet you've received,
> that frag queue will be there 65536 packets later when you reuse the same 
> ID
> for a different packet. I think that works out to be 7 secs or so at full
> rate-- well within the 1-4 minute typical frag queue timer on most 
> systems.

[...]

I'm well aware of the Gigabit+ NFS problem. My standard suggestion to solve
it is to just get rid of NFS over UDP - it always was a bad idea.

My point was just that you're concentrating on that one only,
but you're potentially causing more problems for slow links.
The stack has to work well both for slow and fast links though.


> 
> > In general handling a link where the RTT increases would seem
> > tricky with your scheme. Unlike TCP there is no retransmit
> > to save the day.
> 
> In the particular case (NFS over UDP), there is both a retransmit (done
> by RPC) and significant loss rate to start with. As long as the time-out
> is conservative, I don't think this has to affect other cases
> significantly.

NFS over UDP is just a bad idea. Don't do it. NFS over TCP 
works fine these days and should be the prefered choice for everybody.

I don't really see the point of risking problems with slower links
just to fix a fundamentally flawed protocol.

And you cannot rely on all UDP based protocols doing this as well.

-Andi
