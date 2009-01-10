From: James Chapman <jchapman@katalix.com>
Subject: Re: [RFC 3/4] net: pppol2tp - introduce net-namespace functionality
Date: Sat, 10 Jan 2009 18:14:33 +0000
Message-ID: <4968E589.2020904@katalix.com>
References: <20090109195154.320495476@gmail.com>> <4967accc.0c58560a.2ee6.3de4@mx.google.com> <49688120.9000507@katalix.com> <20090110111359.GA29349@localhost> <20090110125444.GB29349@localhost> <4968B929.10801@katalix.com> <20090110151958.GC29349@localhost> <20090110161257.GD29349@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, devel@openvz.org, xemul@openvz.org
To: Cyrill Gorcunov <gorcunov@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from katalix.com ([82.103.140.233]:37232 "EHLO mail.katalix.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752327AbZAJSOo (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 10 Jan 2009 13:14:44 -0500
In-Reply-To: <20090110161257.GD29349@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Cyrill Gorcunov wrote:
> [Cyrill Gorcunov - Sat, Jan 10, 2009 at 06:19:58PM +0300]
> | [James Chapman - Sat, Jan 10, 2009 at 03:05:13PM +0000]
> | | Cyrill Gorcunov wrote:
> | | > [Cyrill Gorcunov - Sat, Jan 10, 2009 at 02:13:59PM +0300]
> | | > | [James Chapman - Sat, Jan 10, 2009 at 11:06:08AM +0000]
> | | > | | Cyrill Gorcunov wrote:
> | | > | | > - Each tunnel and appropriate lock are inside own namespace now.
> | | > | | > - pppox code allows to create per-namespace sockets for
> | | > | | >   both PX_PROTO_OE and PX_PROTO_OL2TP protocols. Actually since
> | | > | | >   now pppox_create support net-namespaces new PPPo... protocols
> | | > | | >   (if they ever will be) should support net-namespace too otherwise
> | | > | | >   explicit check for &init_net would be needed.
> | | 
> | | Ok, I tested this in my L2TP setup. The first ppp session setup fails
> | | because the PPPIOCNEWUNIT ioctl returns -EEXIST. I think the problem is
> | |  the logic in ppp_create_interface(), which does the following to create
> | | a new ppp interface:
> | | 
> | |         /* Initialize the new ppp unit */
> | |         ppp->file.index = unit;
> | |         sprintf(dev->name, "ppp%d", unit);
> | | 
> | |         ret = register_netdev(dev);
> | | 
> | | Looks like there is more work to do in the ppp changes.
> | | 
> | |
> ...
> 
> Btw James did connection work without these patches? On
> pure net-next-2.6 tree? I've some bad feeling that this
> fail is related to different patch. Just to be sure.

If you mean, does pppol2tp work with the patches applied when no
namespace is configured, yes it does.

But to test this patch, I ran two l2tp daemons (in different namespaces
on the same box) and used the veth device to connect them. The failure
happened on the first l2tp session create because each side tried to
create a ppp interface called ppp0.

Should all interface names be unique across the system even when netns
is used? If so, then ppp_generic needs to assign system-wide unique ppp
unit numbers.


-- 
James Chapman
Katalix Systems Ltd
http://www.katalix.com
Catalysts for your Embedded Linux software development

