From: "John W. Linville" <linville@tuxdriver.com>
Subject: Re: [PATCH 1/2] ipw2100: register pm_qos request on hardware
 activation
Date: Wed, 11 Aug 2010 16:22:23 -0400
Message-ID: <20100811202223.GA30437@tuxdriver.com>
References: <1281555063.4367.1.camel@lovely.krouter>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: James Bottomley <James.Bottomley@suse.de>,
	Zhu Yi <yi.zhu@intel.com>,
	"David S. Miller" <davem@davemloft.net>,
	Joe Perches <joe@perches.com>,
	"Rafael J. Wysocki" <rjw@sisk.pl>,
	linux-wireless <linux-wireless@vger.kernel.org>,
	netdev@vger.kernel.org,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Christoph Fritz <chf.fritz@googlemail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:32974 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756438Ab0HKU35 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Aug 2010 16:29:57 -0400
Content-Disposition: inline
In-Reply-To: <1281555063.4367.1.camel@lovely.krouter>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Aug 11, 2010 at 09:31:03PM +0200, Christoph Fritz wrote:
> Function pm_qos_add_request() has to be called before first
> pm_qos_update_request().  This was found out due to a change in pm_qos
> (commit 82f682514a5df89ffb3890627eebf0897b7a84ec "pm_qos: Get rid of
> the allocation in pm_qos_add_request()"). The warning call trace is below.
> 
> This patch is similar to c128ec29208d410568469bd8bb373b4cdc10912a "e1000e:
> register pm_qos request on hardware activation".
> 
> WARNING: at kernel/pm_qos_params.c:264 pm_qos_update_request+0x5e/0x70()
> pm_qos_update_request() called for unknown object
> Call Trace:
> [<c1024088>] ? warn_slowpath_common+0x78/0xb0
> [<c1041c9e>] ? pm_qos_update_request+0x5e/0x70
> [<c1041c9e>] ? pm_qos_update_request+0x5e/0x70
> [<c1024153>] ? warn_slowpath_fmt+0x33/0x40
> [<c1041c9e>] ? pm_qos_update_request+0x5e/0x70
> [<f89fe15f>] ? ipw2100_up+0x3f/0xf10 [ipw2100]
> [<c11961c9>] ? vsnprintf+0xc9/0x530
> [<f89ff36c>] ? ipw2100_net_init+0x2c/0x1c0 [ipw2100]
> [<c12f542d>] ? register_netdevice+0x7d/0x3c0
> [<f89f9b00>] ? ipw2100_irq_tasklet+0x910/0x9a0 [ipw2100]
> [<c12f579f>] ? register_netdev+0x2f/0x40
> [<f89fd471>] ? ipw2100_pci_init_one+0xd21/0x1060 [ipw2100]
> [<c11a5ebb>] ? local_pci_probe+0xb/0x10
> [<c11a6d49>] ? pci_device_probe+0x69/0x90
> [<c1224704>] ? driver_probe_device+0x74/0x180
> [<c10dd15a>] ? sysfs_create_dir+0x6a/0xb0
> [<c1224889>] ? __driver_attach+0x79/0x80
> [<c1224810>] ? __driver_attach+0x0/0x80
> [<c1223fa2>] ? bus_for_each_dev+0x52/0x80
> [<c1224586>] ? driver_attach+0x16/0x20
> [<c1224810>] ? __driver_attach+0x0/0x80
> [<c122395f>] ? bus_add_driver+0x17f/0x250
> [<c11a5ec0>] ? pci_device_shutdown+0x0/0x20
> [<c11a6c80>] ? pci_device_remove+0x0/0x40
> [<c1224b13>] ? driver_register+0x63/0x120
> [<c11a6f96>] ? __pci_register_driver+0x36/0xa0
> [<f84f9048>] ? ipw2100_init+0x48/0x67 [ipw2100]
> [<c1001122>] ? do_one_initcall+0x32/0x170
> [<c1087078>] ? __vunmap+0xb8/0xf0
> [<f84f9000>] ? ipw2100_init+0x0/0x67 [ipw2100]
> [<c10510c1>] ? sys_init_module+0x161/0x1000
> [<c108f847>] ? sys_close+0x67/0xe0
> [<c13647c1>] ? syscall_call+0x7/0xb
> 
> Signed-off-by: Christoph Fritz <chf.fritz@googlemail.com>

Thanks for identifying this problem!  However, I think there is a
simpler fix.  I'll include it in a follow-up email.  Could you verify
that it also addresses this issue?

John
-- 
John W. Linville		Someday the world will need a hero, and you
linville@tuxdriver.com			might be all we have.  Be ready.
