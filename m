From: Thomas Themel <themel@iwoars.net>
Subject: Source addresses of rerouted packets
Date: Tue, 28 Oct 2003 22:56:00 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031028215600.GE15501@iwoars.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi,

I've recently tried to do policy routing of locally generated traffic
based on a netfilter fwmark.  This works, in a way, but doesn't achieve
the result I want. I want to route locally originating connections
differently based on their fwmark, but the packets always end up with
the wrong source address (that of the interface they would go out on if
they hadn't been marked).

After seeing this both with 2.4.20 and 2.6.0-test9, I've had a quick
look at the routing code, and what I believe is happening is

- the new socket doesn't yet have a source address
- the SYN packet is queued and routed, thus the socket gets a source address
- the SYN packet is caught by the netfilter rule and marked
- the SYN packet is rerouted, but at that point, it/its socket already
  has the source address of the original route and doesn't get the
  address of the different route it is now sent on.

Is this behaviour intended? Following the principle of least surprise, I
would expect a locally generated packet to get the source address of the
last route it traverses.

ciao,
-- 
[*Thomas  Themel*]      'To a hardcore geek, "Open" and "Source" are like
[extended contact]   the nipples on the breasts of Jennifer Love Hewitt.'
[info provided in]              - Mr. Cranky reviewing "Antitrust"
[*message header*]   <URL:http://www.mrcranky.com/movies/antitrust.html>
