From: Simon Kirby <sim@netnation.com>
Subject: Re: Route cache performance tests
Date: Tue, 17 Jun 2003 14:07:01 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030617210700.GE25773@netnation.com>
References: <20030616.160856.35828947.davem@redhat.com> <20030616232750.GD18484@netnation.com> <20030616234937.GE18484@netnation.com> <20030617.085921.28790392.davem@redhat.com> <16111.18107.699689.704597@robur.slu.se> <20030617200721.GA25773@netnation.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@redhat.com>, ralph+d@istop.com,
   hadi@shell.cyberus.ca, xerox@foonet.net, fw@deneb.enyo.de,
   netdev@oss.sgi.com, linux-net@vger.kernel.org
Return-path: <netdev-bounce@oss.sgi.com>
To: Robert Olsson <Robert.Olsson@data.slu.se>
Content-Disposition: inline
In-Reply-To: <20030617200721.GA25773@netnation.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, Jun 17, 2003 at 01:07:21PM -0700, Simon Kirby wrote:

> Whoa.  Uhm.  A lot.  I should compare with 2.4 again to see what's going
> on here.
> 
> 60.0042 seconds passed, avg forwarding rate: 50759.683 pps

Ummmm, yeah, 2.5.71 is quite a bit slower than 2.4.21.  I applied
Alexey's 2.5.71 rtcache fixes to 2.4.21 (changing "fl" to "key" in
the scoring function), and now I see:

60.0065 seconds passed, avg forwarding rate: 135379.152 pps

If reboot and don't fill the routing table:

60.0104 seconds passed, avg forwarding rate: 259027.200 pps

This is with standard juno (pseudo-random sources).

This is with CONFIG_IP_MULTIPLE_TABLES still on, too.  I'll turn that off
and do some profiles.  The only weird thing I'm seeing while doing this
is that the route cache table continues to grow slowly, and the pps
slowly falls off over a few minutes.  "ip route flush cache" restores
performance again.  I'll verify this is not happening in 2.5.

Simon-

[        Simon Kirby        ][        Network Operations        ]
[     sim@netnation.com     ][   NetNation Communications Inc.  ]
[  Opinions expressed are not necessarily those of my employer. ]
