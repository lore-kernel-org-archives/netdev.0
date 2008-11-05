From: Jesper Dangaard Brouer <jdb@comx.dk>
Subject: Re: NIU driver: Sun x8 Express Quad Gigabit Ethernet Adapter
Date: Wed, 05 Nov 2008 08:05:44 +0100
Message-ID: <1225868744.31605.12.camel@localhost.localdomain>
References: <1225809909.10206.90.camel@localhost.localdomain>
	 <20081104.134236.115613394.davem@davemloft.net>
Reply-To: jdb@comx.dk
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="=-HrnHZKl2mJa1xZtRGZkE"
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from lanfw001a.cxnet.dk ([87.72.215.196]:42281 "EHLO
	lanfw001a.cxnet.dk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751611AbYKEHFr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Nov 2008 02:05:47 -0500
In-Reply-To: <20081104.134236.115613394.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-HrnHZKl2mJa1xZtRGZkE
Content-Type: text/plain
Content-Transfer-Encoding: 7bit

On Tue, 2008-11-04 at 13:42 -0800, David Miller wrote:
> From: Jesper Dangaard Brouer <jdb@comx.dk>
> Date: Tue, 04 Nov 2008 15:45:09 +0100
> 
> > I just bought the Sun x8 Express Quad Gigabit Ethernet Adapter you
> > recommended to me.  It seem to work with the NIU driver (I can ping
> > through the box), but I get a kernel warning when spamming it with
> > pktgen...
> > 
> > Where do I go from here?
> > And what do you want me to try?
> 
> Looks like the transmitter is wedged.

I have attached niu related output from kern.log.
(cat /var/log/kern.log | grep niu | awk -F'kernel:' '{print $2}')

> Using current sources I assume?

Yes, your latest tree.  Both with and without your latest change to the
niu driver (niu: Use pci_ioremap_bar().).

Also tried a debian 2.6.26-1-686, that kernel actually crashed (in
net_rx_action, __do_softirq, do_softirq, irq_exit, do_IRQ, mwait_idle).

A strange observation is the IRQ allocations seen via /proc/interrupts:
(e.g. eth2 has assigned no less than 12 IRQs !?!)

dcu-router-ng:~# cat /proc/interrupts 
           CPU0       CPU1       CPU2       CPU3       
  0:        123          1          0          1   IO-APIC-edge      timer
  1:          1          0          0          1   IO-APIC-edge      i8042
  3:          2          2          1          2   IO-APIC-edge      serial
  9:          0          0          0          0   IO-APIC-fasteoi   acpi
 12:          0          1          2          1   IO-APIC-edge      i8042
 14:         15         14         13         15   IO-APIC-edge      ata_piix
 15:          0          0          0          0   IO-APIC-edge      ata_piix
 16:        404        412        424        367   IO-APIC-fasteoi   uhci_hcd:usb1, ehci_hcd:usb6, eth0
 17:          0          0          0          0   IO-APIC-fasteoi   uhci_hcd:usb2, eth3
 18:          8          9          8          9   IO-APIC-fasteoi   uhci_hcd:usb3
 19:          0          0          0          0   IO-APIC-fasteoi   uhci_hcd:usb4
 20:          0          0          0          0   PCI-MSI-edge      eth2
 21:        963        959        942        997   IO-APIC-fasteoi   ipmi_si, eth2
 22:         23         23         24         23   IO-APIC-fasteoi   uhci_hcd:usb5, eth2
 23:          0          0          0          0   PCI-MSI-edge      eth2
 24:          0          0          0          0   PCI-MSI-edge      eth2
 25:          0          0          0          0   PCI-MSI-edge      eth2
 26:          0          0          0          0   PCI-MSI-edge      eth2
 27:          0          0          0          0   PCI-MSI-edge      eth2
 28:          0          0          0          0   PCI-MSI-edge      eth2
 29:          0          0          0          0   PCI-MSI-edge      eth2
 30:          0          0          0          0   PCI-MSI-edge      eth2
 31:          0          0          0          0   PCI-MSI-edge      eth2
 32:          0          0          0          0   PCI-MSI-edge      eth2
 34:        318        310        319        317   PCI-MSI-edge      cciss0
NMI:          0          0          0          0   Non-maskable interrupts
LOC:      89420     334612     485037     172341   Local timer interrupts
RES:        101        270        159        174   Rescheduling interrupts
CAL:         83        132        122         74   Function call interrupts
TLB:        259        226        350        315   TLB shootdowns
TRM:          0          0          0          0   Thermal event interrupts
SPU:          0          0          0          0   Spurious interrupts
ERR:          0
MIS:          0

-- 
Med venlig hilsen / Best regards
  Jesper Brouer
  ComX Networks A/S
  Linux Network developer
  Cand. Scient Datalog / MSc.
  Author of http://adsl-optimizer.dk
  LinkedIn: http://www.linkedin.com/in/brouer

--=-HrnHZKl2mJa1xZtRGZkE
Content-Disposition: attachment; filename=niu_kern.log
Content-Type: text/x-log; name=niu_kern.log; charset=us-ascii
Content-Transfer-Encoding: base64

Y2F0IC92YXIvbG9nL2tlcm4ubG9nIHwgZ3JlcCBuaXUgfCBhd2sgLUYna2VybmVsOicgJ3twcmlu
dCAkMn0nID4gbml1X2tlcm4ubG9nDQoNCiBuaXUuYzp2MC45IChNYXkgNCwgMjAwOCkNCiBuaXUg
MDAwMDowYjowMC4wOiBQQ0kgSU5UIEEgLT4gR1NJIDE2IChsZXZlbCwgbG93KSAtPiBJUlEgMTYN
CiBuaXU6IG5pdV9nZXRfcGFyZW50OiBwbGF0Zm9ybV90eXBlWzFdIHBvcnRbMF0NCiBuaXU6IG5p
dV9uZXdfcGFyZW50OiBDcmVhdGluZyBuZXcgcGFyZW50Lg0KIG5pdSAwMDAwOjBiOjAwLjA6IHNl
dHRpbmcgbGF0ZW5jeSB0aW1lciB0byA2NA0KIG5pdTogbml1X2dldF9pbnZhcmlhbnRzOiBWUEQg
b2Zmc2V0IFswMDAxNmEwMF0NCiBuaXU6IFZQRF9TQ0FOOiBzdGFydFsxNmExNF0gZW5kWzE2Yjk4
XQ0KIG5pdTogVlBEX1NDQU46IFJlYWRpbmcgaW4gcHJvcGVydHkgW2xvY2FsLW1hYy1hZGRyZXNz
XSBsZW5bNl0NCiBuaXU6IFZQRF9TQ0FOOiBSZWFkaW5nIGluIHByb3BlcnR5IFt2ZXJzaW9uXSBs
ZW5bMzhdDQogbml1OiBWUERfU0NBTjogUmVhZGluZyBpbiBwcm9wZXJ0eSBbbW9kZWxdIGxlblsx
NF0NCiBuaXU6IFZQRF9TQ0FOOiBSZWFkaW5nIGluIHByb3BlcnR5IFtib2FyZC1tb2RlbF0gbGVu
WzEyXQ0KIG5pdTogVlBEX1NDQU46IFJlYWRpbmcgaW4gcHJvcGVydHkgW251bS1tYWMtYWRkcmVz
c2VzXSBsZW5bMV0NCiBuaXU6IFZQRF9TQ0FOOiBSZWFkaW5nIGluIHByb3BlcnR5IFtwaHktdHlw
ZV0gbGVuWzRdDQogbml1OiBWUERfU0NBTjogRkNPREUgbWFqb3IoMykgbWlub3IoOSkNCiBuaXU6
IG5pdV9nZXRfYW5kX3ZhbGlkYXRlX3BvcnQ6IHBvcnRbMF0gbnVtX3BvcnRzWzRdDQogbml1OiBu
aXVfcHJvYmVfcG9ydHMoKTogcG9ydF9waHlbMDAwMDAwMDBdDQogbml1MDogRm91bmQgUEhZIDAw
MjA2MGIxIHR5cGUgTUlJIGF0IHBoeV9wb3J0IDEwDQogbml1MDogRm91bmQgUEhZIDAwMjA2MGIx
IHR5cGUgTUlJIGF0IHBoeV9wb3J0IDExDQogbml1MDogRm91bmQgUEhZIDAwMjA2MGIxIHR5cGUg
TUlJIGF0IHBoeV9wb3J0IDEyDQogbml1MDogRm91bmQgUEhZIDAwMjA2MGIxIHR5cGUgTUlJIGF0
IHBoeV9wb3J0IDEzDQogbml1OiBuaXUwOiBQb3J0IDAgWzQgUlggY2hhbnNdIFs2IFRYIGNoYW5z
XQ0KIG5pdTogbml1MDogUG9ydCAxIFs0IFJYIGNoYW5zXSBbNiBUWCBjaGFuc10NCiBuaXU6IG5p
dTA6IFBvcnQgMiBbNCBSWCBjaGFuc10gWzYgVFggY2hhbnNdDQogbml1OiBuaXUwOiBQb3J0IDMg
WzQgUlggY2hhbnNdIFs2IFRYIGNoYW5zXQ0KIG5pdTogbml1MDogUG9ydCAwIFJEQyB0YmwoMCkg
WyAwIDEgMiAzIDAgMSAyIDMgMCAxIDIgMyAwIDEgMiAzIF0NCiBuaXU6IG5pdTA6IFBvcnQgMCBS
REMgdGJsKDEpIFsgMCAxIDIgMyAwIDEgMiAzIDAgMSAyIDMgMCAxIDIgMyBdDQogbml1OiBuaXUw
OiBQb3J0IDEgUkRDIHRibCgyKSBbIDQgNSA2IDcgNCA1IDYgNyA0IDUgNiA3IDQgNSA2IDcgXQ0K
IG5pdTogbml1MDogUG9ydCAxIFJEQyB0YmwoMykgWyA0IDUgNiA3IDQgNSA2IDcgNCA1IDYgNyA0
IDUgNiA3IF0NCiBuaXU6IG5pdTA6IFBvcnQgMiBSREMgdGJsKDQpIFsgOCA5IDEwIDExIDggOSAx
MCAxMSA4IDkgMTAgMTEgOCA5IDEwIDExIF0NCiBuaXU6IG5pdTA6IFBvcnQgMiBSREMgdGJsKDUp
IFsgOCA5IDEwIDExIDggOSAxMCAxMSA4IDkgMTAgMTEgOCA5IDEwIDExIF0NCiBuaXU6IG5pdTA6
IFBvcnQgMyBSREMgdGJsKDYpIFsgMTIgMTMgMTQgMTUgMTIgMTMgMTQgMTUgMTIgMTMgMTQgMTUg
MTIgMTMgMTQgMTUgXQ0KIG5pdTogbml1MDogUG9ydCAzIFJEQyB0YmwoNykgWyAxMiAxMyAxNCAx
NSAxMiAxMyAxNCAxNSAxMiAxMyAxNCAxNSAxMiAxMyAxNCAxNSBdDQogbml1IDAwMDA6MGI6MDAu
MDogaXJxIDMyIGZvciBNU0kvTVNJLVgNCiBuaXUgMDAwMDowYjowMC4wOiBpcnEgMzEgZm9yIE1T
SS9NU0ktWA0KIG5pdSAwMDAwOjBiOjAwLjA6IGlycSAzMCBmb3IgTVNJL01TSS1YDQogbml1IDAw
MDA6MGI6MDAuMDogaXJxIDI5IGZvciBNU0kvTVNJLVgNCiBuaXUgMDAwMDowYjowMC4wOiBpcnEg
MjggZm9yIE1TSS9NU0ktWA0KIG5pdSAwMDAwOjBiOjAwLjA6IGlycSAyNyBmb3IgTVNJL01TSS1Y
DQogbml1IDAwMDA6MGI6MDAuMDogaXJxIDI2IGZvciBNU0kvTVNJLVgNCiBuaXUgMDAwMDowYjow
MC4wOiBpcnEgMjUgZm9yIE1TSS9NU0ktWA0KIG5pdSAwMDAwOjBiOjAwLjA6IGlycSAyNCBmb3Ig
TVNJL01TSS1YDQogbml1IDAwMDA6MGI6MDAuMDogaXJxIDIzIGZvciBNU0kvTVNJLVgNCiBuaXUg
MDAwMDowYjowMC4wOiBpcnEgMjIgZm9yIE1TSS9NU0ktWA0KIG5pdSAwMDAwOjBiOjAwLjA6IGly
cSAyMSBmb3IgTVNJL01TSS1YDQogbml1IDAwMDA6MGI6MDAuMDogaXJxIDIwIGZvciBNU0kvTVNJ
LVgNCiBuaXU6IG5pdV9jbGFzc2lmaWVyX3N3c3RhdGVfaW5pdDogbnVtX3RjYW0oMjU2KQ0KIG5p
dTogZmZscF9lYXJseV9pbml0OiBJbml0dGluZyBodyBvbiBwb3J0IDANCiBuaXU6IGZmbHBfZWFy
bHlfaW5pdDogU3VjY2Vzcw0KIG5pdSAwMDAwOjBiOjAwLjE6IFBDSSBJTlQgQiAtPiBHU0kgMTcg
KGxldmVsLCBsb3cpIC0+IElSUSAxNw0KIG5pdTogbml1X2dldF9wYXJlbnQ6IHBsYXRmb3JtX3R5
cGVbMV0gcG9ydFsxXQ0KIG5pdSAwMDAwOjBiOjAwLjE6IHNldHRpbmcgbGF0ZW5jeSB0aW1lciB0
byA2NA0KIG5pdTogbml1X2dldF9pbnZhcmlhbnRzOiBWUEQgb2Zmc2V0IFswMDAxNmEwMF0NCiBu
aXU6IFZQRF9TQ0FOOiBzdGFydFsxNmExNF0gZW5kWzE2Yjk4XQ0KIG5pdTogVlBEX1NDQU46IFJl
YWRpbmcgaW4gcHJvcGVydHkgW2xvY2FsLW1hYy1hZGRyZXNzXSBsZW5bNl0NCiBuaXU6IFZQRF9T
Q0FOOiBSZWFkaW5nIGluIHByb3BlcnR5IFt2ZXJzaW9uXSBsZW5bMzhdDQogbml1OiBWUERfU0NB
TjogUmVhZGluZyBpbiBwcm9wZXJ0eSBbbW9kZWxdIGxlblsxNF0NCiBuaXU6IFZQRF9TQ0FOOiBS
ZWFkaW5nIGluIHByb3BlcnR5IFtib2FyZC1tb2RlbF0gbGVuWzEyXQ0KIG5pdTogVlBEX1NDQU46
IFJlYWRpbmcgaW4gcHJvcGVydHkgW251bS1tYWMtYWRkcmVzc2VzXSBsZW5bMV0NCiBuaXU6IFZQ
RF9TQ0FOOiBSZWFkaW5nIGluIHByb3BlcnR5IFtwaHktdHlwZV0gbGVuWzRdDQogbml1OiBWUERf
U0NBTjogRkNPREUgbWFqb3IoMykgbWlub3IoOSkNCiBuaXU6IG5pdV9nZXRfYW5kX3ZhbGlkYXRl
X3BvcnQ6IHBvcnRbMV0gbnVtX3BvcnRzWzRdDQogbml1OiBuaXVfcHJvYmVfcG9ydHMoKTogcG9y
dF9waHlbMDAwMDAwYWFdDQogbml1OiBuaXVfY2xhc3NpZmllcl9zd3N0YXRlX2luaXQ6IG51bV90
Y2FtKDI1NikNCiBuaXUgMDAwMDowYjowMC4yOiBQQ0kgSU5UIEMgLT4gR1NJIDE4IChsZXZlbCwg
bG93KSAtPiBJUlEgMTgNCiBuaXU6IG5pdV9nZXRfcGFyZW50OiBwbGF0Zm9ybV90eXBlWzFdIHBv
cnRbMl0NCiBuaXUgMDAwMDowYjowMC4yOiBzZXR0aW5nIGxhdGVuY3kgdGltZXIgdG8gNjQNCiBu
aXU6IG5pdV9nZXRfaW52YXJpYW50czogVlBEIG9mZnNldCBbMDAwMTZhMDBdDQogbml1OiBWUERf
U0NBTjogc3RhcnRbMTZhMTRdIGVuZFsxNmI5OF0NCiBuaXU6IFZQRF9TQ0FOOiBSZWFkaW5nIGlu
IHByb3BlcnR5IFtsb2NhbC1tYWMtYWRkcmVzc10gbGVuWzZdDQogbml1OiBWUERfU0NBTjogUmVh
ZGluZyBpbiBwcm9wZXJ0eSBbdmVyc2lvbl0gbGVuWzM4XQ0KIG5pdTogVlBEX1NDQU46IFJlYWRp
bmcgaW4gcHJvcGVydHkgW21vZGVsXSBsZW5bMTRdDQogbml1OiBWUERfU0NBTjogUmVhZGluZyBp
biBwcm9wZXJ0eSBbYm9hcmQtbW9kZWxdIGxlblsxMl0NCiBuaXU6IFZQRF9TQ0FOOiBSZWFkaW5n
IGluIHByb3BlcnR5IFtudW0tbWFjLWFkZHJlc3Nlc10gbGVuWzFdDQogbml1OiBWUERfU0NBTjog
UmVhZGluZyBpbiBwcm9wZXJ0eSBbcGh5LXR5cGVdIGxlbls0XQ0KIG5pdTogVlBEX1NDQU46IEZD
T0RFIG1ham9yKDMpIG1pbm9yKDkpDQogbml1OiBuaXVfZ2V0X2FuZF92YWxpZGF0ZV9wb3J0OiBw
b3J0WzJdIG51bV9wb3J0c1s0XQ0KIG5pdTogbml1X3Byb2JlX3BvcnRzKCk6IHBvcnRfcGh5WzAw
MDAwMGFhXQ0KIG5pdTogbml1X2NsYXNzaWZpZXJfc3dzdGF0ZV9pbml0OiBudW1fdGNhbSgyNTYp
DQogbml1IDAwMDA6MGI6MDAuMzogUENJIElOVCBEIC0+IEdTSSAxOSAobGV2ZWwsIGxvdykgLT4g
SVJRIDE5DQogbml1OiBuaXVfZ2V0X3BhcmVudDogcGxhdGZvcm1fdHlwZVsxXSBwb3J0WzNdDQog
bml1IDAwMDA6MGI6MDAuMzogc2V0dGluZyBsYXRlbmN5IHRpbWVyIHRvIDY0DQogbml1OiBuaXVf
Z2V0X2ludmFyaWFudHM6IFZQRCBvZmZzZXQgWzAwMDE2YTAwXQ0KIG5pdTogVlBEX1NDQU46IHN0
YXJ0WzE2YTE0XSBlbmRbMTZiOThdDQogbml1OiBWUERfU0NBTjogUmVhZGluZyBpbiBwcm9wZXJ0
eSBbbG9jYWwtbWFjLWFkZHJlc3NdIGxlbls2XQ0KIG5pdTogVlBEX1NDQU46IFJlYWRpbmcgaW4g
cHJvcGVydHkgW3ZlcnNpb25dIGxlblszOF0NCiBuaXU6IFZQRF9TQ0FOOiBSZWFkaW5nIGluIHBy
b3BlcnR5IFttb2RlbF0gbGVuWzE0XQ0KIG5pdTogVlBEX1NDQU46IFJlYWRpbmcgaW4gcHJvcGVy
dHkgW2JvYXJkLW1vZGVsXSBsZW5bMTJdDQogbml1OiBWUERfU0NBTjogUmVhZGluZyBpbiBwcm9w
ZXJ0eSBbbnVtLW1hYy1hZGRyZXNzZXNdIGxlblsxXQ0KIG5pdTogVlBEX1NDQU46IFJlYWRpbmcg
aW4gcHJvcGVydHkgW3BoeS10eXBlXSBsZW5bNF0NCiBuaXU6IFZQRF9TQ0FOOiBGQ09ERSBtYWpv
cigzKSBtaW5vcig5KQ0KIG5pdTogbml1X2dldF9hbmRfdmFsaWRhdGVfcG9ydDogcG9ydFszXSBu
dW1fcG9ydHNbNF0NCiBuaXU6IG5pdV9wcm9iZV9wb3J0cygpOiBwb3J0X3BoeVswMDAwMDBhYV0N
CiBuaXU6IG5pdV9jbGFzc2lmaWVyX3N3c3RhdGVfaW5pdDogbnVtX3RjYW0oMjU2KQ0KIG5pdTog
ZXRoMjogTGluayBpcyB1cCBhdCAxR2Ivc2VjLCBmdWxsIGR1cGxleA0KIG5pdTogZXRoMzogTGlu
ayBpcyB1cCBhdCAxR2Ivc2VjLCBmdWxsIGR1cGxleA0K


--=-HrnHZKl2mJa1xZtRGZkE--
