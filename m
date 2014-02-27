From: "Skidmore, Donald C" <donald.c.skidmore@intel.com>
Subject: Re: [PATCH net-next] ixgbevf: fix skb->pkt_type checks
Date: Thu, 27 Feb 2014 22:39:05 +0000
Message-ID: <F6FB0E698C9B3143BDF729DF2228664685D6D5BF@ORSMSX110.amr.corp.intel.com>
References: <1393454640-19651-1-git-send-email-f.fainelli@gmail.com>
	<20140227.160741.1837528571194344504.davem@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "e1000-devel@lists.sourceforge.net" <e1000-devel@lists.sourceforge.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>, "Brandeburg,
	Jesse" <jesse.brandeburg@intel.com>
To: David Miller <davem@redhat.com>, "f.fainelli@gmail.com"
	<f.fainelli@gmail.com>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <20140227.160741.1837528571194344504.davem@redhat.com>
Content-Language: en-US
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

> -----Original Message-----
> From: David Miller [mailto:davem@redhat.com]
> Sent: Thursday, February 27, 2014 1:08 PM
> To: f.fainelli@gmail.com
> Cc: e1000-devel@lists.sourceforge.net; netdev@vger.kernel.org;
> Brandeburg, Jesse
> Subject: Re: [E1000-devel] [PATCH net-next] ixgbevf: fix skb->pkt_type
> checks
> 
> From: Florian Fainelli <f.fainelli@gmail.com>
> Date: Wed, 26 Feb 2014 14:44:00 -0800
> 
> > skb->pkt_type is not a bitmask, but contains only value at a time from
> > the range defined in include/uapi/linux/if_packet.h.
> >
> > Checking it like if it was a bitmask of values would also cause
> > PACKET_OTHERHOST, PACKET_LOOPBACK and PACKET_FASTROUTE to be
> matched
> > by this check since their lower 2 bits are also set, although that
> > does not fix a real bug due to how the checks are used, it is still potentially
> confusing.
> >
> > This bogus check was introduced in commit 815cccbf ("ixgbe: add
> > setlink, getlink support to ixgbe and ixgbevf").
> >
> > Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
> 
> Intel folks, I assume you will pick this up?
> 

This patch looks like it fixes an obvious bug on our part.  I'm sure Aaron will get to it soon.

Thanks Florin for pointing this out,
-Don Skidmore <donald.c.skidmore@intel.com>

------------------------------------------------------------------------------
Flow-based real-time traffic analytics software. Cisco certified tool.
Monitor traffic, SLAs, QoS, Medianet, WAAS etc. with NetFlow Analyzer
Customize your own dashboards, set traffic alerts and generate reports.
Network behavioral analysis & security monitoring. All-in-one tool.
http://pubads.g.doubleclick.net/gampad/clk?id=126839071&iu=/4140/ostg.clktrk
_______________________________________________
E1000-devel mailing list
E1000-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/e1000-devel
To learn more about Intel&#174; Ethernet, visit http://communities.intel.com/community/wired
