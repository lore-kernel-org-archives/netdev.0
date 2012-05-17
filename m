From: Ming Lei <tom.leiming@gmail.com>
Subject: Re: [PATCH 1/1] smsc95xx: add FLAG_POINTTOPOINT flag for driver_info
Date: Thu, 17 May 2012 16:20:47 +0800
Message-ID: <CACVXFVPLf9+8qQKgkikexq3ao=b9fM4jOCasMWVJrbZEVSj_Tg@mail.gmail.com>
References: <1337155302-26244-1-git-send-email-jgq516@gmail.com>
	<CACVXFVNzmq74BKYZN1SpXYULneV2ASmniMhs4LhevPm-XgSJpg@mail.gmail.com>
	<4FB4613B.3020603@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: steve.glendinning@smsc.com, gregkh@linuxfoundation.org,
	netdev@vger.kernel.org, linux-usb@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Xiao Jiang <jgq516@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pz0-f46.google.com ([209.85.210.46]:45585 "EHLO
	mail-pz0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753698Ab2EQIUs convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 May 2012 04:20:48 -0400
In-Reply-To: <4FB4613B.3020603@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, May 17, 2012 at 10:23 AM, Xiao Jiang <jgq516@gmail.com> wrote:
> Ming Lei wrote:
>>
>> On Wed, May 16, 2012 at 4:01 PM, =A0<jgq516@gmail.com> wrote:
>>
>>>
>>> From: Xiao Jiang <jgq516@gmail.com>
>>>
>>> commit c26134 introduced FLAG_POINTTOPOINT flag for USB ethernet de=
vices
>>> which possibly use "usb%d" names, add this flag to make sure pandab=
oard
>>> can mount nfs with smsc95xx NIC.
>>>
>>
>>
>> Without the flag, I also can mount nfs successfully on my Pandaboard=
=2E..

I always mount nfs in console, and not tried to mount nfs as root fs.

>>
>>
>
> I have pulled latest tree
> (git://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git
> commit 0e93b4b304ae052ba1bc73f6d34a68556fe93429), and enable related =
options
> (USB_NET_SMSC95XX,
> USB_EHCI_HCD and USB_EHCI_HCD_OMAP) with omap2plus_config, However th=
e
> kernel still can't mount
> nfs, pls see below infos.
>
> [ =A0 =A03.114105] smsc95xx v1.0.4
> [ =A0 =A04.533752] smsc95xx 1-1.1:1.0: *eth0*: register 'smsc95xx' at
> usb-ehci-omap.0-1.1, smsc95xx USB 2.0 Ethernet, fe:b9:1b:07:8e:d1
> [ =A0108.854217] VFS: Unable to mount root fs via NFS, trying floppy.
> [ =A0108.861114] VFS: Cannot open root device "nfs" or unknown-block(=
2,0):
> error -6
> [ =A0108.868713] Please append a correct "root=3D" boot option; here =
are the
> available partitions:
> [ =A0108.877655] b300 =A0 =A0 =A0 =A0 7761920 mmcblk0 =A0driver: mmcb=
lk
> [ =A0108.883239] =A0 b301 =A0 =A0 =A0 =A0 =A0 40131 mmcblk0p1
> 00000000-0000-0000-0000-000000000mmcblk0p1
> [ =A0108.891662] =A0 b302 =A0 =A0 =A0 =A0 7719232 mmcblk0p2
> 00000000-0000-0000-0000-000000000mmcblk0p2
> [ =A0108.900146] Kernel panic - not syncing: VFS: Unable to mount roo=
t fs on
> unknown-block(2,0)
>
> BTW: I tested it with OMAP4430 ES2.2 pandaboard, the issue can be sol=
ved
> with apply the patch.
>
> Is there something which I missed? thanks.

What is your kernel parameter? Maybe you use 'usb%d' in kernel paramete=
r for
mounting nfs as root fs. If so, could you try 'eth%d' in kernel cmd?

In fact, smsc95xx is a real LAN interface, and 'eth%d' should be prefer=
ed name
as described in changelog of commit
c261344d3ce3edac781f9d3c7eabe2e96d8e8fe8(usbnet:use eth%d name for
known ethernet devices)


Thanks,
--=20
Ming Lei
