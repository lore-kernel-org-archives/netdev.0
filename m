From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH 01/02 V3] net/ipv6: seperate sit driver to extra module
Date: Sun, 05 Nov 2006 23:35:07 +0100
Message-ID: <454E671B.2090302@trash.net>
References: <20061010153745.GA27455@zlug.org> <452FD6F6.3090907@l4x.org> <20061013191744.GA30089@zlug.org> <20061013.150608.63128976.davem@davemloft.net> <45301CB3.4060803@l4x.org> <20061014093255.GA4646@zlug.org>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------070107090809010407060109"
Cc: Jan Dittmer <jdi@l4x.org>, David Miller <davem@davemloft.net>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:48042 "EHLO
	stinky.trash.net") by vger.kernel.org with ESMTP id S1422759AbWKEWfV
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 5 Nov 2006 17:35:21 -0500
To: Joerg Roedel <joro-lkml@zlug.org>
In-Reply-To: <20061014093255.GA4646@zlug.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------070107090809010407060109
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit

Joerg Roedel wrote:
> On Sat, Oct 14, 2006 at 01:09:39AM +0200, Jan Dittmer wrote:
> 
>>Btw. is there any way to autoload the sit module or is this the
>>task of the distribution tools? Debian etch at least does not
>>automatically probe the module when trying to bring up a 6to4 tunnel.
> 
> 
> AFAIK there is no way to automatically load the driver from the kernel
> space. The configuration of the tunnel devices requires the sit0 device.
> But this device is installed by the sit driver. I mailed a bug report to
> the Debian people and informed them about the change.


It would be nice to keep things working even with this built as a
module, it took me some time to realize my IPv6 tunnel was broken
because of the missing sit module. This module alias fixes things
until distributions have added an appropriate alias to modprobe.conf.

Signed-off-by: Patrick McHardy <kaber@trash.net>


--------------070107090809010407060109
Content-Type: text/plain;
 name="x"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="x"

diff --git a/net/ipv6/sit.c b/net/ipv6/sit.c
index b481a4d..be699f8 100644
--- a/net/ipv6/sit.c
+++ b/net/ipv6/sit.c
@@ -854,3 +854,4 @@ int __init sit_init(void)
 module_init(sit_init);
 module_exit(sit_cleanup);
 MODULE_LICENSE("GPL");
+MODULE_ALIAS("sit0");

--------------070107090809010407060109--
