From: Adam Anthony <AAnthony@sbs.com>
Subject: RE: [PATCH] /driver/net/wan/sbs520
Date: Mon, 10 Jan 2005 13:49:55 -0700
Message-ID: <4F23E557A0317D45864097982DE907941A33AD@pilotmail.sbscorp.sbs.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Matthias-Christian Ott <matthias.christian@tiscali.de>,
        Alexey Dobriyan <adobriyan@mail.ru>, netdev@oss.sgi.com,
        linux-kernel@vger.kernel.org
Return-path: <netdev-bounce@oss.sgi.com>
To: Francois Romieu <romieu@fr.zoreil.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

	The SBS Communications group structured their software this way
(w/useless wrappers) to make files portable from one operating system to
another.  Now that this package will be taking a life of its own, the change
you propose makes perfect sense.
Thanks,
Adam

-----Original Message-----
From: Francois Romieu [mailto:romieu@fr.zoreil.com] 
Sent: Monday, January 10, 2005 3:30 PM
To: Adam Anthony
Cc: Matthias-Christian Ott; Alexey Dobriyan; netdev@oss.sgi.com;
linux-kernel@vger.kernel.org
Subject: Re: [PATCH] /driver/net/wan/sbs520

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

For limitations on the use and distribution of this message, please visit www.sbs.com/emaildisclaimer.
