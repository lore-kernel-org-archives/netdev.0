From: Adrian Bunk <bunk@fs.tum.de>
Subject: Re: RFC: [2.6 patch] disallow modular IPv6
Date: Mon, 29 Sep 2003 02:14:39 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030929001439.GY15338@fs.tum.de>
References: <20030928225941.GW15338@fs.tum.de> <20030928231842.GE1039@conectiva.com.br> <20030928232403.GX15338@fs.tum.de> <20030928233909.GG1039@conectiva.com.br>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-bounce@oss.sgi.com>
To: Arnaldo Carvalho de Melo <acme@conectiva.com.br>, netdev@oss.sgi.com,
        davem@redhat.com, pekkas@netcore.fi,
        lksctp-developers@lists.sourceforge.net, linux-kernel@vger.kernel.org
Content-Disposition: inline
In-Reply-To: <20030928233909.GG1039@conectiva.com.br>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sun, Sep 28, 2003 at 08:39:10PM -0300, Arnaldo Carvalho de Melo wrote:
> 
> Its not just this, look at all the CONFIG_IPV6 related #ifdefs in the core
> tcp/ip v4 code, the point is that this is a (currently) needed limitation to be
> able to ship a kernel that can be used by both ipv6 users and people that
> doesn't (yet) need ipv6.
> 
> Simply removing the ifdefs in the headers will not help, leaving it in the
> kernel will bloat general purpose kernels, so can we live with this limitation
> till we sort out the IPV6/IPV4 entanglement in a good way? I.e. lets leave ipv6
> as a special case, perhaps just adding a big fat warning in relevant Kconfigs.

What about the following solution (the names and help texts for the
config options might not be optimal, I hope you understand the
intention):

config IPV6_SUPPORT
	bool "IPv6 support"

config IPV6_ENABLE
	tristate "enable IPv6"
	depends on IPV6_SUPPORT

IPV6_SUPPORT changes structs etc. and IPV6_ENABLE is responsible for 
ipv6.o .

> - Arnaldo

cu
Adrian

-- 

       "Is there not promise of rain?" Ling Tan asked suddenly out
        of the darkness. There had been need of rain for many days.
       "Only a promise," Lao Er said.
                                       Pearl S. Buck - Dragon Seed
