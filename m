From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH] ethtool_ops rev 4
Date: Fri, 01 Aug 2003 19:09:35 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <3F2AF32F.7090201@pobox.com>
References: <20030801150232.GV22222@parcelfarce.linux.theplanet.co.uk>	<20030801154021.GA7696@gtf.org>	<20030801154656.GW22222@parcelfarce.linux.theplanet.co.uk>	<20030801162536.GA18574@gtf.org>	<20030801132037.3f3542ae.davem@redhat.com>	<3F2AE91D.5090705@pobox.com>	<3F2AEB33.9050506@pobox.com> <20030801153439.4a324c36.davem@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: willy@debian.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
In-Reply-To: <20030801153439.4a324c36.davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

David S. Miller wrote:
> On Fri, 01 Aug 2003 18:35:31 -0400
> Jeff Garzik <jgarzik@pobox.com> wrote:
> 
> 
>>We want to provide a sane, ifdef-free path to kcompat, where feasible.
> 
> 
> I don't believe it's possible with netdev_ops, without
> undoing the entire purpose of what netdev_ops is trying
> to accomplish (elimination of code duplication).
> 
> Show me, in code not words, how you are able to accomplish
> this with SET_NETDEV_OPS() or whatever.  I will not read
> english text describing the scheme, I will read only code :)

Read kcompat.  Then:

#define SET_ETHTOOL_OPS kcompat_set_ethtool_ops

#define DO_ETHTOOL_OPS /* duplicate net/core/ethtool.c, basically */

I would define both of these in Matthew's patch, but one only _needs_ to 
define SET_ETHTOOL_OPS, so I pushed for the latter course.

So why is SET_ETHTOOL_OPS needed?  It covered up the one place

It intentionally follows the same design as SET_MODULE_OWNER, and for 
the same purpose:  hiding what would otherwise be a naked struct deref 
to a struct member that does not exist on an older kernel.

Hiding naked struct derefs is also the reason I created 
pci_{get,drv}_drvdata, pci_resource_*, etc.  Back compat is really a big 
syntactic sugar game, and naked struct derefs are really the only big 
thorn in the side.  Everything else can be beaten down with syntactic 
sugar behind the scenes, that never ever gets merged into the upstream 
kernel.

	Jeff
