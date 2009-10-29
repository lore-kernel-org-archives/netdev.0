From: <Narendra_K@Dell.com>
Subject: RE: [PATCH] udev: create empty regular files to represent net interfaces
Date: Thu, 29 Oct 2009 22:14:08 +0530
Message-ID: <EDA0A4495861324DA2618B4C45DCB3EE589662@blrx3m08.blr.amer.dell.com>
References: <20091016214024.GA10091@ldl.fc.hp.com> <20091022063619.GB6321@ldl.fc.hp.com> <20091027205551.GA31963@auslistsprd01.us.dell.com> <ac3eb2510910280123g3c0e3d95wb38a239238906027@mail.gmail.com> <20091029131125.GA13809@auslistsprd01.us.dell.com> <20091029142554.GA16869@kroah.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
	boundary="----_=_NextPart_001_01CA58B7.095AA8AA"
Cc: <kay.sievers@vrfy.org>, <dannf@hp.com>,
	<linux-hotplug@vger.kernel.org>, <netdev@vger.kernel.org>,
	<Jordan_Hargrave@Dell.com>, <Charles_Rose@Dell.com>,
	<bhutchings@solarflare.com>
To: <greg@kroah.com>, <Matt_Domsch@Dell.com>
Return-path: <linux-hotplug-owner@vger.kernel.org>
Content-class: urn:content-classes:message
In-Reply-To: <20091029142554.GA16869@kroah.com>
Sender: linux-hotplug-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.

------_=_NextPart_001_01CA58B7.095AA8AA
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: quoted-printable


>> Netdev team - are you in agreement that having multiple names to=20
>> address the same netdevice is a worthwhile thing to add, to allow a=20
>> variety of naming schemes to exist simultaneously?  If not,=20
>this whole=20
>> discussion will be moot, and my basic problem, that the ethX naming=20
>> convention is nondeterministic, but we need determinism, remains=20
>> unresolved.
>
>I'm still totally confused as to why you think this.  What is=20
>wrong with what we do today, which is name network devices in=20
>a deterministic manner by their MAC in userspace?  That name=20
>goes into the kernel, and everyone uses the same name and is happy.

The interface name as assigned by the OS is determined by how the
interface is named first during the OS installation. This name is made
persistent by associating the name with it's MAC address in userspace,
either by udev or ifcfg-eth files. In cases where there are one or more
add-in cards along with one or more integrated cards (Lan on
Motherboard), the integrated port 1, which is designated as Gb1 on the
chassis may or may not get the name "eth0". And that is the customer
expectation, most of the times.
Unattended installs and large scale image based installs are the most
affected scenarios.=20

>If you don't like naming by MAC, then pick some other=20
>deterministic naming scheme that works for your hardware and=20
>write udev rules for it.
>
>You could easily name them in a way that could keep the lowest number
>(eth0) for the lowest PCI id if you so desired and your BIOS=20
>guaranteed it.
>

This is how the lspci tree view on a PER710 (PowerEdge R710) server with
Four BCM5709 integrated NIC ports and One add-in Intel NIC port looks
like. The integrated ports are always found before the add-in nic (or
nics) by the BIOS consistently and BIOS guarantees it across every
reboot. If the OS also found and named the network ports in the same
manner, then there is no issue as integrated NIC port 1, designated Gb1
on the chassis, is always named as "eth0". But the observation is that,
it is not the case always.

-[0000:00]-+-00.0  Intel Corporation 5520 I/O Hub to ESI Port
           +-01.0-[0000:01]--+-00.0  Broadcom Corporation NetXtreme II
BCM5709 Gigabit Ethernet
           |                 \-00.1  Broadcom Corporation NetXtreme II
BCM5709 Gigabit Ethernet
           +-03.0-[0000:02]--+-00.0  Broadcom Corporation NetXtreme II
BCM5709 Gigabit Ethernet
           |                 \-00.1  Broadcom Corporation NetXtreme II
BCM5709 Gigabit Ethernet
           +-04.0-[0000:03]----00.0  LSI Logic / Symbios Logic MegaRAID
SAS 1078
           +-05.0-[0000:04]--
           +-06.0-[0000:05]--
           +-07.0-[0000:06]--
           +-09.0-[0000:07]----00.0  Intel Corporation 82598EB
10-Gigabit AT Network Connection

In such cases, pathnames like Embedded_NIC_1 -> eth[01..], point to the
right interface, and communicate a more meaningful name without any
state embedded in them.

With regards,
Narendra K


         =20



------_=_NextPart_001_01CA58B7.095AA8AA
Content-Type: application/octet-stream;
	name="PER710-lspci-tv.output"
Content-Transfer-Encoding: base64
Content-Description: PER710-lspci-tv.output
Content-Disposition: attachment;
	filename="PER710-lspci-tv.output"

LVswMDAwOjAwXS0rLTAwLjAgIEludGVsIENvcnBvcmF0aW9uIDU1MjAgSS9PIEh1YiB0byBFU0kg
UG9ydA0KICAgICAgICAgICArLTAxLjAtWzAwMDA6MDFdLS0rLTAwLjAgIEJyb2FkY29tIENvcnBv
cmF0aW9uIE5ldFh0cmVtZSBJSSBCQ001NzA5IEdpZ2FiaXQgRXRoZXJuZXQNCiAgICAgICAgICAg
fCAgICAgICAgICAgICAgICAgXC0wMC4xICBCcm9hZGNvbSBDb3Jwb3JhdGlvbiBOZXRYdHJlbWUg
SUkgQkNNNTcwOSBHaWdhYml0IEV0aGVybmV0DQogICAgICAgICAgICstMDMuMC1bMDAwMDowMl0t
LSstMDAuMCAgQnJvYWRjb20gQ29ycG9yYXRpb24gTmV0WHRyZW1lIElJIEJDTTU3MDkgR2lnYWJp
dCBFdGhlcm5ldA0KICAgICAgICAgICB8ICAgICAgICAgICAgICAgICBcLTAwLjEgIEJyb2FkY29t
IENvcnBvcmF0aW9uIE5ldFh0cmVtZSBJSSBCQ001NzA5IEdpZ2FiaXQgRXRoZXJuZXQNCiAgICAg
ICAgICAgKy0wNC4wLVswMDAwOjAzXS0tLS0wMC4wICBMU0kgTG9naWMgLyBTeW1iaW9zIExvZ2lj
IE1lZ2FSQUlEIFNBUyAxMDc4DQogICAgICAgICAgICstMDUuMC1bMDAwMDowNF0tLQ0KICAgICAg
ICAgICArLTA2LjAtWzAwMDA6MDVdLS0NCiAgICAgICAgICAgKy0wNy4wLVswMDAwOjA2XS0tDQog
ICAgICAgICAgICstMDkuMC1bMDAwMDowN10tLS0tMDAuMCAgSW50ZWwgQ29ycG9yYXRpb24gODI1
OThFQiAxMC1HaWdhYml0IEFUIE5ldHdvcmsgQ29ubmVjdGlvbg0KICAgICAgICAgIA0K

------_=_NextPart_001_01CA58B7.095AA8AA--
