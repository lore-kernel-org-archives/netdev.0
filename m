From: Jamie Lokier <jamie@shareable.org>
Subject: Re: [RFC] High Performance Packet Classifiction for tc framework
Date: Thu, 14 Aug 2003 00:21:58 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030813232158.GA6181@mail.jlokier.co.uk>
References: <3F2E5CD6.4030500@hipac.org> <1060012260.1103.380.camel@jzny.localdomain> <3F302E04.1090503@hipac.org> <1060286331.1025.73.camel@jzny.localdomain> <3F381B3E.6080807@hipac.org> <20030811224050.59bc36fe.davem@redhat.com> <20030812142913.GB18802@mail.jlokier.co.uk> <Pine.LNX.4.51.0308131320470.13253@ns.istop.com> <20030813191757.GE4405@mail.jlokier.co.uk> <Pine.LNX.4.51.0308131707280.21992@ns.istop.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "netdev@oss.sgi.com" <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: ralph+d@istop.com
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.51.0308131707280.21992@ns.istop.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Ralph Doncaster wrote:
> So you have to put an entry in the /16 table for every /16 that you have a
> more specific route for, right?
> Then what if I have 3 different routes; one for 217.109.0.0/16, another
> for 217.109.118.0/24 and one for 217.109.118.68/32?

Then you would have one entry in the /16 table, matching
217.109.0.0/16, whose BEST value is the first route and whose LARGER
points to another table.

The second table would have one entry matching 217.109.118.0/24, whose
BEST value is the second route, and whose LARGER points to another
table.

The third table would have one entry matching 217.109.118.68/32, whose
BEST value is the third route, and which has no LARGER.

That's three hash tables, each containing just one entry.

-- Jamie
