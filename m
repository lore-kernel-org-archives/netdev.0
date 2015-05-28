From: Amir Vadai <amirv@mellanox.com>
Subject: Re: [PATCH net-next V4 00/12] net/mlx5: ConnectX-4 100G Ethernet driver
Date: Thu, 28 May 2015 12:23:36 +0300
Message-ID: <CAPcc5Pi1YfJBhZ4C9=xN8MrvL+qfddV7PLpZ=GfFa6hbmgCFsQ@mail.gmail.com>
References: <CAJ3xEMiteyRsGuNQoQYiiZKeWkpjQE8WcJdQfWyxntJ9bjYXcw@mail.gmail.com>
	<20150527.133620.1867770619067144773.davem@davemloft.net>
	<1432756657.6319.22.camel@decadent.org.uk>
	<20150528.015232.1205990019180315319.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Ben Hutchings <ben@decadent.org.uk>,
	Or Gerlitz <gerlitz.or@gmail.com>,
	netdev <netdev@vger.kernel.org>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Tal Alon <talal@mellanox.com>,
	Achiad Shochat <achiad@mellanox.com>,
	Saeed Mahameed <saeedm@mellanox.com>,
	Amir Vadai <amirv@mellanox.com>,
	Eric Dumazet <edumazet@google.com>, <tom@herbertland.com>,
	<jiri@resnulli.us>, Benjamin Poirier <bpoirier@suse.de>
To: David Miller <davem@davemloft.net>,
	Neil Horman <nhorman@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-db3on0055.outbound.protection.outlook.com ([157.55.234.55]:51776
	"EHLO emea01-db3-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751529AbbE1JXs (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 28 May 2015 05:23:48 -0400
Received: by laat2 with SMTP id t2so26899672laa.1
        for <netdev@vger.kernel.org>; Thu, 28 May 2015 02:23:36 -0700 (PDT)
In-Reply-To: <20150528.015232.1205990019180315319.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, May 28, 2015 at 11:52 AM, David Miller <davem@davemloft.net> wrote:
> From: Ben Hutchings <ben@decadent.org.uk>
> Date: Wed, 27 May 2015 20:57:37 +0100
>
>> How would an application tell the difference between an IRQ handler
>> being renamed, or being unregistered and re-registered under a different
>> name?  I'm fairly sure it can't tell.
>
> What do things like the userland IRQ balancer do?

Thanks to Neil Horman, userland scripts can get the irq number from
sysfs (/sys/bus/pci/devices/<device>/msi_irqs) which is not based on
the irq naming [1].
He also fixed irq_balancer [2] to use this API instead of being based
on those strings.

I will drop the irq renaming from the patchset. mlx5_core driver will
set generic irq names (since same irq's might service both Ethernet
and Infiniband), for example: mlx5_comp0@pci:0000:00:04.0.

Thanks,
Amir


[1] - kernel: da8d1c8 PCI/sysfs: add per pci device msi[x] irq listing (v5)
[2] - irq_balancer: 32a7757 Complete rework of how we detect and classify irqs
