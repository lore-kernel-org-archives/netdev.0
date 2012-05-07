From: Dan Williams <dcbw@redhat.com>
Subject: Re: [PATCH] mwl8k: Add 0x2a02 PCI device-id (Marvell 88W8361)
Date: Mon, 07 May 2012 11:09:04 -0500
Message-ID: <1336406944.2385.24.camel@dcbw.foobar.com>
References: <20120427094637.GV3157@wantstofly.org>
	 <CA+icZUXNZ=exTnR=OgD_9bpt_0s-KnR+v-K6u+XzQr4HBoTQHQ@mail.gmail.com>
	 <20120427095842.GW3157@wantstofly.org>
	 <CA+icZUWuynSaPE4pdxzoP783pw7r=5x27ewXN_pkR5VS=0kKUg@mail.gmail.com>
	 <20120427101732.GX3157@wantstofly.org>
	 <CA+icZUUnJPeDmL9xXfvj62an40bXwwaOnrJmxmLN_cBt9PyCZA@mail.gmail.com>
	 <CA+icZUV76wSBj88EpzmWbO=u2dP23yi5P98nN2KZehBUni9mEg@mail.gmail.com>
	 <20120427185809.GZ3157@wantstofly.org>
	 <CA+icZUWQmCRdjucb4+Nf24_zbJ4fzzp7zjqhKjXE6U01rppDfA@mail.gmail.com>
	 <CA+icZUXSaEMA=KbQP9UQcU6ZMBh8QD2sv-O=6r_Ly8is==gvSA@mail.gmail.com>
	 <20120501125102.GN3157@wantstofly.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: sedat.dilek@gmail.com, "John W. Linville" <linville@tuxdriver.com>,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, lautriv <admin@coldplug.net>,
	Jim Cromie <jim.cromie@gmail.com>
To: Lennert Buytenhek <buytenh@wantstofly.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20120501125102.GN3157@wantstofly.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2012-05-01 at 14:51 +0200, Lennert Buytenhek wrote:
> On Sun, Apr 29, 2012 at 12:25:21AM +0200, Sedat Dilek wrote:
> 
> > > On 1st sight, logs look fine:
> > >
> > > [21:52:52] <lautriv> [    6.050967] ieee80211 phy0: 88w8361p v4,
> > > 00173f3bdde3, STA firmware 2.1.4.25
> > >
> > > But WLAN connection is not that fast and stable as lautriv reports
> > > (several abnormalities were observed).
> > >
> > > I requested a tarball which includes:
> > > * dmesg (Linux-3.3.3)
> > > * e_n_a (/etc/network/interfaces)
> > > * ifconfig output
> > > * iwconfig output
> > > * iw_phy output
> > > * ps_axu (WPA) output
> > >
> > > lautriv will be so kind to be around on #linux-wireless/Freenode the
> > > next days (UTC+2: German/Swiss local-time).
> > > Just ping him.
> > >
> > > Hope you have fun, together!
> > >
> > > - Sedat -
> > 
> > A new tarball from lautriv with same outputs as before, but now tested
> > with Linux-3.4-rc4.
> 
> The output looks good enough for me to ACK adding the PCI ID.
> 
> Can the firmware being used here be submitted to the linux-firmware
> git tree?

So Marvell sent John a driver for TopDog a long time ago, which he put
up on kernel.org.  That driver was reworked by Louis and put up in a git
tree, but both were lost to the kernel.org hack.  I have git backups of
both git trees.  I put Louis' cleanup here:

http://people.redhat.com/dcbw/mrvl_cb82.tar.bz2

That driver (mrvl_cb82) has the following PCI IDs:

static const struct pci_device_id mwl_id_tbl[] __devinitdata = {
        { PCI_VDEVICE(MARVELL, 0x2a02), 0 },
        { PCI_VDEVICE(MARVELL, 0x2a03), 1 },
        { PCI_VDEVICE(MARVELL, 0x2a06), 2 },
        { PCI_VDEVICE(MARVELL, 0x2a07), 3 },
        { PCI_VDEVICE(MARVELL, 0x2a04), 4 },
        { PCI_VDEVICE(MARVELL, 0x2a08), 5 },
        { PCI_VDEVICE(MARVELL, 0x2a0a), 6 },
        { PCI_VDEVICE(MARVELL, 0x2a0b), 7 },
        { PCI_VDEVICE(MARVELL, 0x2a0c), 8 },
        { 0 }
};

and supposedly works for CB82 + CB85.  The firmware helper for CB82
looks pretty close to the mwl8k one.

The firmware API exposed by mrvl_cb82 looks very close to mwl8k
actually.  I only checked the HostCmd bits, not the structures, so I
would expect a few differences.  There are some commands that mwl8k
exposes that mrvl_cb82 does not and vice versa, but I'm not sure if the
drivers actually use those commands.

Hope this helps.

Dan
