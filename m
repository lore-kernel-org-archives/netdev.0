From: Cyrill Gorcunov <gorcunov@gmail.com>
Subject: Re: [RFC 3/4] net: pppol2tp - introduce net-namespace functionality
Date: Sat, 10 Jan 2009 18:19:58 +0300
Message-ID: <20090110151958.GC29349@localhost>
References: <20090109195154.320495476@gmail.com>> <4967accc.0c58560a.2ee6.3de4@mx.google.com> <49688120.9000507@katalix.com> <20090110111359.GA29349@localhost> <20090110125444.GB29349@localhost> <4968B929.10801@katalix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, devel@openvz.org, xemul@openvz.org
To: James Chapman <jchapman@katalix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fg-out-1718.google.com ([72.14.220.155]:60497 "EHLO
	fg-out-1718.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751217AbZAJPUE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 10 Jan 2009 10:20:04 -0500
Content-Disposition: inline
In-Reply-To: <4968B929.10801@katalix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

[James Chapman - Sat, Jan 10, 2009 at 03:05:13PM +0000]
| Cyrill Gorcunov wrote:
| > [Cyrill Gorcunov - Sat, Jan 10, 2009 at 02:13:59PM +0300]
| > | [James Chapman - Sat, Jan 10, 2009 at 11:06:08AM +0000]
| > | | Cyrill Gorcunov wrote:
| > | | > - Each tunnel and appropriate lock are inside own namespace now.
| > | | > - pppox code allows to create per-namespace sockets for
| > | | >   both PX_PROTO_OE and PX_PROTO_OL2TP protocols. Actually since
| > | | >   now pppox_create support net-namespaces new PPPo... protocols
| > | | >   (if they ever will be) should support net-namespace too otherwise
| > | | >   explicit check for &init_net would be needed.
| 
| Ok, I tested this in my L2TP setup. The first ppp session setup fails
| because the PPPIOCNEWUNIT ioctl returns -EEXIST. I think the problem is
|  the logic in ppp_create_interface(), which does the following to create
| a new ppp interface:
| 
|         /* Initialize the new ppp unit */
|         ppp->file.index = unit;
|         sprintf(dev->name, "ppp%d", unit);
| 
|         ret = register_netdev(dev);
| 
| Looks like there is more work to do in the ppp changes.
| 
| -- 
| James Chapman
| Katalix Systems Ltd
| http://www.katalix.com
| Catalysts for your Embedded Linux software development
| 

Thanks a lot James for testing!!! Will keep you in touch.
Thanks again!

		- Cyrill -
