From: Ben Greear <greearb@candelatech.com>
Subject: Re: [PATCH] netdev_ops
Date: Tue, 08 Jul 2003 13:44:32 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <3F0B2D30.4020102@candelatech.com>
References: <20030708163042.GL23597@parcelfarce.linux.theplanet.co.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Matthew Wilcox <willy@debian.org>
In-Reply-To: <20030708163042.GL23597@parcelfarce.linux.theplanet.co.uk>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Matthew Wilcox wrote:
> After a conversation with acme, I realised that ethtool_ops is far too
> narrow scope.  What we need are netdev_ops.  This patch renames the
> ethtool_ops to netdev_ops and fixes some other minor flaws:
> 
>  - add _len() ops for operations which previously had to kmalloc their
>    own memory.
>  - move the netdev_ops from ethtool.h to netdevice.h
>  - makes some ops generic as requested by Jeff Garzik.
> 
> I think netdev_ops is still a little too ethtool-specific; something
> I'd like to do is convert the parameters to be a little less
> ethtool-related.  For example, instead of ->get_drvinfo, I'd like to
> see ethtool_get_drvinfo() call several methods and fill in all the data
> that way.
> 
> But let's see what everyone thinks of this patch first ...
> 

> + * Each operation is passed a &struct net_device as its first parameter.

Some of these are missing their netdevice arg?
> +	int	(*get_regs_len)(struct ethtool_regs *);

> +	int	(*self_test_len)(struct ethtool_test *);

> +	int	(*get_strings_len)(struct ethtool_gstrings *);

> +	int	(*get_stats_len)(struct ethtool_stats *);



-- 
Ben Greear <greearb@candelatech.com>       <Ben_Greear AT excite.com>
President of Candela Technologies Inc      http://www.candelatech.com
ScryMUD:  http://scry.wanfear.com     http://scry.wanfear.com/~greear
