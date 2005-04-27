From: Ismail Donmez <ismail@kde.org.tr>
Subject: Re: [KJ] [PATCH] Documentation/networking/dmfe.txt : Make documentation nicer
Date: Wed, 27 Apr 2005 20:26:28 +0300
Message-ID: <200504272026.29047.ismail@kde.org.tr>
References: <200504262244.01258.ismail@kde.org.tr> <20050427170703.GA3762@nd47.coderock.org>
Mime-Version: 1.0
Content-Type: Multipart/Mixed;
  boundary="Boundary-00=_Ft8bCp6v85r2St9"
Cc: ismail@kde.org.tr
Return-path: <netdev-bounce@oss.sgi.com>
To: kernel-janitors@lists.osdl.org, netdev@oss.sgi.com, jgarzik@pobox.com
In-Reply-To: <20050427170703.GA3762@nd47.coderock.org>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

--Boundary-00=_Ft8bCp6v85r2St9
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable
X-MIME-Autoconverted: from 8bit to quoted-printable by oss.sgi.com id j3RHSp1O026705

On Wednesday 27 April 2005 20:07, Domen Puncer wrote:
> On 26/04/05 22:44 +0300, Ismail Donmez wrote:
> > Hi,
> >
> > attached patch indents dmfe.txt to look like other docs. It adds a ti=
p
> > about CNET cards using Davicom chipsets. Also it removes parts where =
it
> > refers to how to build driver out-of-kernel which seems to be cruft f=
rom
> > times where the driver was out of the kernel.
>
> Please, no quoted-printable, it makes it hard for scripts to parse righ=
t.
> (=3D20 and similar "characters")

Ok hopefully its ok now

>
> > Signed-off-by: ??smail D=F6nmez <ismail@kde.org.tr>
>

Ok my unicode name is buggy ;)

> Uhh... I don't recall being discussed in which encoding this should be,
> ascii is a safe bet.
>
> > --- dmfe.txt	2004-07-24 09:45:13.000000000 +0300
> > +++ dmfe2.txt	2004-07-24 09:46:37.000000000 +0300
>
> Patch should be -p1 appliable... meaning these lines will be something
> like: --- linux-2.6.12-rc3/Documentation/dmfe.txt ...
> +++ linux-dev/Documentation/dmfe.txt ...
>
> > @@ -1,59 +1,65 @@
> > -  dmfe.c: Version 1.28        01/18/2000
> > +Davicom DM9102(A)/DM9132/DM9801 fast ethernet driver for Linux.
>
> Trailing whitespace.

Nice catch.

Here goes the new one :


Attached patch indents dmfe.txt to look like other docs. It adds a tip
about CNET cards using Davicom chipsets. Also it removes parts where it
refers to how to build driver out-of-kernel which seems to be cruft from
times where the driver was out of the kernel.

Signed-off-by: Ismail D=F6nmez <ismail@kde.org.tr>

--Boundary-00=_Ft8bCp6v85r2St9
Content-Type: text/x-diff;
  charset="Iso-8859-1";
  name="dmfe.patch"
Content-Disposition: attachment;
	filename="dmfe.patch"
Content-Transfer-Encoding: 7bit

--- linux-2.6.12/Documentation/networking/dmfe.txt	2005-04-27 20:13:04.000000000 +0300
+++ linux-2.6.12/Documentation/networking/dmfe2.txt	2005-04-27 20:22:35.000000000 +0300
@@ -1,59 +1,65 @@
-  dmfe.c: Version 1.28        01/18/2000
+Davicom DM9102(A)/DM9132/DM9801 fast ethernet driver for Linux.
 
-        A Davicom DM9102(A)/DM9132/DM9801 fast ethernet driver for Linux. 
-        Copyright (C) 1997  Sten Wang
+This program is free software; you can redistribute it and/or
+modify it under the terms of the GNU General   Public License
+as published by the Free Software Foundation; either version 2
+of the License, or (at your option) any later version.
 
