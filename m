From: Jamie Lokier <jamie@shareable.org>
Subject: Re: [RFC] High Performance Packet Classifiction for tc framework
Date: Wed, 13 Aug 2003 20:17:57 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030813191757.GE4405@mail.jlokier.co.uk>
References: <3F16A0E5.1080007@hipac.org> <1059934468.1103.41.camel@jzny.localdomain> <3F2E5CD6.4030500@hipac.org> <1060012260.1103.380.camel@jzny.localdomain> <3F302E04.1090503@hipac.org> <1060286331.1025.73.camel@jzny.localdomain> <3F381B3E.6080807@hipac.org> <20030811224050.59bc36fe.davem@redhat.com> <20030812142913.GB18802@mail.jlokier.co.uk> <Pine.LNX.4.51.0308131320470.13253@ns.istop.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "netdev@oss.sgi.com" <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: ralph+d@istop.com
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.51.0308131320470.13253@ns.istop.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Ralph Doncaster wrote:
> However if you have 32 tables (one for each prefix length) I can't see any
> possible way of avoiding a search in each table for the worst case.  So if
> my packet is destined to 217.109.118.70 you need to start looking for a
> match for a /32 route, and if not found continue checking each prefix size
> until you've reached /0.

You would start by search for a 217.109.0.0/16 entry.  That's
the root in the search tree.

That would match, and the matching tree node would tell you to search
a specific table for 217.109.118.0/24.  (Actually, just
0.0.118.0/0.0.255.0, because this node can assume the first 16 bits).

That would match, and the matching tree node tells you to search a
specific table for 217.109.118.64/28 (0.0.0.64/0.0.0.240).

That would match, and the matching tree node tells you to search a
specific table for 217.109.118.68/32 (0.0.0.6/0.0.0.15).

That would match, and is your result.

Without the optimisation you said you understand, there would be a few
more steps, narrowing to /30, /31 then /32, but for such small hashes,
not only is it faster, it also uses less memory to just use a single
4-bit table lookup than to have a tree of tiny hash tables.

-- Jamie
