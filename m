From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH 2.6]: Make packet scheduler clock source configurable
Date: Fri, 23 Jul 2004 01:36:22 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <41004F76.1080807@trash.net>
References: <40F34740.5040100@trash.net>	<1107.63.170.215.71.1089689716.squirrel@www.osdl.org>	<20040712205037.573411c0.davem@redhat.com>	<40F4862D.3070802@trash.net>	<40F4AC8B.40706@trash.net> <20040721143110.4ab944bf.davem@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: shemminger@osdl.org, netdev@oss.sgi.com, devik@cdi.cz
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
In-Reply-To: <20040721143110.4ab944bf.davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

David S. Miller wrote:
> This looks great.
> 
> As you mention some platforms return zero, for example sparc32,
> for get_cycles().
> 
> I suggest we just expand the dependency list for NET_SCH_CLK_TSC
> to include SPARC64 PPC64 and perhaps some other easy to verify
> as having a working get_cycles() implementation.  I believe that
> as long as it increments at some rate >= jiffies, the psched
> calibration will get things into a working state.

It needs to increment at slightly above 1Mhz, otherwise delay will
be zero after this division and everything will fall apart:
delay /= rdelay.

> A lot of patches have been posted in this area and I'm losing
> track of what to apply first etc.  Can you repost your work
> one change at a time?  Thanks.

The following two patches remove some dead timer code and
change PSCHED_GET_TIME to use get_cycles. I'm going to send
the configurable clock-source patch tomorrow after checking
the arches.

Regards
Patrick
