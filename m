From: Greg KH <gregkh@linuxfoundation.org>
Subject: Re: [RFC net-next 0/3] devconf: New infrastructure for setting
 pre-load parameters for a module
Date: Thu, 8 Jan 2015 08:46:18 -0800
Message-ID: <20150108164618.GA11696@kroah.com>
References: <1420730220-20224-1-git-send-email-hadarh@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Amir Vadai <amirv@mellanox.com>,
	Yevgeny Petrilin <yevgenyp@mellanox.com>,
	Or Gerlitz <ogerlitz@mellanox.com>, shannon.nelson@intel.com,
	Doug Ledford <dledford@redhat.com>, greearb@candelatech.com
To: Hadar Hen Zion <hadarh@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.linuxfoundation.org ([140.211.169.12]:42109 "EHLO
	mail.linuxfoundation.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754837AbbAHQqT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Jan 2015 11:46:19 -0500
Content-Disposition: inline
In-Reply-To: <1420730220-20224-1-git-send-email-hadarh@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jan 08, 2015 at 05:16:57PM +0200, Hadar Hen Zion wrote:
> Hi,
>     
> When configuring a device at an early boot stage, most kernel drivers
> use module parameters (the parameters' settings can be determined in
> modprobe.d config files).

Which is a bad idea, as you have learned :)

> These parameters are difficult to manage, and one of the reasons is that
> module parameters are set per driver and not per device (NICs using the
> same driver cannot be set with different configurations).
> Furthermore, using other existing configuration tools like ethtool,
> ifconfig, ip link commands or sysfs entries is not applicable, since
> they all rely on having a netdev already set up.
> 
> In the past, 'request_firmware' solution for configuration parameters
> was suggested by Shannon Nelson from Intel[1]. The idea was rejected by
> Greg KH, who claimed it was abusive of the request_firmware mechanism.
> Greg suggested using configfs for device configuration instead (as done
> by the USB gadget driver).
> 
> As a solution, we introduce a new kernel infrastructure using configfs
> to allow the configuration of the device. The goal is to set low-level
> device functionality that needs to be sorted out before a module is
> loaded.

Ick, really?  drivers should never need to be configured like this, if
so, then something is wrong, they should "just work" by default.  What
are you needing to "configure" that can't be determined by something
like a device tree?

greg k-h
