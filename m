From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH] /driver/net/wan/sbs520
Date: Mon, 10 Jan 2005 21:29:47 +0100
Message-ID: <20050110202947.GA31426@electric-eye.fr.zoreil.com>
References: <4F23E557A0317D45864097982DE907941A3383@pilotmail.sbscorp.sbs.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Matthias-Christian Ott <matthias.christian@tiscali.de>,
        Alexey Dobriyan <adobriyan@mail.ru>, netdev@oss.sgi.com,
        linux-kernel@vger.kernel.org
Return-path: <netdev-bounce@oss.sgi.com>
To: Adam Anthony <AAnthony@sbs.com>
Content-Disposition: inline
In-Reply-To: <4F23E557A0317D45864097982DE907941A3383@pilotmail.sbscorp.sbs.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Adam Anthony <AAnthony@sbs.com> :
> Thank you for the heads up A&M.  I have destroyed the evil [^M]'s, and
> updated the package.
> http://prdownloads.sourceforge.net/sbs520lnxdrv/sbs520patch.bz2?download

o OsMapPhysToVirt
  -> should be ioremap/pci_iomap()

o OsUnMapVirt
  -> iounmap, etc.

o OsAllocateNonPagedMemory/OsMemcpy/OsStall/OsSleep/OsZeroMem
  -> useless wrappers.

o OsAllocateDeviceMemory
  Yuck, virt_to_bus !
  Please read:
  - linux-2.6.x/Documentation/DMA-mapping.txt
  - linux-2.6.x/Documentation/DMA-API.txt
  drivers/net/*.c provides a lot of good examples for recent PCI
  devices.

o OsReadPciConfiguration
  Please see pci_resource_{start/len} and friends.

At this point, lnxosl.c will be removable and nobody will regret it.

--
Ueimor
