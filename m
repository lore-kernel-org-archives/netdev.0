From: Adrian Bunk <bunk@kernel.org>
Subject: [2.6 patch] remove comx driver docs
Date: Mon, 5 Nov 2007 18:04:45 +0100
Message-ID: <20071105170445.GQ12045@stusta.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: jgarzik@pobox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from emailhub.stusta.mhn.de ([141.84.69.5]:59437 "EHLO
	mailhub.stusta.mhn.de" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1754578AbXKERFK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Nov 2007 12:05:10 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The drivers have already been removed 3.5 years ago.

Signed-off-by: Adrian Bunk <bunk@kernel.org>

---

 Documentation/networking/00-INDEX     |    2=20
 Documentation/networking/comx.txt     |  248 -----------------
 Documentation/networking/slicecom.hun |  371 -------------------------=
-
 Documentation/networking/slicecom.txt |  369 -------------------------
 4 files changed, 990 deletions(-)

89b45c57a2a74c6497cd808e15f9ef33077bf352=20
diff --git a/Documentation/networking/00-INDEX b/Documentation/networki=
ng/00-INDEX
index f5a5e6d..c48892e 100644
--- a/Documentation/networking/00-INDEX
+++ b/Documentation/networking/00-INDEX
@@ -26,8 +26,6 @@ baycom.txt
 	- info on the driver for Baycom style amateur radio modems
 bridge.txt
 	- where to get user space programs for ethernet bridging with Linux.
-comx.txt
-	- info on drivers for COMX line of synchronous serial adapters.
 cops.txt
 	- info on the COPS LocalTalk Linux driver
 cs89x0.txt
diff --git a/Documentation/networking/comx.txt b/Documentation/networki=
ng/comx.txt
deleted file mode 100644
index d1526eb..0000000
--- a/Documentation/networking/comx.txt
+++ /dev/null
@@ -1,248 +0,0 @@
-
-		COMX drivers for the 2.2 kernel
-
-Originally written by: Tivadar Szemethy, <tiv@itc.hu>
-Currently maintained by: Gergely Madarasz <gorgo@itc.hu>
-
-Last change: 21/06/1999.
-
-INTRODUCTION
-
-This document describes the software drivers and their use for the=20
-COMX line of synchronous serial adapters for Linux version 2.2.0 and
-above.
-The cards are produced and sold by ITC-Pro Ltd. Budapest, Hungary
-For further info contact <info@itc.hu>=20
-or http://www.itc.hu (mostly in Hungarian).
-The firmware files and software are available from ftp://ftp.itc.hu
-
-Currently, the drivers support the following cards and protocols:
-
-COMX (2x64 kbps intelligent board)
-CMX (1x256 + 1x128 kbps intelligent board)
-HiCOMX (2x2Mbps intelligent board)
-LoCOMX (1x512 kbps passive board)
-MixCOM (1x512 or 2x512kbps passive board with a hardware watchdog an
-	optional BRI interface and optional flashROM (1-32M))
-SliceCOM	(1x2Mbps channelized E1 board)
-PciCOM	(X21)
-
-At the moment of writing this document, the (Cisco)-HDLC, LAPB, SyncPP=
P and
-Frame Relay (DTE, rfc1294 IP encapsulation with partially implemented =
Q933a=20
-LMI) protocols are available as link-level protocol.=20
-X.25 support is being worked on.
-
-USAGE
-
-Load the comx.o module and the hardware-specific and protocol-specific=
=20
-modules you'll need into the running kernel using the insmod utility.
-This creates the /proc/comx directory.
-See the example scripts in the 'etc' directory.
-
-/proc INTERFACE INTRO
-
-The COMX driver set has a new type of user interface based on the /pro=
c=20
-filesystem which eliminates the need for external user-land software d=
oing=20
-IOCTL calls.=20
-Each network interface or device (i.e. those ones you configure with '=
ifconfig'
-and 'route' etc.) has a corresponding directory under /proc/comx. You =
can
-dynamically create a new interface by saying 'mkdir /proc/comx/comx0' =
(or you
-can name it whatever you want up to 8 characters long, comx[n] is just=
 a=20
-convention).
-Generally the files contained in these directories are text files, whi=
ch can
-be viewed by 'cat filename' and you can write a string to such a file =
by
-saying 'echo _string_ >filename'. This is very similar to the sysctl i=
nterface.
-Don't use a text editor to edit these files, always use 'echo' (or 'ca=
t'
-where appropriate).
-When you've created the comx[n] directory, two files are created autom=
agically
-in it: 'boardtype' and 'protocol'. You have to fill in these files cor=
rectly
-for your board and protocol you intend to use (see the board and proto=
col=20
-descriptions in this file below or the example scripts in the 'etc' di=
rectory).
-After filling in these files, other files will appear in the directory=
 for=20
-setting the various hardware- and protocol-related informations (for e=
xample
-irq and io addresses, keepalive values etc.) These files are set to de=
fault=20
-values upon creation, so you don't necessarily have to change all of t=
hem.
-
-When you're ready with filling in the files in the comx[n] directory, =
you can
-configure the corresponding network interface with the standard networ=
k=20
-configuration utilities. If you're unable to bring the interfaces up, =
look up
-the various kernel log files on your system, and consult the messages =
for
-a probable reason.
-
-EXAMPLE
-
-To create the interface 'comx0' which is the first channel of a COMX c=
ard:
-
-insmod comx=20
-# insmod comx-hw-comx ; insmod comx-proto-ppp  (these are usually
-autoloaded if you use the kernel module loader)
-
-mkdir /proc/comx/comx0
-echo comx >/proc/comx/comx0/boardtype
-echo 0x360 >/proc/comx/comx0/io		<- jumper-selectable I/O port=20
-echo 0x0a >/proc/comx/comx0/irq		<- jumper-selectable IRQ line
-echo 0xd000 >/proc/comx/comx0/memaddr	<- software-configurable memory
-					   address. COMX uses 64 KB, and this
-					   can be: 0xa000, 0xb000, 0xc000,=20
-					   0xd000, 0xe000. Avoid conflicts
-					   with other hardware.
-cat </etc/siol1.rom >/proc/comx/comx0/firmware <- the firmware for the=
 card
