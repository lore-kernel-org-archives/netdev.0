From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH] ethtool_ops rev 4
Date: Sat, 02 Aug 2003 23:14:26 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <3F2C7E12.8070904@pobox.com>
References: <20030801150232.GV22222@parcelfarce.linux.theplanet.co.uk> <20030801154021.GA7696@gtf.org> <20030801154656.GW22222@parcelfarce.linux.theplanet.co.uk> <20030801162536.GA18574@gtf.org> <20030802222145.GE22222@parcelfarce.linux.theplanet.co.uk> <3F2C3C86.6000202@pobox.com> <20030803002744.GF22222@parcelfarce.linux.theplanet.co.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Matthew Wilcox <willy@debian.org>
In-Reply-To: <20030803002744.GF22222@parcelfarce.linux.theplanet.co.uk>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Matthew Wilcox wrote:
> On Sat, Aug 02, 2003 at 06:34:46PM -0400, Jeff Garzik wrote:
> 
>>>diff -u include/linux/netdevice.h include/linux/netdevice.h
>>>--- include/linux/netdevice.h   31 Jul 2003 13:06:23 -0000
>>>+++ include/linux/netdevice.h   2 Aug 2003 18:37:16 -0000
>>>@@ -477,6 +477,10 @@
>>> */
>>>#define SET_NETDEV_DEV(net, pdev)      ((net)->class_dev.dev = (pdev))
>>>
>>>+static inline void set_ethtool_ops(struct net_device *dev, struct 
>>>ethtool_ops *
>>>ops)
>>>+{
>>>+       dev->ethtool_ops = ops;
>>>+}
>>
>>
>>It needs to be a macro for maximum flexibility.
> 
> 
> Nothing stops it being implemented as a macro in kcompat.  Having it as
> an inline function gives it argument typechecking which always gives me
> the warm fuzzies.

No, it _needs_ to be a macro for maximum flexibility.

Most importantly, kcompat code may use '#ifndef SET_ETHTOOL_OPS' as a 
trigger, to signal that compat code is needed.  No need for drivers to 
create tons of kernel-version-code ifdefs, just to test for when 
ethtool_ops appeared in 2.6, for when it starts appearing in 2.4 vendor 
backports, and (possibly) 2.4 itself.  Also, doing it at the cpp level 
allows compat code to #undef it, if it _really_ knows what its doing, 
and the situation calls for it.


>>Also, no need to convert in-kernel drivers over to using it...  Let 
>>driver authors use it or not as they choose.
> 
> 
> I took "Like pci_set_drvdata" as the most important part of your
> argument...  having everyone use it is no bad thing.

Certainly.  I have no real preferences either way, just noting that 
in-kernel drivers don't _need_ to use this macro.

	Jeff
