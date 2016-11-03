From: Hayes Wang <hayeswang@realtek.com>
Subject: RE: [PATCH net] r8152: Fix broken RX checksums.
Date: Thu, 3 Nov 2016 08:56:30 +0000
Message-ID: <0835B3720019904CB8F7AA43166CEEB20104878A@RTITMBSV03.realtek.com.tw>
References: <9fb6be7b-95f3-6e59-c0f4-1d6c3357416d@pobox.com>
 <20161030.205755.1198665157526465556.davem@davemloft.net>
 <1f847ae0-4928-01e7-f1e7-3cbc37529961@pobox.com>
 <20161030.235342.134481656830778556.davem@davemloft.net>
 <0835B3720019904CB8F7AA43166CEEB201047353@RTITMBSV03.realtek.com.tw>
 <201611030159.uA31x0np004648@rtits1.realtek.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: nic_swsd <nic_swsd@realtek.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Mark Lord <mlord@pobox.com>, David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <201611030159.uA31x0np004648@rtits1.realtek.com>
Content-Language: zh-TW
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Mark Lord [mailto:mlord@pobox.com]
> Sent: Thursday, November 03, 2016 2:30 AM
> To: Hayes Wang; David Miller
[...]
> I have poked at it some more, and thus far it appears that it is
> only necessary to disable TCP rx checksums.  The system doesn't crash
> when only IP/UDP checksums are enabled, but does when TCP checksums are on.
> 
> This happens regardless of whether RX_AGG is disabled or enabled,
> and increasing/decreasing the number of RX URBs (RTL8152_MAX_RX)
> doesn't seem to affect it.

I test Raspberry Pi v1, but I couldn't boot with NFSROOT through
both onboard nic and RTL8152. I get following error.

   VFS: Unable to mount root fs via NFS, trying floppy.
   Kernel panic - not syncing: VFS: Unable to mount root fs on unknown-block(2,0)

However, if I start the system without NFSROOT, I could mount the nfs fs.
Any idea?

NFS server: Fedora 24
Raspberry Pi OS: 2016-09-23-raspbian-jessie

Content of /etc/exports:

   /nfsexport *(rw,sync,no_root_squash)

I change the cmdline.txt from

   dwc_otg.lpm_enable=0 console=serial0,115200 console=tty1
   root=/dev/mmcblk0p2 rootfstype=ext4 elevator=deadline
   fsck.repair=yes rootwait quiet splash plymouth.ignore-serial-consoles

to

   dwc_otg.lpm_enable=0 console=serial0,115200 console=tty1
   root=/dev/nfs nfsroot=192.168.94.2:/nfsexport ip=192.168.94.22
   rw rootwait quiet splash plymouth.ignore-serial-consoles

Best Regards,
Hayes
