From: Werner Almesberger <wa@almesberger.net>
Subject: Re: [Fwd: [ANNOUNCE] Layer-7 Filter for Linux QoS]
Date: Sat, 24 May 2003 01:11:48 -0300
Sender: linux-net-owner@vger.kernel.org
Message-ID: <20030524011148.A29146@almesberger.net>
References: <Pine.LNX.4.40.0305220107460.29409-100000@phil.home.phil> <3ECC0B14.7020105@ethanet.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Philippe Biondi <biondi@cartel-securite.fr>,
	Jamal Hadi <hadi@shell.cyberus.ca>,
	Martin Josefsson <gandalf@wlug.westbo.se>,
	"David S. Miller" <davem@redhat.com>, linux-net@vger.kernel.org,
	netdev@oss.sgi.com
Return-path: <linux-net-owner@vger.kernel.org>
To: Ethan Sommer <sommere@ethanet.com>
Content-Disposition: inline
In-Reply-To: <3ECC0B14.7020105@ethanet.com>; from sommere@ethanet.com on Wed, May 21, 2003 at 06:26:12PM -0500
List-Id: netdev.vger.kernel.org

Ethan Sommer wrote:
> I take it back, it is regular (kinda) but you can't to it with a 
> deterministic finite atomaton. If there is a cycle in pattern1, off of 
> which pattern2 has a branch, then you would need to count how many times 
> you have gone around the cycle to know where to jump to in pattern2 if 
> it fails to match pattern1

You mean things like

a*b -> 1
ac -> 2

? You can still express this with a DFA, i.e.

a(c|a*b)

Of course, if you have patterns that match the same string, you
need to decide at some point whether you want longest or shortest
match.

For the idea of using regexps for all types of classification: 
this is definitely something I'd love to see. The problem I've
encountered is that it seems prohibitively expensive to
construct an efficient DFA from human-friendly input.

I experimented a bit with this in tcng, but never got to a
usable solution. (tcng can handle arbitrary expressions, but
it does this by following a collection of rules for rewriting
the expression into a canonical and possibly redundant form.
Basically, it does what a human being would do if given the
task of simplifying a Boolan expression. This is usually quick,
but has very ugly worst-case overhead.)

I never thought of viewing this as a regexp, though. For this,
one would need to be able to introduce positions, e.g. through
the ability of putting "^" in the middle of an expression.
Example:

^(A|B|C)(^D)|^(E|D)

where A ... E would be strings containing 0, 1, or .

Example:

ip_tos == 0xb8:   ^........10111000

Now, how to turn such expressions with embedded ^ efficiently
into a DFA ?

- Werner

-- 
  _________________________________________________________________________
 / Werner Almesberger, Buenos Aires, Argentina         wa@almesberger.net /
/_http://www.almesberger.net/____________________________________________/
