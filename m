From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH V2 net-next 01/21] net-next/hinic: Initialize hw interface
Date: Tue, 25 Jul 2017 22:02:05 +0200
Message-ID: <20170725200205.GA984@electric-eye.fr.zoreil.com>
References: <cover.1500454998.git.aviad.krawczyk@huawei.com>
 <0febc61414e7908a7c8c0c2fa7c2b06b0f7524f7.1500454998.git.aviad.krawczyk@huawei.com>
 <20170719222740.GA1755@electric-eye.fr.zoreil.com>
 <33fbbf34-cdbe-81a8-dc33-2cd6cb6cf4ee@huawei.com>
 <20170724230318.GA26260@electric-eye.fr.zoreil.com>
 <01800b7a-c11d-980f-0e5e-d4684eaa0f2a@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, linux-kernel@vger.kernel.org,
        netdev@vger.kernel.org, bc.y@huawei.com, victor.gissin@huawei.com,
        zhaochen6@huawei.com, tony.qu@huawei.com
To: Aviad Krawczyk <aviad.krawczyk@huawei.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <01800b7a-c11d-980f-0e5e-d4684eaa0f2a@huawei.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Aviad Krawczyk <aviad.krawczyk@huawei.com> :
[...]
> module_pci_driver - is not used in other drivers in the same segments, it
> is necessary ?

/me checks... Ok, there seems to be some overenthusiastic copy'paste.

See drivers/net/ethernet/intel/ixgb/ixgb_main.c:
[...]
/**
 * ixgb_init_module - Driver Registration Routine
 *
 * ixgb_init_module is the first routine called when the driver is
 * loaded. All it does is register with the PCI subsystem.
 **/

static int __init
ixgb_init_module(void)
{
	pr_info("%s - version %s\n", ixgb_driver_string, ixgb_driver_version);
	pr_info("%s\n", ixgb_copyright);

	return pci_register_driver(&ixgb_driver);
}

module_init(ixgb_init_module);

/**
 * ixgb_exit_module - Driver Exit Cleanup Routine
 *
 * ixgb_exit_module is called just before the driver is removed
 * from memory.
 **/

static void __exit
ixgb_exit_module(void)
{
	pci_unregister_driver(&ixgb_driver);
}

module_exit(ixgb_exit_module);

Driver version ought to be fed through ethtool, if ever. Copyright message
mildly contributes to a better world. So the whole stuff above could be:

module_pci_driver(ixgb_driver);

-- 
Ueimor