-        This program is free software; you can redistribute it and/or
-        modify it under the terms of the GNU General Public License
-        as published by the Free Software Foundation; either version 2
-        of the License, or (at your option) any later version.
+This program is distributed in the hope that it will be useful,
+but WITHOUT ANY WARRANTY; without even the implied warranty of
+MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
+GNU General Public License for more details.
 
-        This program is distributed in the hope that it will be useful,
-        but WITHOUT ANY WARRANTY; without even the implied warranty of
-        MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
-        GNU General Public License for more details.
 
+This driver provides kernel support for Davicom DM9102(A)/DM9132/DM9801 ethernet cards ( CNET
+10/100 ethernet cards uses Davicom chipset too, so this driver supports CNET cards too ).If you
+didn't compile this driver as a module, it will automatically load itself on boot and print a 
+line similar to :
 
-  A. Compiler command:
+	dmfe: Davicom DM9xxx net driver, version 1.36.4 (2002-01-17)
 
-     A-1: For normal single or multiple processor kernel
-          "gcc -DMODULE -D__KERNEL__ -I/usr/src/linux/net/inet -Wall 
-            -Wstrict-prototypes -O6 -c dmfe.c"
+If you compiled this driver as a module, you have to load it on boot.You can load it with command :
 
-     A-2: For single or multiple processor with kernel module version function
-          "gcc -DMODULE -DMODVERSIONS -D__KERNEL__ -I/usr/src/linux/net/inet 
-            -Wall -Wstrict-prototypes -O6 -c dmfe.c"
+	insmod dmfe
 
+This way it will autodetect the device mode.This is the suggested way to load the module.Or you can pass
+a mode= setting to module while loading, like :
 
-  B. The following steps teach you how to activate a DM9102 board:
+	insmod dmfe mode=0 # Force 10M Half Duplex
+        insmod dmfe mode=1 # Force 100M Half Duplex
+        insmod dmfe mode=4 # Force 10M Full Duplex
+        insmod dmfe mode=5 # Force 100M Full Duplex
 
-        1. Used the upper compiler command to compile dmfe.c
+Next you should configure your network interface with a command similar to :
 
-        2. Insert dmfe module into kernel
-           "insmod dmfe"        ;;Auto Detection Mode (Suggest)
-           "insmod dmfe mode=0" ;;Force 10M Half Duplex
-           "insmod dmfe mode=1" ;;Force 100M Half Duplex
-           "insmod dmfe mode=4" ;;Force 10M Full Duplex
-           "insmod dmfe mode=5" ;;Force 100M Full Duplex
+	ifconfig eth0 172.22.3.18
+                      ^^^^^^^^^^^
+		     Your IP Adress
 
-        3. Config a dm9102 network interface
-           "ifconfig eth0 172.22.3.18"
-                          ^^^^^^^^^^^ Your IP address
+Then you may have to modify the default routing table with command :
 
-        4. Activate the IP routing table. For some distributions, it is not
-           necessary. You can type "route" to check.
+	route add default eth0
 
-           "route add default eth0"
 
+Now your ethernet card should be up and running.
 
-        5. Well done. Your DM9102 adapter is now activated.
 
+TODO:
 
-   C. Object files description:
-        1. dmfe_rh61.o:       	For Redhat 6.1
+Implement pci_driver::suspend() and pci_driver::resume() power management methods.
+Check on 64 bit boxes.
+Check and fix on big endian boxes.
+Test and make sure PCI latency is now correct for all cases.
 
-        If you can make sure your kernel version, you can rename
-        to dmfe.o and directly use it without re-compiling.
 
+Authors:
 
-  Author: Sten Wang, 886-3-5798797-8517, E-mail: sten_wang@davicom.com.tw
+Sten Wang <sten_wang@davicom.com.tw >   : Original Author
+Tobias Ringstrom <tori@unhappy.mine.nu> : Current Maintainer
+
+Contributors:
+
+Marcelo Tosatti <marcelo@conectiva.com.br>
+Alan Cox <alan@redhat.com>
+Jeff Garzik <jgarzik@pobox.com>
+Vojtech Pavlik <vojtech@suse.cz>

--Boundary-00=_Ft8bCp6v85r2St9--
