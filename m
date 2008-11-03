From: "Alexander Beregalov" <a.beregalov@gmail.com>
Subject: Re: e100/netconsole: Failed to load firmware (Re:
	linux-next: Tree for November 3)
Date: Mon, 3 Nov 2008 18:49:58 +0300
Message-ID: <a4423d670811030749l53098b34i21af579c13ba112e@mail.gmail.com>
References: <a4423d670811030425y1bdf93fcn829b7311e38731b9@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Netdev <netdev@vger.kernel.org>, linux-next@vger.kernel.org
To: e1000-devel@lists.sourceforge.net, jaswinder@infradead.org,
	"David Woodhouse" <dwmw2@infradead.org>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <a4423d670811030425y1bdf93fcn829b7311e38731b9@mail.gmail.com>
Content-Disposition: inline
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

2008/11/3 Alexander Beregalov <a.beregalov@gmail.com>:
> Hi
>
> 2.6.28-rc3-next-20081103 on sparc64
>
> netconsole on e100 does not work
>
> pci 0000:02:01.0: supports D1 D2
> pci 0000:02:01.0: PME# supported from D0 D1 D2 D3hot
> pci 0000:02:01.0: PME# disabled
> device: '0000:02:01.0': device_add
> bus: 'pci': add device 0000:02:01.0
> pci 0000:02:01.0: calling quirk_e100_interrupt+0x0/0x1e4
> pci 0000:02:01.0: calling quirk_cardbus_legacy+0x0/0x40
> pci 0000:02:01.0: calling quirk_usb_early_handoff+0x0/0x42c
> <...>
> e100: Intel(R) PRO/100 Network Driver, 3.5.23-k4-NAPI
> e100: Copyright(c) 1999-2006 Intel Corporation
> bus: 'pci': add driver e100
> bus: 'pci': driver_probe_device: matched device 0000:02:01.0 with driver e100
> bus: 'pci': really_probe: probing driver e100 with device 0000:02:01.0
> PCI: Enabling device: (0000:02:01.0), cmd 3
> e100 0000:02:01.0: enabling bus mastering
> e100 0000:02:01.0: PME# disabled
> device: 'eth1': device_add
> e100: eth1: e100_probe: addr 0x1ff00002000, irq 15, MAC addr 00:d0:b7:e4:d6:f1
> driver: '0000:02:01.0': driver_bound: bound to device 'e100'
> bus: 'pci': really_probe: bound device 0000:02:01.0 to driver e100
> netconsole: local port 6665
> netconsole: local IP 192.168.1.5
> netconsole: interface eth1
> netconsole: remote port 6667
> netconsole: remote IP 192.168.1.3
> netconsole: remote ethernet address 00:08:c7:da:88:fb
> netconsole: device eth1 not up yet, forcing it
> e100 0000:02:01.0: firmware: requesting e100/d101m_ucode.bin
> device: '0000:02:01.0': device_add

60 seconds delay here

> device: '0000:02:01.0': device_unregister
> e100: eth1: e100_request_firmware: Failed to load firmware
> "e100/d101m_ucode.bin": -2
> netconsole: failed to open eth1
> netconsole: cleaning up
> <...>
> e100 0000:02:01.0: firmware: requesting e100/d101m_ucode.bin
> device: '0000:02:01.0': device_add
> device: '0000:02:01.0': device_unregister
> e100: eth1: e100_watchdog: link up, 100Mbps, full-duplex

drivers/base/firmware_class.c:
_request_firmware():

mutex_lock(&fw_lock);
if (!fw_priv->fw->size || test_bit(FW_STATUS_ABORT, &fw_priv->status)) {
        retval = -ENOENT;
        release_firmware(fw_priv->fw);
        *firmware_p = NULL;
}
fw_priv->fw = NULL;
mutex_unlock(&fw_lock);
device_unregister(f_dev);
goto out;


fw_priv->fw->size is 0 at the first time
At the second time it is 539

-------------------------------------------------------------------------
This SF.Net email is sponsored by the Moblin Your Move Developer's challenge
Build the coolest Linux based applications with Moblin SDK & win great prizes
Grand prize is a trip for two to an Open Source event anywhere in the world
http://moblin-contest.org/redirect.php?banner_id=100&url=/
