From: David Stevens <dlstevens@us.ibm.com>
Subject: Re: Fragment ID wrap workaround (read-only, untested).
Date: Thu, 15 Jul 2004 09:54:53 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <OF6D39F992.163676EB-ON88256ED2.005AF110-88256ED2.005CC82F@us.ibm.com>
References: <20040715182735.3787c8b1.ak@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Cc: netdev@oss.sgi.com, rusty@au1.ibm.com
Return-path: <netdev-bounce@oss.sgi.com>
In-Reply-To: <20040715182735.3787c8b1.ak@suse.de>
To: Andi Kleen <ak@suse.de>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Andi Kleen wrote on 07/15/2004 09:27:35 AM:

> I'm well aware of the Gigabit+ NFS problem. My standard suggestion to 
solve
> it is to just get rid of NFS over UDP - it always was a bad idea.

No disagreement here.

> My point was just that you're concentrating on that one only,
> but you're potentially causing more problems for slow links.
> The stack has to work well both for slow and fast links though.

That's the problem it's intended to solve, but of course any
actual solution would have to behave well for all links, and
that's in fact the whole reason to have a dynamic frag queue
timeout instead of a fixed one for all links. As long as the
timeout is conservative without being so enormously so that it
allows IP ID wrap, it shouldn't affect any existing use at all.

If the timeout were scaled to be only 10 (or 100!) times any reasonable
expectation of success rather than thousands or tens of thousands
of times too large, the problem wouldn't exist on fast links, and
slow links would behave exactly as they do now.

I agree that NFS over UDP should be dead as soon as possible,
and fragmentation in general not far behind it. They aren't quite
dead yet; until they are, why not make them better behaved? And
if your argument is that it isn't worth fixing because it isn't
used, then of course the argument that it'll break slow links to
change it doesn't fly. Sites obviously have fast links where this
can break, and done correctly, this shouldn't affect slow links
at all. People who don't use NFS over UDP aren't affected by it
either way, right? :-)
                                                        +-DLS
