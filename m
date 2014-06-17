From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: Device Tree Binding for Marvell DSA on P1023RDB
Date: Tue, 17 Jun 2014 16:44:26 -0700
Message-ID: <CAGVrzcZDXA6OG-gjhR7N3ZU4EkprTJV+pj77t=JEOsuKWavhsg@mail.gmail.com>
References: <539F1B3F.6060203@xsmail.com> <539F1B8E.30503@xsmail.com>
 <CAGVrzcbxBE0yk5J1Pvkz5Yx+ugHTBjRSTLsvN9NACt20vjmgjw@mail.gmail.com>
 <539FE2FC.4020105@xsmail.com> <CAGVrzcY-khbCM3rB5qsNSq2Y+ekeH-4RyW-A-3+Di1MUVhXy4w@mail.gmail.com>
 <53A0D1C2.4080305@xsmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
To: Pannirselvam Kanagaratnam <pannir@xsmail.com>,
	netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oa0-f53.google.com ([209.85.219.53]:49263 "EHLO
	mail-oa0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756324AbaFQXpH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Jun 2014 19:45:07 -0400
Received: by mail-oa0-f53.google.com with SMTP id l6so171306oag.12
        for <netdev@vger.kernel.org>; Tue, 17 Jun 2014 16:45:06 -0700 (PDT)
In-Reply-To: <53A0D1C2.4080305@xsmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2014-06-17 16:39 GMT-07:00 Pannirselvam Kanagaratnam <pannir@xsmail.com>:
>
> On 18/06/2014 12:44 AM, Florian Fainelli wrote:
>>
>> On Jun 16, 2014 11:41 PM, "Pannirselvam Kanagaratnam" <pannir@xsmail.com>
>> wrote:
>>>
>>>
>>> The error is coming from:
>>>
>>> dev = dev_to_net_device(pd->netdev);
>>> if (dev == NULL) {
>>>                  ret = -EINVAL;
>>>                  goto out;
>>>          }
>>
>> Ok, I could not find which Freescale Ethernet driver you are using,
>> but my guess is that we cannot look up the struct net_device that is
>> associated with the struct platform_device of your network driver,
>> most likely because the network driver failed to call
>> SET_NETDEV_DEV(). Also, if your Ethernet driver is modular, that might
>> be a problem if it get probed after DSA.
>>
>
> The Freescale Ethernet Driver is from SDK. The driver code can be viewed
> here:
> https://lists.ubuntu.com/archives/kernel-team/2012-June/020687.html
>
> This is my startup log. Looks like dsa is probed after ethernet:

Yes, so you should be good. You should investigate why dev_to_net()
does not work with your specific out of tree Ethernet driver. On all
drivers that I have tested: mv643xx_eth, mvneta and bcmsysport which
are all in the kernel, I had no problems, most likely something is not
done correctly by this out of tree driver, but that is beyond the
scope of the dsa code for now.

>
> libphy: Fixed MDIO Bus: probed
> libphy: Freescale PowerQUICC MII Bus: probed
>  FMAN(0) Fifo size settings:
>   - Total buffers available(192 - 256B/buffer)
>   - Total throughput(2Gbps)
>   - Max frame size(1522B)
>   - 1G ports TX 2(12 bufs set (min: 12))
>   - 1G ports RX 2(68 bufs set (min: 8))
>   - OH-HC ports 4(8)
>   - Shared extra buffers(0)
>  FMAN(0) open dma settings:
>   - Total open dma available(16)
>   - 1G ports TX 2(3)
>   - 1G ports RX 2(3)
>   - OH-HC ports 4(1)
>   - Shared extra open dma(0)
>  FMAN(0) Tnums settings:
>   - Total Tnums available(64)
>   - 1G ports TX 2(13)
>   - 1G ports RX 2(14)
>   - OH-HC ports 4(2)
>   - Shared extra tnums(2)
> Freescale FM module (Jun 16 2014:02:20:25), FMD API version 21.1.0
> Freescale FM Ports module (Jun 16 2014:02:20:27)
> dpaa_debugfs: FSL DPAA Ethernet debugfs entries ()
> fsl_mac: mac.c:416:mac_load() fsl_mac: FSL FMan MAC API based driver ()
> fsl_mac ff7e0000.ethernet: FMan dTSEC version: 0x08240101
> fsl_mac ff7e0000.ethernet: FMan MAC address: 00:22:33:44:55:44
> fsl_mac ff7e2000.ethernet: FMan dTSEC version: 0x08240101
> fsl_mac ff7e2000.ethernet: FMan MAC address: 00:22:33:44:55:45
> fsl_dpa: FSL DPAA Ethernet driver ()
> fsl_dpa: Probed interface eth0
> fsl_dpa: Probed interface eth1
> fsl_dpa_shared: FSL DPAA Shared Ethernet driver ()
> fsl_dpa_proxy: FSL DPAA Proxy initialization driver ()
> fsl_oh: FSL FMan Offline Parsing port driver ()
> e1000e: Intel(R) PRO/1000 Network Driver - 2.1.4-k
> e1000e: Copyright(c) 1999 - 2012 Intel Corporation.
> PPP generic driver version 2.4.2
> NET: Registered protocol family 24
> ehci_hcd: USB 2.0 'Enhanced' Host Controller (EHCI) Driver
> ehci-pci: EHCI PCI platform driver
> fsl-ehci fsl-ehci.0: Freescale On-Chip EHCI Host Controller
> fsl-ehci fsl-ehci.0: new USB bus registered, assigned bus number 1
> fsl-ehci fsl-ehci.0: irq 28, io mem 0xff622000
> fsl-ehci fsl-ehci.0: USB 2.0 started, EHCI 1.00
> hub 1-0:1.0: USB hub found
> hub 1-0:1.0: 1 port detected
> Initializing USB Mass Storage driver...
> usbcore: registered new interface driver usb-storage
> USB Mass Storage support registered.
> i2c /dev entries driver
> mpc-i2c ff603000.i2c: timeout 1000000 us
> at24 0-0053: 512 byte 24c04 EEPROM, writable, 1 bytes/write
> usb 1-1: new high-speed USB device number 2 using fsl-ehci
> hub 1-1:1.0: USB hub found
> hub 1-1:1.0: 4 ports detected
> rtc-ds1307: probe of 0-006f failed with error -5
> mpc-i2c ff603100.i2c: timeout 1000000 us
> EDAC MC: Ver: 3.0.0
> platform caam_qi.0: Linux CAAM Queue I/F driver initialised
> caam ff630000.crypto: device ID = 0x0a12010100000000 (Era 3)
> caam ff630000.crypto: job rings = 4, qi = 1
> caam ff630000.crypto: tls10-hmac-sha1-cbc-aes-caam needs Era 4 or higher but
> SEC is Era 3, skipping it
> caam ff630000.crypto: fsl,sec-v4.2 algorithms registered in /proc/crypto
> platform ff631000.jr: registering rng-caam
> platform caam_qi.0: fsl,sec-v4.2 algorithms registered in /proc/crypto
> caam ff630000.crypto: fsl,sec-v4.2 algorithms registered in /proc/crypto
> usbcore: registered new interface driver usbhid
> usbhid: USB HID core driver
> Freescale USDPAA process driver
> fsl-usdpaa: no region found
> Freescale USDPAA process IRQ driver
> u32 classifier
> nf_conntrack version 0.5.0 (7137 buckets, 28548 max)
> IPv4 over IPv4 tunneling driver
> ip_tables: (C) 2000-2006 Netfilter Core Team
> TCP: cubic registered
> Initializing XFRM netlink socket
> NET: Registered protocol family 10
> ip6_tables: (C) 2000-2006 Netfilter Core Team
> sit: IPv6 over IPv4 tunneling driver
> NET: Registered protocol family 17
> NET: Registered protocol family 15
>
> Distributed Switch Architecture driver version 0.1
> dsa: probe of dsa.16 failed with error -22
> 8021q: 802.1Q VLAN Support v1.8
> Key type dns_resolver registered
> fsl_dpa_macless: FSL DPAA MACless Ethernet driver ()
> drivers/rtc/hctosys.c: unable to open rtc device (rtc0)
> ALSA device list:
>   No soundcards found.
> RAMDISK: gzip image found at block 0
> VFS: Mounted root (ext2 filesystem) on device 1:0.
> devtmpfs: mounted
> Freeing unused kernel memory: 248k freed
> INIT: version 2.88 booting
> Starting udev
> udevd[1332]: starting version 182
> Starting Bootlog daemon: bootlogd.
> Configuring network interfaces... done.
> hwclock: can't open '/dev/misc/rtc': No such file or directory
> Sun Jun 15 23:41:00 UTC 2014
> hwclock: can't open '/dev/misc/rtc': No such file or directory
> Running postinst /etc/rpm-postinsts/sysvinit-inittab...
> INIT: Entering runlevel: 5
> hwclock: can't open '/dev/misc/rtc': No such file or directory
> Starting syslogd/klogd: done
> Stopping Bootlog daemon: bootlogd.
>
> Poky 9.0 (Yocto Project 1.4 Reference Distro) 1.4.1 p1023 ttyS0
>
>
>



-- 
Florian
