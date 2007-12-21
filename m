From: Randy Dunlap <randy.dunlap@oracle.com>
Subject: Re: [PATCH]  New driver "sfc" for Solarstorm SFC4000 controller -
 3nd try
Date: Fri, 21 Dec 2007 10:02:53 -0800
Message-ID: <20071221100253.fb5b0899.randy.dunlap@oracle.com>
References: <476BEF94.4000801@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com,
	spope@solarflare.com
To: Robert Stonehouse <rstonehouse@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from agminet01.oracle.com ([141.146.126.228]:55698 "EHLO
	agminet01.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752086AbXLUSEe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Dec 2007 13:04:34 -0500
In-Reply-To: <476BEF94.4000801@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 21 Dec 2007 16:53:40 +0000 Robert Stonehouse wrote:

> This is a resubmission of a new driver for Solarflare network controllers.
> 
> The driver supports several types of PHY (10Gbase-T, XFP, CX4) on six
> different 10G and 1G boards.
> 
> The previous thread was:
>   [PATCH] [RFC] New driver "sfc" for Solarstorm SFC4000 controller
>   http://marc.info/?l=linux-netdev&m=119757352830103&w=2
> 
> Thanks to the people who looked at the previous patches. We have addressed
> the following from received comments after the 2nd submission:
>   - Use kzalloc where appropriate
>   - Remove deprecated fastcall attributes
>   - Use kernel routines for hex dumps and MAC address printing
>   - Changes to logging MACROs
> 
> The last two patches were marked with RFC but I now think that this driver
> is ready (withstanding any further review comments) and I would like to ask
> that this driver is considered for merging.
> 
> 
> The patch (against net-2.6.25) is at:
>      https://support.solarflare.com/netdev/3/net-2.6.25-sfc-2.2.0029.patch

wow, 750+ KB

How many drivers is this?


> The new files may also be downloaded as a tarball:
>      https://support.solarflare.com/netdev/3/net-2.6.25-sfc-2.2.0029.tgz
> 
> And for verification there is:
>      https://support.solarflare.com/netdev/3/MD5SUMS


Hi,
I have just a few comments, mostly related to infrastructure.

a.  Don't use kernel-doc comment flags (i.e., "/**" to begin a comment
block) when the comment is not in kernel-doc format.  Or use
kernel-doc format.  :)
(as documented in Documentation/kernel-doc-nano-HOWTO.txt)

E.g.:
+/** @file
+ *
+ * Efx driverlink
+ *
+ * This header file defines the portions of the Efx driverlink
+ * interface that are used only by the kernel net driver, and are not
+ * part of the public interface specification.
+ */

b.  Kconfig file:

Use 1 tab (not 8 spaces) to indent below "config" items.
Use 1 tab + 2 spaces to indent help text below "help" lines.


c.  Driver contains MTD, SPI, & I2C (at least) code and needs to be
reviewed by people in those areas as well (IMO).

I see an MTD dependency in the Kconfig file.
What about the SPI and I2C parts?  Are they conditional or
how is that handled?  or does the driver not use the kernel
infrastructure for these?


---
~Randy
