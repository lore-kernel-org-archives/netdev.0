From: David Stevens <dlstevens@us.ibm.com>
Subject: Re: 6to4/SIT and IP DF
Date: Wed, 15 Oct 2003 00:15:21 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <OFBD470C6E.206063CD-ON88256DC0.0025444B@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: r.venning@telstra.com, <nate@thebog.net>, <davem@redhat.com>,
        <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Pekka Savola <pekkas@netcore.fi>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org





Pekka Savola writes:
>Seems like a good idea.  The only thing I'm worried about is when someone
>is attached to a network of at least 1500 MTU (at IPv6 level), and uses
>6to4 -- then basically every IPv6 packet over 1480 bytes will be
>fragmented in the network, even though it could potentially be chopped to
>smaller pieces already in the end-nodes.
>
>Just wondering how our 6to4 implementation handles this case at the
>moment..

The tunnel device does subtract the enscapsulating header, so v6-only PMTU
should work
up to the tunnel endpoint, and a v6 source should only generate 1480
(because that's what the
tunnel endpoint MTU would be) if the entire path is 1500.

But if the destination path is something less than the tunnel endpoint's
MTU, then I expect
every packet bigger than that PMTU would be fragmented. I'm concerned that
with DF set, as
it is now, every packet in that range would be dropped, if the IPv4
Frag-Needed-But-DF-Set (FNBDFS :-))
does not include enough v6 header & payload  to identify the v6 sender.

I haven't looked enough at the this code to see what's done (if anything)
with PMTU in this case--
for example, if it tries to adjust the tunnel endpoint MTU, or translate
the v4 PMTU to v6 when there
is enough included. Or trigger a v6 PMTU message based on a v4 route's PMTU
and not the
tunnel's MTU.

I really don't know what it does now for this case, and it may be good
already, or some of those
options may be more appropriate-- really just seeing if anyone's been
through this already. :-)
The technical violation of setting DF may be better than not setting it, if
the right goodies are
already there-- anybody know?

                  +-DLS