-echo HDLC >/proc/comx/comx0/protocol	<- the data-link protocol
-echo 10 >/proc/comx/comx0/keepalive	<- the keepalive for the protocol
-ifconfig comx0 1.2.3.4 pointopoint 5.6.7.8 netmask 255.255.255.255 <-
-					   finally configure it with ifconfig
-Check its status:
-cat /proc/comx/comx0/status
-
-If you want to use the second channel of this board:
-
-mkdir /proc/comx/comx1
-echo comx >/proc/comx/comx1/boardtype
-echo 0x360 >/proc/comx/comx1/io=09
-echo 10 >/proc/comx/comx1/irq	=09
-echo 0xd000 >/proc/comx/comx1/memaddr
-echo 1 >/proc/comx/comx1/channel	<- channels are numbered=20
-					   as 0 (default) and 1
-
-Now, check if the driver recognized that you're going to use the other
-channel of the same adapter:
-
-cat /proc/comx/comx0/twin
-comx1
-cat /proc/comx/comx1/twin
-comx0
-
-You don't have to load the firmware twice, if you use both channels of
-an adapter, just write it into the channel 0's /proc firmware file.
-
-Default values: io 0x360 for COMX, 0x320 (HICOMX), irq 10, memaddr 0xd=
0000
-
-THE LOCOMX HARDWARE DRIVER
-
-The LoCOMX driver doesn't require firmware, and it doesn't use memory =
either,
-but it uses DMA channels 1 and 3. You can set the clock rate (if enabl=
ed by
-jumpers on the board) by writing the kbps value into the file named 'c=
lock'.
-Set it to 'external' (it is the default) if you have external clock so=
urce.
-
-(Note: currently the LoCOMX driver does not support the internal clock=
)
-
-THE COMX, CMX AND HICOMX DRIVERS
-
-On the HICOMX, COMX and CMX, you have to load the firmware (it is diff=
erent for
-the three cards!). All these adapters can share the same memory
-address (we usually use 0xd0000). On the CMX you can set the internal
-clock rate (if enabled by jumpers on the small adapter boards) by writ=
ing
-the kbps value into the 'clock' file. You have to do this before initi=
alizing
-the card. If you use both HICOMX and CMX/COMX cards, initialize the HI=
COMX
-first. The I/O address of the HICOMX board is not configurable by any
-method available to the user: it is hardwired to 0x320, and if you hav=
e to=20
-change it, consult ITC-Pro Ltd.
-
-THE MIXCOM DRIVER
-
-The MixCOM board doesn't require firmware, the driver communicates wit=
h
-it through I/O ports. You can have three of these cards in one machine=
=2E
-
-THE SLICECOM DRIVER
-
-The SliceCOM board doesn't require firmware. You can have 4 of these c=
ards
-in one machine. The driver doesn't (yet) support shared interrupts, so
-you will need a separate IRQ line for every board.
-Read Documentation/networking/slicecom.txt for help on configuring
-this adapter.
-
-THE HDLC/PPP LINE PROTOCOL DRIVER
-
-The HDLC/SyncPPP line protocol driver uses the kernel's built-in syncp=
pp
-driver (syncppp.o). You don't have to manually select syncppp.o when b=
uilding
-the kernel, the dependencies compile it in automatically.
-
-
-
-
-EXAMPLE
-(setting up hw parameters, see above)
-
-# using HDLC:
-echo hdlc >/proc/comx/comx0/protocol
-echo 10 >/proc/comx/comx0/keepalive	<- not necessary, 10 is the defaul=
t
-ifconfig comx0 1.2.3.4 pointopoint 5.6.7.8 netmask 255.255.255.255
-
-(setting up hw parameters, see above)
-
-# using PPP:
-echo ppp >/proc/comx/comx0/protocol
-ifconfig comx0 up
-ifconfig comx0 1.2.3.4 pointopoint 5.6.7.8 netmask 255.255.255.255
-
-
-THE LAPB LINE PROTOCOL DRIVER
-
-For this, you'll need to configure LAPB support (See 'LAPB Data Link D=
river' in
-'Network options' section) into your kernel (thanks to Jonathan Naylor=
 for his=20
-excellent implementation).=20
-comx-proto-lapb.o provides the following files in the appropriate dire=
ctory
-(the default values in parens): t1 (5), t2 (1), n2 (20), mode (DTE, ST=
D) and
-window (7). Agree with the administrator of your peer router on these
-settings (most people use defaults, but you have to know if you are DT=
E or
-DCE).
-
-EXAMPLE
-
-(setting up hw parameters, see above)
-echo lapb >/proc/comx/comx0/protocol
-echo dce >/proc/comx/comx0/mode		<- DCE interface in this example
-ifconfig comx0 1.2.3.4 pointopoint 5.6.7.8 netmask 255.255.255.255
-
-
-THE FRAME RELAY PROTOCOL DRIVER
-
-You DON'T need any other frame relay related modules from the kernel t=
o use
-COMX-Frame Relay. This protocol is a bit more complicated than the oth=
ers,=20
-because it allows to use 'subinterfaces' or DLCIs within one physical =
device.
-First you have to create the 'master' device (the actual physical inte=
rface)
-as you would do for other protocols. Specify 'frad' as protocol type.
-Now you can bring this interface up by saying 'ifconfig comx0 up' (or =
whatever
-you've named the interface). Do not assign any IP address to this inte=
rface
-and do not set any routes through it.
-Then, set up your DLCIs the following way: create a comx interface for=
 each
-DLCI you intend to use (with mkdir), and write 'dlci' to the 'boardtyp=
e' file,=20
-and 'ietf-ip' to the 'protocol' file. Currently, the only supported=20
-encapsulation type is this (also called as RFC1294/1490 IP encapsulati=
on).
-Write the DLCI number to the 'dlci' file, and write the name of the ph=
ysical
-COMX device to the file called 'master'.=20
-Now you can assign an IP address to this interface and set routes usin=
g it.
-See the example file for further info and example config script.
-Notes: this driver implements a DTE interface with partially implement=
ed
-Q933a LMI.
-You can find an extensively commented example in the 'etc' directory.
-
-FURTHER /proc FILES
-
-boardtype:
-Type of the hardware. Valid values are:
- 'comx', 'hicomx', 'locomx', 'cmx', 'slicecom'.
-
-protocol:
-Data-link protocol on this channel. Can be: HDLC, LAPB, PPP, FRAD
-
-status:
-You can read the channel's actual status from the 'status' file, for e=
xample
-'cat /proc/comx/comx3/status'.
-
-lineup_delay:
-Interpreted in seconds (default is 1). Used to avoid line jitter: the =
system
-will consider the line status 'UP' only if it is up for at least this =
number
-of seconds.
-
-debug:=20
-You can set various debug options through this file. Valid options are=
:
-'comx_events', 'comx_tx', 'comx_rx', 'hw_events', 'hw_tx', 'hw_rx'.
-You can enable a debug options by writing its name prepended by a '+' =
into
-the debug file, for example 'echo +comx_rx >comx0/debug'.=20
-Disabling an option happens similarly, use the '-' prefix=20
-(e.g. 'echo -hw_rx >debug').
-Debug results can be read from the debug file, for example:=20
-tail -f /proc/comx/comx2/debug
-
-
diff --git a/Documentation/networking/slicecom.hun b/Documentation/netw=
orking/slicecom.hun
deleted file mode 100644
index bed2f04..0000000
--- a/Documentation/networking/slicecom.hun
+++ /dev/null
@@ -1,371 +0,0 @@
-
-SliceCOM adapter felhasznaloi dokumentacioja - 0.51 verziohoz
-
-Bart=C3=B3k Istv=C3=A1n <bartoki@itc.hu>
-Utolso modositas: Wed Aug 29 17:26:58 CEST 2001
-
------------------------------------------------------------------
-
-Hasznalata:
-
-Forditas:
-
-Code maturity level options
-	[*] Prompt for development and/or incomplete code/drivers
-
-Network device support
-	Wan interfaces
-		<M> MultiGate (COMX) synchronous
-			<M> Support for MUNICH based boards: SliceCOM, PCICOM (NEW)
-			<M> Support for HDLC and syncPPP...
-
-
-A modulok betoltese:
-
-modprobe comx
-
-modprobe comx-proto-ppp		# a Cisco-HDLC es a SyncPPP protokollt is
-				# ez a modul adja
-
-modprobe comx-hw-munich		# a modul betoltodeskor azonnal jelent a
-				# syslogba a detektalt kartyakrol
-
-
-Konfiguralas:
-
-# Ezen az interfeszen Cisco-HDLC vonali protokoll fog futni
-# Az interfeszhez rendelt idoszeletek: 1,2 (128 kbit/sec-es vonal)
-# (a G.703 keretben az elso adatot vivo idoszelet az 1-es)
-#
-mkdir /proc/comx/comx0.1/
-echo slicecom	>/proc/comx/comx0.1/boardtype
-echo hdlc	>/proc/comx/comx0.1/protocol
-echo 1 2	>/proc/comx/comx0.1/timeslots
-
-
-# Ezen az interfeszen SyncPPP vonali protokoll fog futni
-# Az interfeszhez rendelt idoszelet: 3 (64 kbit/sec-es vonal)
-#
-mkdir /proc/comx/comx0.2/
-echo slicecom	>/proc/comx/comx0.2/boardtype
-echo ppp	>/proc/comx/comx0.2/protocol
-echo 3		>/proc/comx/comx0.2/timeslots
-
-...
-
-ifconfig comx0.1 up
-ifconfig comx0.2 up
-
------------------------------------------------------------------
-
-A COMX driverek default 20 csomagnyi transmit queue-t rendelnek a halo=
zati
-interfeszekhez. WAN halozatokban ennel hosszabbat is szokas hasznalni
-(20 es 100 kozott), hogy a vonal kihasznaltsaga nagy terheles eseten j=
obb
-legyen (bar ezzel megno a varhato kesleltetes a csomagok sorban allasa=
 miatt):
-
-# ifconfig comx0 txqueuelen 50
-
-Ezt a beallitasi lehetoseget csak az ujabb disztribuciok ifconfig para=
ncsa
-tamogatja (amik mar a 2.2 kernelekhez keszultek, mint a RedHat 6.1 vag=
y a
-Debian 2.2).
-
-A 2.1-es Debian disztribuciohoz a http://www.debian.org/~rcw/2.2/netba=
se/
-cimrol toltheto le ujabb netbase csomag, ami mar ilyet tamogato ifconf=
ig
-parancsot tartalmaz. Bovebben a 2.2 kernel hasznalatarol Debian 2.1 al=
att:
-http://www.debian.org/releases/stable/running-kernel-2.2
-
------------------------------------------------------------------
-
-A kartya LED-jeinek jelentese:
-
-piros	- eg, ha Remote Alarm-ot kuld a tuloldal
-zold	- eg, ha a vett jelben megtalalja a keretszinkront
-
-Reszletesebben:
-
-piros:	zold:	jelentes:
-
--	-	nincs keretszinkron (nincs jel, vagy rossz a jel)
--	eg	"minden rendben"
-eg	eg	a vetel OK, de a tuloldal Remote Alarm-ot kuld
-eg	-	ez nincs ertelmezve, egyelore funkcio nelkul
-
------------------------------------------------------------------
-
-Reszletesebb leiras a hardver beallitasi lehetosegeirol:
-
-Az altalanos,- es a protokoll-retegek beallitasi lehetosegeirol a 'com=
x.txt'
-fajlban leirtak SliceCOM kartyanal is ervenyesek, itt csak a hardver-s=
pecifikus
-beallitasi lehetosegek vannak osszefoglalva:
-
-Konfiguralasi interfesz a /proc/comx/ alatt:
-
-Minden timeslot-csoportnak kulon comx* interfeszt kell letrehozni mkdi=
r-rel:
-comx0, comx1, .. stb. Itt beallithato, hogy az adott interfesz hanyadi=
k kartya
-melyik timeslotja(i)bol alljon ossze. A Cisco-fele serial3:1 elnevezes=
ek
-(serial3:1 =3D a 3. kartyaban az 1-es idoszelet-csoport) Linuxon alias=
ing-ot
-jelentenenek, ezert mi nem tudunk ilyen elnevezest hasznalni.
-
-Tobb kartya eseten a comx0.1, comx0.2, ... vagy slice0.1, slice0.2 nev=
ek
-hasznalhatoak.
-
-Tobb SliceCOM kartya is lehet egy gepben, de sajat interrupt kell mind=
egyiknek,
-nem tud meg megosztott interruptot kezelni.
-
-Az egesz kartyat erinto beallitasok:
-
-Az ioport es irq beallitas nincs: amit a PCI BIOS kioszt a rendszernek=
,
-azt hasznalja a driver.
-
-
-comx0/boardnum	- hanyadik SliceCOM kartya a gepben (a 'termeszetes' PC=
I
-		sorrendben ertve: ahogyan a /proc/pci-ban vagy az 'lspci'
-		kimeneteben megjelenik, altalaban az alaplapi PCI meghajto
-		aramkorokhoz kozelebb eso kartyak a kisebb sorszamuak)
-
-		Default: 0 (0-tol kezdodik a szamolas)
-
-
-Bar a kovetkezoket csak egy-egy interfeszen allitjuk at, megis az eges=
z kartya
-mukodeset egyszerre allitjak. A megkotes hogy csak UP-ban levo interfe=
szen
-hasznalhatoak, azert van, mert kulonben nem vart eredmenyekre vezetne =
egy ilyen
-paranccsorozat:
-
-	echo 0        >boardnum
-	echo internal >clock_source
-	echo 1        >boardnum
-
-- Ez a 0-s board clock_source-at allitana at.
-
-Ezek a beallitasok megmaradnak az osszes interfesz torlesekor, de torl=
odnek
-a driver modul ki/betoltesekor.
-
-
-comx0/clock_source - A Tx orajelforrasa, a Cisco-val hasonlatosra kesz=
ult.
-	Hasznalata:
-
-	papaya:# echo line     >/proc/comx/comx0/clock_source
-	papaya:# echo internal >/proc/comx/comx0/clock_source
-
-	line     - A Tx orajelet a vett adatfolyambol dekodolja, igyekszik
-		igazodni hozza. Ha nem lat orajelet az inputon, akkor
-		atall a sajat orajelgeneratorara.
-	internal - A Tx orajelet a sajat orajelgeneratora szolgaltatja.
-
-	Default: line
-
-	Normal osszeallitas eseten a tavkozlesi szolgaltato eszkoze
-	(pl. HDSL modem) adja az orajelet, ezert ez a default.
-
-
-comx0/framing	- A CRC4 ki/be kapcsolasa
-
-	A CRC4: 16 PCM keretet (A PCM keret az, amibe a 32 darab 64
-	kilobites csatorna van bemultiplexalva. Nem osszetevesztendo a HDLC
-	kerettel.) 2x8 -as csoportokra osztanak, es azokhoz 4-4 bites CRC-t
-	szamolnak. Elsosorban a vonal minosegenek a monitorozasara szolgal.
-
-	papaya:~# echo crc4	>/proc/comx/comx0/framing
-	papaya:~# echo no-crc4	>/proc/comx/comx0/framing
-
-	Default a 'crc4', a MATAV vonalak altalaban igy futnak. De ha nem
-	egyforma is a beallitas a vonal ket vegen, attol a forgalom altalaban
-	at tud menni.
-
-
-comx0/linecode	- A vonali kodolas beallitasa
-
-	papaya:~# echo hdb3	>/proc/comx/comx0/linecode
-	papaya:~# echo ami	>/proc/comx/comx0/linecode
-
-	Default a 'hdb3', a MATAV vonalak igy futnak.
-=09
-	(az AMI kodolas igen ritka E1-es vonalaknal). Ha ez a beallitas nem
-	egyezik a vonal ket vegen, akkor elofordulhat hogy a keretszinkron
-	osszejon, de CRC4-hibak es a vonalakon atvitt adatokban is hibak
-	keletkeznek (amit a HDLC/SyncPPP szinten CRC-hibaval jelez)
-
-
-comx0/reg	- a kartya aramkoreinek, a MUNICH (reg) es a FALC (lbireg)
-comx0/lbireg	regisztereinek kozvetlen elerese. Hasznalata:
-
-		echo >reg 0x04 0x0	- a 4-es regiszterbe 0-t ir
-		echo >reg 0x104		- printk()-val kiirja a 4-es regiszter
-					tartalmat a syslogba.
-
-		WARNING: ezek csak a fejleszteshez keszultek, sok galibat
-		lehet veluk okozni!
-
-
-comx0/loopback - A kartya G.703 jelenek a visszahurkolasara is van leh=
etoseg:
-
-	papaya:# echo none   >/proc/comx/comx0/loopback
-	papaya:# echo local  >/proc/comx/comx0/loopback
-	papaya:# echo remote >/proc/comx/comx0/loopback
-
-	none   - nincs visszahurkolas, normal mukodes
-	local  - a kartya a sajat maga altal adott jelet kapja vissza
-	remote - a kartya a kivulrol vett jelet adja kifele
-
-	Default: none
-
------------------------------------------------------------------
-
-Az interfeszhez (Cisco terminologiaban 'channel-group') kapcsolodo bea=
llitasok:
-
-comx0/timeslots	- mely timeslotok (idoszeletek) tartoznak az adott int=
erfeszhez.
-
-	papaya:~# cat /proc/comx/comx0/timeslots
-	1 3 4 5 6
-	papaya:~#
-
-	Egy timeslot megkeresese (hanyas interfeszbe tartozik nalunk):
-
-	papaya:~# grep ' 4' /proc/comx/comx*/timeslots
-	/proc/comx/comx0/timeslots:1 3 4 5 6
-	papaya:~#
-
-	Beallitasa:
-	papaya:~# echo '1 5 2 6 7 8' >/proc/comx/comx0/timeslots
-=09
-	A timeslotok sorrendje nem szamit, '1 3 2' ugyanaz mint az '1 2 3'.
-
-	Beallitashoz az adott interfesznek DOWN-ban kell lennie
-	(ifconfig comx0 down), de ugyanannak a kartyanak a tobbi interfesze
-	uzemelhet kozben.
-
-	Beallitaskor leellenorzi, hogy az uj timeslotok nem utkoznek-e egy
-	masik interfesz timeslotjaival. Ha utkoznek, akkor nem allitja at.
-
-	Mindig 10-es szamrendszerben tortenik a timeslotok ertelmezese, nehog=
y
-	a 08, 09 alaku felirast rosszul ertelmezze.
-
------------------------------------------------------------------
-
-Az interfeszek es a kartya allapotanak lekerdezese:
-
-- A ' '-szel kezdodo sorok az eredeti kimenetet, a //-rel kezdodo soro=
k a
-magyarazatot jelzik.
-
- papaya:~$ cat /proc/comx/comx1/status
- Interface administrative status is UP, modem status is UP, protocol i=
s UP
- Modem status changes: 0, Transmitter status is IDLE, tbusy: 0
- Interface load (input): 978376 / 947808 / 951024 bits/s (5s/5m/15m)
-               (output): 978376 / 947848 / 951024 bits/s (5s/5m/15m)
- Debug flags: none
- RX errors: len: 22, overrun: 1, crc: 0, aborts: 0
-            buffer overrun: 0, pbuffer overrun: 0
- TX errors: underrun: 0
- Line keepalive (value: 10) status UP [0]
-
-// Itt kezdodik a hardver-specifikus resz:
- Controller status:
-         No alarms
-
-// Alarm: hibajelzes:
-//
-// No alarms - minden rendben
-//
-// LOS  - Loss Of Signal - nem erzekel jelet a bemeneten.
-// AIS  - Alarm Indication Signal - csak egymas utani 1-esek jonnek
-//	a bemeneten, a tuloldal igy is jelezheti hogy meghibasodott vagy
-//	nincs inicializalva.
-// AUXP - Auxiliary Pattern Indication - 01010101.. sorozat jon a beme=
neten.
-// LFA  - Loss of Frame Alignment - nincs keretszinkron
-// RRA  - Receive Remote Alarm - a tuloldal el, de hibat jelez.
-// LMFA - Loss of CRC4 Multiframe Alignment - nincs CRC4-multikeret-sz=
inkron
-// NMF  - No Multiframe alignment Found after 400 msec - ilyen alarm a=
 no-crc4
-//	es crc4 keretezesek eseten nincs, lasd lentebb
-//
-// Egyeb lehetseges hibajelzesek:
-//
-// Transmit Line Short - a kartya ugy erzi hogy az adasi kimenete rovi=
dre
-//	van zarva, ezert kikapcsolta az adast. (nem feltetlenul veszi eszre
-//	a kulso rovidzarat)
-
-// A veteli oldal csomagjainak lancolt listai, debug celokra:
-
- Rx ring:
-         rafutott: 0
-         lastcheck: 50845731, jiffies: 51314281
-         base: 017b1858
-         rx_desc_ptr: 0
-         rx_desc_ptr: 017b1858
-         hw_curr_ptr: 017b1858
-         06040000 017b1868 017b1898 c016ff00
-         06040000 017b1878 017b1e9c c016ff00
-         46040000 017b1888 017b24a0 c016ff00
-         06040000 017b1858 017b2aa4 c016ff00
-
-// A kartyat hasznalo tobbi interfesz: a 0-s channel-group a comx1 int=
erfesz,
-// es az 1,2,...,16 timeslotok tartoznak hozza:
-
- Interfaces using this board: (channel-group, interface, timeslots)
-          0 comx1: 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16
-          1 comx2: 17
-          2 comx3: 18
-          3 comx4: 19
-          4 comx5: 20
-          5 comx6: 21
-          6 comx7: 22
-          7 comx8: 23
-          8 comx9: 24
-          9 comx10: 25
-         10 comx11: 26
-         11 comx12: 27
-         12 comx13: 28
-         13 comx14: 29
-         14 comx15: 30
-         15 comx16: 31
-
-// Hany esemenyt kezelt le a driver egy-egy hardver-interrupt kiszolga=
lasanal:
-
- Interrupt work histogram:
- hist[ 0]:        0 hist[ 1]:        2 hist[ 2]:    18574 hist[ 3]:   =
    79
- hist[ 4]:       14 hist[ 5]:        1 hist[ 6]:        0 hist[ 7]:   =
     1
- hist[ 8]:        0 hist[ 9]:        7
-
-// Hany kikuldendo csomag volt mar a Tx-ringben amikor ujabb lett irva=
 bele:
-
- Tx ring histogram:
- hist[ 0]:     2329 hist[ 1]:        0 hist[ 2]:        0 hist[ 3]:   =
     0
-
-// Az E1-interfesz hiba-szamlaloi, az rfc2495-nek megfeleloen:
-// (kb. a Cisco routerek "show controllers e1" formatumaban: http://ww=
w.cisco.com/univercd/cc/td/doc/product/software/ios11/rbook/rinterfc.ht=
m#xtocid25669126)
-
-Data in current interval (91 seconds elapsed):
-   9516 Line Code Violations, 65 Path Code Violations, 2 E-Bit Errors
-   0 Slip Secs, 2 Fr Loss Secs, 2 Line Err Secs, 0 Degraded Mins
-   0 Errored Secs, 0 Bursty Err Secs, 0 Severely Err Secs, 11 Unavail =
Secs
-Data in Interval 1 (15 minutes):
-   0 Line Code Violations, 0 Path Code Violations, 0 E-Bit Errors
-   0 Slip Secs, 0 Fr Loss Secs, 0 Line Err Secs, 0 Degraded Mins
-   0 Errored Secs, 0 Bursty Err Secs, 0 Severely Err Secs, 0 Unavail S=
ecs
-Data in last 4 intervals (1 hour):
-   0 Line Code Violations, 0 Path Code Violations, 0 E-Bit Errors
-   0 Slip Secs, 0 Fr Loss Secs, 0 Line Err Secs, 0 Degraded Mins
-   0 Errored Secs, 0 Bursty Err Secs, 0 Severely Err Secs, 0 Unavail S=
ecs
-Data in last 96 intervals (24 hours):
-   0 Line Code Violations, 0 Path Code Violations, 0 E-Bit Errors
-   0 Slip Secs, 0 Fr Loss Secs, 0 Line Err Secs, 0 Degraded Mins
-   0 Errored Secs, 0 Bursty Err Secs, 0 Severely Err Secs, 0 Unavail S=
ecs
-
------------------------------------------------------------------
-
-Nehany kulonlegesebb beallitasi lehetoseg (idovel beepulhetnek majd a =
driverbe):
-Ezekkel sok galibat lehet okozni, nagyon ovatosan kell oket hasznalni!
-
-	modified CRC-4, for improved interworking of CRC-4 and non-CRC-4
-	devices: (lasd page 107 es g706 Annex B)
-		lbireg[ 0x1b ] |=3D 0x08
-		lbireg[ 0x1c ] |=3D 0xc0
-	- ilyenkor ertelmezett az NMF - 'No Multiframe alignment Found after
-	400 msec' alarm.
-
-	FALC - a vonali meghajto IC
-	local loop - a sajat adasomat halljam vissza
-	remote loop - a kivulrol jovo adast adom vissza
-
-	Egy hibakeresesre hasznalhato dolog:
-		- 1-es timeslot local loop a FALC-ban:	echo >lbireg 0x1d 0x21
-		- local loop kikapcsolasa:		echo >lbireg 0x1d 0x00
diff --git a/Documentation/networking/slicecom.txt b/Documentation/netw=
orking/slicecom.txt
deleted file mode 100644
index c82c0cf..0000000
--- a/Documentation/networking/slicecom.txt
+++ /dev/null
@@ -1,369 +0,0 @@
-
-SliceCOM adapter user's documentation - for the 0.51 driver version
-
-Written by Bart=C3=B3k Istv=C3=A1n <bartoki@itc.hu>
-
-English translation: Lakatos Gy=C3=B6rgy <gyuri@itc.hu>
-Mon Dec 11 15:28:42 CET 2000
-
-Last modified: Wed Aug 29 17:25:37 CEST 2001
-
------------------------------------------------------------------
-
-Usage:
-
-Compiling the kernel:
-
-Code maturity level options
-	[*] Prompt for development and/or incomplete code/drivers
-
-Network device support
-	Wan interfaces
-		<M> MultiGate (COMX) synchronous
-			<M> Support for MUNICH based boards: SliceCOM, PCICOM (NEW)
-			<M> Support for HDLC and syncPPP...
-
-
-Loading the modules:
-
-modprobe comx
-
-modprobe comx-proto-ppp		# module for  Cisco-HDLC and SyncPPP protocol=
s
-
-modprobe comx-hw-munich		# the module logs information by the kernel
-				# about the detected boards
-
-
-Configuring the board:
-
-# This interface will use the Cisco-HDLC line protocol,
-# the timeslices assigned are 1,2 (128 KiBit line speed)
-# (the first data timeslice in the G.703 frame is no. 1)
-#
-mkdir /proc/comx/comx0.1/
-echo slicecom	>/proc/comx/comx0.1/boardtype
-echo hdlc	>/proc/comx/comx0.1/protocol
-echo 1 2	>/proc/comx/comx0.1/timeslots
-
-
-# This interface uses SyncPPP line protocol, the assigned=20
-# is no. 3 (64 KiBit line speed)
-#
-mkdir /proc/comx/comx0.2/
-echo slicecom	>/proc/comx/comx0.2/boardtype
-echo ppp	>/proc/comx/comx0.2/protocol
-echo 3		>/proc/comx/comx0.2/timeslots
-
-...
-
-ifconfig comx0.1 up
-ifconfig comx0.2 up
-
------------------------------------------------------------------
-
-The COMX interfaces use a 10 packet transmit queue by default, however=
 WAN
-networks sometimes use bigger values (20 to 100), to utilize the line =
better
-by large traffic (though the line delay increases because of more pack=
ets
-join the queue).
-
-# ifconfig comx0 txqueuelen 50
-
-This option is only supported by the ifconfig command of the later=20
-distributions, which came with 2.2 kernels, such as RedHat 6.1 or Debi=
an 2.2.
-
-You can download a newer netbase packet from=20
-http://www.debian.org/~rcw/2.2/netbase/ for Debian 2.1, which has a ne=
w
-ifconfig. You can get further information about using 2.2 kernel with
-Debian 2.1 from http://www.debian.org/releases/stable/running-kernel-2=
=2E2
-
------------------------------------------------------------------
-
-The SliceCom LEDs:
-
-red	- on, if the interface is unconfigured, or it gets Remote Alarm-s
-green	- on, if the board finds frame-sync in the received signal =09
-
-A bit more detailed:
-
-red:	green:	meaning:
-
--	-	no frame-sync, no signal received, or signal SNAFU.
--	on	"Everything is OK"
-on	on	Reception is ok, but the remote end sends Remote Alarm
-on	-	The interface is unconfigured
-
------------------------------------------------------------------
-
-A more detailed description of the hardware setting options:
-
-The general and the protocol layer options described in the 'comx.txt'=
 file
-apply to the SliceCom as well, I only summarize the SliceCom hardware =
specific
-settings below.
-
-The '/proc/comx' configuring interface:
-
-An interface directory should be created for every timeslot group with
-'mkdir', e,g: 'comx0', 'comx1' etc. The timeslots can be assigned here=
 to the
-specific interface. The Cisco-like naming convention (serial3:1 - firs=
t
-timeslot group of the 3rd. board) can't be used here, because these me=
an IP
-aliasing in Linux.
-
-You can give any meaningful name to keep the configuration clear;=20
-e.g: 'comx0.1', 'comx0.2', 'comx1.1', comx1.2', if you have two boards
-with two interfaces each.
-
-Settings, which apply to the board:
-
-Neither 'io' nor 'irq' settings required, the driver uses the resource=
s
-given by the PCI BIOS.
-
-comx0/boardnum	- board number of the SliceCom in the PC (using the 'na=
tural'
-		PCI order) as listed in '/proc/pci' or the output of the
-	 	'lspci' command, generally the slots nearer to the motherboard
-		PCI driver chips have the lower numbers.
-	=09
-		Default: 0 (the counting starts with 0)
-
-Though the options below are to be set on a single interface, they app=
ly to the
-whole board. The restriction, to use them on 'UP' interfaces, is becau=
se the=20
-command sequence below could lead to unpredictable results.
-
-	# echo 0        >boardnum
-	# echo internal >clock_source
-	# echo 1        >boardnum
-
-The sequence would set the clock source of board 0.
-
-These settings will persist after all the interfaces are cleared, but =
are
-cleared when the driver module is unloaded and loaded again.
-
-comx0/clock_source - source of the transmit clock
-	Usage:
-
-	# echo line     >/proc/comx/comx0/clock_source
-	# echo internal >/proc/comx/comx0/clock_source
-
-	line	- The Tx clock is being decoded if the input data stream,
-		if no clock seen on the input, then the board will use it's
-		own clock generator.
-
-	internal - The Tx clock is supplied by the builtin clock generator. =09
-
-	Default: line
-
-	Normally, the telecommunication company's end device (the HDSL
-	modem) provides the Tx clock, that's why 'line' is the default.
-
-comx0/framing	- Switching CRC4 off/on
-
-	CRC4: 16 PCM frames (The 32 64Kibit channels are multiplexed into a
-	PCM frame, nothing to do with HDLC frames) are divided into 2x8
-	groups, each group has a 4 bit CRC.
-
-	# echo crc4	>/proc/comx/comx0/framing
-	# echo no-crc4	>/proc/comx/comx0/framing
-
-	Default is 'crc4', the Hungarian MATAV lines behave like this.=20
-	The traffic generally passes if this setting on both ends don't match=
=2E
-
-comx0/linecode	- Setting the line coding
-
-	# echo hdb3	>/proc/comx/comx0/linecode
-	# echo ami	>/proc/comx/comx0/linecode
-
-	Default a 'hdb3', MATAV lines use this.
-=09
-	(AMI coding is rarely used with E1 lines). Frame sync may occur, if
-	this setting doesn't match the other end's, but CRC4 and data errors
-	will come, which will result in CRC errors on HDLC/SyncPPP level.=20
-
-comx0/reg	- direct access to the board's MUNICH (reg) and FALC (lbireg=
)
-comx0/lbireg	circuit's registers =20
-
-	# echo >reg 0x04 0x0	- write 0 to register 4
-	# echo >reg 0x104	- write the contents of register 4 with
-				printk() to syslog
-
-WARNING! These are only for development purposes, messing with this wi=
ll
-	result much trouble!
-
-comx0/loopback - Places a loop to the board's G.703 signals
-
-	# echo none   >/proc/comx/comx0/loopback
-	# echo local  >/proc/comx/comx0/loopback
-	# echo remote >/proc/comx/comx0/loopback
-
-	none   - normal operation, no loop
-	local  - the board receives it's own output
-	remote - the board sends the received data to the remote side
-
-	Default: none
-
------------------------------------------------------------------
-
-Interface (channel group in Cisco terms) settings:=20
-
-comx0/timeslots	- which timeslots belong to the given interface
-
-	Setting:
-
-	# echo '1 5 2 6 7 8' >/proc/comx/comx0/timeslots
-
-	# cat /proc/comx/comx0/timeslots
-	1 2 5 6 7 8=20
-	#
-
-	Finding a timeslot:=20
-
-	# grep ' 4' /proc/comx/comx*/timeslots
-	/proc/comx/comx0/timeslots:1 3 4 5 6
-	#
-
-	The timeslots can be in any order, '1 2 3' is the same as '1 3 2'.
-
-	The interface has to be DOWN during the setting ('ifconfig comx0
-	down'), but the other interfaces could operate normally.
-
-	The driver checks if the assigned timeslots are vacant, if not, then
-	the setting won't be applied.
-
-	The timeslot values are treated as decimal numbers, not to misunderst=
and
-	values of 08, 09 form.
-
------------------------------------------------------------------
-
-Checking the interface and board status:
-
-- Lines beginning with ' ' (space) belong to the original output, the =
lines
-which begin with '//' are the comments.
-
- papaya:~$ cat /proc/comx/comx1/status
- Interface administrative status is UP, modem status is UP, protocol i=
s UP
- Modem status changes: 0, Transmitter status is IDLE, tbusy: 0
- Interface load (input): 978376 / 947808 / 951024 bits/s (5s/5m/15m)
-               (output): 978376 / 947848 / 951024 bits/s (5s/5m/15m)
- Debug flags: none
- RX errors: len: 22, overrun: 1, crc: 0, aborts: 0
-            buffer overrun: 0, pbuffer overrun: 0
- TX errors: underrun: 0
- Line keepalive (value: 10) status UP [0]
-
-// The hardware specific part starts here:
- Controller status:
-         No alarms
-
-// Alarm:=20
-//
-// No alarms - Everything OK
-//
-// LOS  - Loss Of Signal - No signal sensed on the input
-// AIS  - Alarm Indication Signal - The remote side sends '11111111'-s=
,=20
-//	it tells, that there's an error condition, or it's not
-//	initialised.
-// AUXP - Auxiliary Pattern Indication - 01010101.. received.
-// LFA  - Loss of Frame Alignment - no frame sync received.
-// RRA  - Receive Remote Alarm - the remote end's OK, but signals erro=
r cond.
-// LMFA - Loss of CRC4 Multiframe Alignment - no CRC4 multiframe sync.
-// NMF  - No Multiframe alignment Found after 400 msec - no such alarm=
 using
-//	no-crc4 or crc4 framing, see below.
-//
-// Other possible error messages:
-//
-// Transmit Line Short - the board felt, that it's output is short-cir=
cuited,
-// 	so it switched the transmission off. (The board can't definitely t=
ell,
-//	that it's output is short-circuited.)
-
-// Chained list of the received packets, for debug purposes:
-
- Rx ring:
-         rafutott: 0
-         lastcheck: 50845731, jiffies: 51314281
-         base: 017b1858
-         rx_desc_ptr: 0
-         rx_desc_ptr: 017b1858
-         hw_curr_ptr: 017b1858
-         06040000 017b1868 017b1898 c016ff00
-         06040000 017b1878 017b1e9c c016ff00
-         46040000 017b1888 017b24a0 c016ff00
-         06040000 017b1858 017b2aa4 c016ff00
-
-// All the interfaces using the board: comx1, using the 1,2,...16 time=
slots,
-// comx2, using timeslot 17, etc.
-
- Interfaces using this board: (channel-group, interface, timeslots)
-          0 comx1: 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16
-          1 comx2: 17
-          2 comx3: 18
-          3 comx4: 19
-          4 comx5: 20
-          5 comx6: 21
-          6 comx7: 22
-          7 comx8: 23
-          8 comx9: 24
-          9 comx10: 25
-         10 comx11: 26
-         11 comx12: 27
-         12 comx13: 28
-         13 comx14: 29
-         14 comx15: 30
-         15 comx16: 31
-
-// The number of events handled by the driver during an interrupt cycl=
e:
-
- Interrupt work histogram:
- hist[ 0]:        0 hist[ 1]:        2 hist[ 2]:    18574 hist[ 3]:   =
    79
- hist[ 4]:       14 hist[ 5]:        1 hist[ 6]:        0 hist[ 7]:   =
     1
- hist[ 8]:        0 hist[ 9]:        7
-
-// The number of packets to send in the Tx ring, when a new one arrive=
d:
-
- Tx ring histogram:
- hist[ 0]:     2329 hist[ 1]:        0 hist[ 2]:        0 hist[ 3]:   =
     0
-
-// The error counters of the E1 interface, according to the RFC2495,
-// (similar to the Cisco "show controllers e1" command's output:
-// http://www.cisco.com/univercd/cc/td/doc/product/software/ios11/rboo=
k/rinterfc.htm#xtocid25669126)
-
-Data in current interval (91 seconds elapsed):
-   9516 Line Code Violations, 65 Path Code Violations, 2 E-Bit Errors
-   0 Slip Secs, 2 Fr Loss Secs, 2 Line Err Secs, 0 Degraded Mins
-   0 Errored Secs, 0 Bursty Err Secs, 0 Severely Err Secs, 11 Unavail =
Secs
-Data in Interval 1 (15 minutes):
-   0 Line Code Violations, 0 Path Code Violations, 0 E-Bit Errors
-   0 Slip Secs, 0 Fr Loss Secs, 0 Line Err Secs, 0 Degraded Mins
-   0 Errored Secs, 0 Bursty Err Secs, 0 Severely Err Secs, 0 Unavail S=
ecs
-Data in last 4 intervals (1 hour):
-   0 Line Code Violations, 0 Path Code Violations, 0 E-Bit Errors
-   0 Slip Secs, 0 Fr Loss Secs, 0 Line Err Secs, 0 Degraded Mins
-   0 Errored Secs, 0 Bursty Err Secs, 0 Severely Err Secs, 0 Unavail S=
ecs
-Data in last 96 intervals (24 hours):
-   0 Line Code Violations, 0 Path Code Violations, 0 E-Bit Errors
-   0 Slip Secs, 0 Fr Loss Secs, 0 Line Err Secs, 0 Degraded Mins
-   0 Errored Secs, 0 Bursty Err Secs, 0 Severely Err Secs, 0 Unavail S=
ecs
-
------------------------------------------------------------------
-
-Some unique options, (may get into the driver later):
-Treat them very carefully, these can cause much trouble!
-
-	modified CRC-4, for improved interworking of CRC-4 and non-CRC-4
-	devices: (see page 107 and g706 Annex B)
-		lbireg[ 0x1b ] |=3D 0x08
-		lbireg[ 0x1c ] |=3D 0xc0
-
-	- The NMF - 'No Multiframe alignment Found after 400 msec' alarm=20
-	comes into account.
-
-	FALC - the line driver chip.
-	local loop - I hear my transmission back.
-	remote loop - I echo the remote transmission back.
-
-	Something useful for finding errors:
-=09
-		- local loop for timeslot 1 in the FALC chip:
-
-	# echo >lbireg 0x1d 0x21
-
-		- Switching the loop off:
-
-	# echo >lbireg 0x1d 0x00

