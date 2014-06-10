From: Florian Klink <flokli@flokli.de>
Subject: Re: cdc-wdm: unable to connect after suspend
Date: Tue, 10 Jun 2014 16:14:18 +0200
Message-ID: <539712BA.5010004@flokli.de>
References: <ln6m4k$q49$1@ger.gmane.org> <874mzt55kz.fsf@nemi.mork.no> <53971171.5070001@flokli.de>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="6H8QH1uc460EQOISKV9oJtuhX815IPsbN"
Cc: netdev@vger.kernel.org, modemmanager-devel@lists.freedesktop.org
To: =?UTF-8?B?QmrDuHJuIE1vcms=?= <bjorn@mork.no>
Return-path: <netdev-owner@vger.kernel.org>
Received: from asterix.flokli.de ([78.46.104.9]:46498 "EHLO asterix.flokli.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751163AbaFJOOY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 10 Jun 2014 10:14:24 -0400
In-Reply-To: <53971171.5070001@flokli.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--6H8QH1uc460EQOISKV9oJtuhX815IPsbN
Content-Type: multipart/mixed;
 boundary="------------070802000401000606060402"

This is a multi-part message in MIME format.
--------------070802000401000606060402
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

Am 10.06.2014 16:08, schrieb Florian Klink:
> Am 10.06.2014 14:09, schrieb Bj=C3=83=C5=BErn Mork:
>> Florian Klink <flokli@flokli.de> writes:
>>
>>> Hi,
>>>
>>> I recently bought a notebook (Fujitsu Lifebook T904) with integrated
>>> 3G/4G modem (Sierra Wireless EM7305) thats powered by the cdc-wdm dri=
ver.
>>>
>>> It works without any problems on a fresh bootup using Networkmanager.=

>>>
>>> However, after putting the notebook into standby and waking up again,=

>>> I'm unable to get a connection (always reproducible, not signal quali=
ty
>>> related).
>>
>> Does it work again if you restart NetworkManager and ModemManager at
>> this point?
>=20
> Nope. ModemManager gets confused completely and drops the modem out of
> the list of connections:
>=20
> ModemManager[3067]: <warn>  Couldn't find support for device at
> '/sys/devices/pci0000:00/0000:00:19.0': not supported by any plugin
> ModemManager[3067]: <warn>  Couldn't find support for device at
> '/sys/devices/pci0000:00/0000:00:1c.3/0000:03:00.0': not supported by
> any plugin
> ModemManager[3067]: [/dev/cdc-wdm1] Queried max control message size: 4=
096
> ModemManager[3067]: [/dev/cdc-wdm1] No transaction matched in received
> message
> ModemManager[3067]: [/dev/cdc-wdm1] No transaction matched in received
> message
> ModemManager[3067]: [/dev/cdc-wdm1] No transaction matched in received
> message
> ModemManager[3067]: [/dev/cdc-wdm1] No transaction matched in received
> message
> ModemManager[3067]: [/dev/cdc-wdm1] No transaction matched in received
> message
> ModemManager[3067]: [/dev/cdc-wdm1] No transaction matched in received
> message
> ModemManager[3067]: [/dev/cdc-wdm1] No transaction matched in received
> message
> ModemManager[3067]: [/dev/cdc-wdm1] No transaction matched in received
> message
> ModemManager[3067]: [/dev/cdc-wdm1] No transaction matched in received
> message
> ModemManager[3067]: [/dev/cdc-wdm1] No transaction matched in received
> message
> ModemManager[3067]: <info>  Creating modem with plugin 'Generic' and '2=
'
> ports
> ModemManager[3067]: <warn>  Could not grab port (usbmisc/cdc-wdm1):
> 'Cannot add port 'usbmisc/cdc-wdm1', unsupported'
> ModemManager[3067]: <warn>  Couldn't create modem for device at
> '/sys/devices/pci0000:00/0000:00:14.0/usb1/1-6': Failed to find primary=

> AT port
> ModemManager[3067]: <info>  Creating modem with plugin 'Generic' and '1=
'
> ports
> ModemManager[3067]: <warn>  Could not grab port (tty/ttyS0): 'Cannot ad=
d
> port 'tty/ttyS0', unhandled serial type'
> ModemManager[3067]: <warn>  Couldn't create modem for device at
> '/sys/devices/pci0000:00/0000:00:16.3': Failed to find primary AT port
>=20
>>
>> Does it help to do
>>
>>  echo  0 >/sys/bus/usb/devices/x-y/power/persist
>>
>> prior to suspending the notebook?  You'll have to replace "x-y" with t=
he
>> correct USB bus and port number.  You can find this in e.g. the dmesg
>> output.  For example, if your log shows:
>>
>>   qmi_wwan 2-4:1.8: cdc-wdm0: USB WDM device
>>
>> then x-y =3D 2-4.
>=20
> dmesg shows "cdc_mbim 1-6:2.12: cdc-wdm1: USB WDM device", so I did ech=
o
> 0 > /sys/bus/usb/devices/1-6/power/persist.
>=20
> However, after a suspend/resume cycle, connecting didnt work either.
> Errors were the same as without persist =3D 0.
>=20
>>
>>
>>> I see the following error messages:
>>>
>>>
>>> Couldn't reload current power state: Transaction timed out
>>> [/dev/cdc-wdm1] No transaction matched in received message
>>> <warn> (cdc-wdm1) failed to connect modem: Transaction timed out
>>> <info> (cdc-wdm1): device state change: prepare -> failed (reason
>>> 'unknown') [40 120 1]
>>> modem_prepare_result: assertion 'state =3D=3D NM_DEVICE_STATE_PREPARE=
' failed
>>>
>>>
>>> It looks like a driver bug for me, like the device not woken up
>>> correctly. I attached the syslog.
>>
>> It is certainly bad interaction between userspace and the driver.  We'=
ll
>> have to fight about where the bug is :-)
>>
>> I believe the problem is that the modem is powered down when the
>> notebook is suspended, combined with the "USB device persistence"
>> feature and bad handling of "unexpected" states in ModemManager.
>> The result is that MM and the device/driver ends up with different vie=
ws
>> of the current modem state. But I might be completely wrong here.
>> Seeing kernel logs would have helped.
>=20
> dmesg doesn't really show an error message from the modem. Seems like i=
t
> also has an issue resuming "Bus 001 Device 006: ID 0483:91d1
> STMicroelectronics", but this shouldn't cause the problems with the mod=
em...

I attached the dmesg output, probably there's till something interesting
inside ;-)
> .
>>
>> Initially I'd like to claim that this is a userspace problem.  But I'm=

>> open to reconsider that view, given convincing arguments. It's not my
>> intention to reject this as "someone elses problem".
>>
>> A short explanation of what's going on: The "USB device persistence"
>> feature just cannot work with 3G/LTE modem devices because they lose
>> necessary internal state on any power loss.  The persist feature makes=

>> the modem reappear as exact the same device after resume, but with a
>> case of severe amnesia.  So why don't we just disable the feature when=

>> it cannot work? The reason is that modems often are composite devices,=

>> and many of them include card reader functions. USB device persistence=
s
>> is critical for such devices. Consider suspending a card reader with a=

>> mounted file system...
>>
>> For this reason I really do not want to disable the persist feature,
>> even if it is pointless from a standalone modem point of view.  Instea=
d
>> userspace should be able to cope with modems "suddendly" entering
>> unexpected states.
>>
>>> I'm running Arch Linux amd64 with an 3.15.0-rc8 kernel, and
>>> NetworkManager 0.9.8.10.
>>>
>>> Is there anybody else who observed this behaviour?
>>
>> Yes, I must admit I've seen similar behaviour.  The interaction betwee=
n
>> system suspend and drivers/MM/NM is not good.
>>
>> Could you please bring this up on the ModemManager list?
>=20
> I added modemmanager-devel to CC as suggested :-)
>>
>>
>> Bj=C3=B8rn
>>
> Florian
>=20
>=20
>=20
>=20
>=20
>=20


--------------070802000401000606060402
Content-Type: text/plain; charset=UTF-8;
 name="cdc-wdm_dmesg.txt"
Content-Transfer-Encoding: base64
Content-Disposition: attachment;
 filename="cdc-wdm_dmesg.txt"

WyAgMjYwLjc5Mjc1N10gUE06IFN5bmNpbmcgZmlsZXN5c3RlbXMgLi4uIGRvbmUuClsgIDI2
MC44MDI0MDddIFBNOiBQcmVwYXJpbmcgc3lzdGVtIGZvciBtZW0gc2xlZXAKWyAgMjYwLjgw
MjY2OV0gRnJlZXppbmcgdXNlciBzcGFjZSBwcm9jZXNzZXMgLi4uIChlbGFwc2VkIDAuMjcy
IHNlY29uZHMpIGRvbmUuClsgIDI2MS4wNzQ4NDldIEZyZWV6aW5nIHJlbWFpbmluZyBmcmVl
emFibGUgdGFza3MgLi4uIChlbGFwc2VkIDAuMDAxIHNlY29uZHMpIGRvbmUuClsgIDI2MS4w
NzU5OTZdIFBNOiBFbnRlcmluZyBtZW0gc2xlZXAKWyAgMjYxLjA3NjA4NF0gU3VzcGVuZGlu
ZyBjb25zb2xlKHMpICh1c2Ugbm9fY29uc29sZV9zdXNwZW5kIHRvIGRlYnVnKQpbICAyNjEu
MDc2NDU4XSBzZCAwOjA6MDowOiBbc2RhXSBTeW5jaHJvbml6aW5nIFNDU0kgY2FjaGUKWyAg
MjYxLjA3NzM5NF0gc2QgMDowOjA6MDogW3NkYV0gU3RvcHBpbmcgZGlzawpbICAyNjEuMzA2
NTcwXSBQTTogc3VzcGVuZCBvZiBkZXZpY2VzIGNvbXBsZXRlIGFmdGVyIDIzMC40NjIgbXNl
Y3MKWyAgMjYxLjMxOTg5OV0gUE06IGxhdGUgc3VzcGVuZCBvZiBkZXZpY2VzIGNvbXBsZXRl
IGFmdGVyIDEzLjMzMSBtc2VjcwpbICAyNjEuMzIwODA4XSB4aGNpX2hjZCAwMDAwOjAwOjE0
LjA6IFN5c3RlbSB3YWtldXAgZW5hYmxlZCBieSBBQ1BJClsgIDI2MS4zMzM0MzldIFBNOiBu
b2lycSBzdXNwZW5kIG9mIGRldmljZXMgY29tcGxldGUgYWZ0ZXIgMTMuNTQxIG1zZWNzClsg
IDI2MS4zMzM4MTNdIEFDUEk6IFByZXBhcmluZyB0byBlbnRlciBzeXN0ZW0gc2xlZXAgc3Rh
dGUgUzMKWyAgMjYxLjMzNDE5Ml0gUE06IFNhdmluZyBwbGF0Zm9ybSBOVlMgbWVtb3J5Clsg
IDI2MS4zMzUxNzBdIERpc2FibGluZyBub24tYm9vdCBDUFVzIC4uLgpbICAyNjEuMzM1MjEw
XSBpbnRlbF9wc3RhdGUgQ1BVIDEgZXhpdGluZwpbICAyNjEuMzM2NDAyXSBrdm06IGRpc2Fi
bGluZyB2aXJ0dWFsaXphdGlvbiBvbiBDUFUxClsgIDI2MS40MzY0ODNdIHNtcGJvb3Q6IENQ
VSAxIGlzIG5vdyBvZmZsaW5lClsgIDI2MS40MzY3NzBdIGludGVsX3BzdGF0ZSBDUFUgMiBl
eGl0aW5nClsgIDI2MS40Mzc5MjZdIGt2bTogZGlzYWJsaW5nIHZpcnR1YWxpemF0aW9uIG9u
IENQVTIKWyAgMjYxLjUzOTc4OF0gc21wYm9vdDogQ1BVIDIgaXMgbm93IG9mZmxpbmUKWyAg
MjYxLjU0MDA4M10gaW50ZWxfcHN0YXRlIENQVSAzIGV4aXRpbmcKWyAgMjYxLjU0MTQwM10g
a3ZtOiBkaXNhYmxpbmcgdmlydHVhbGl6YXRpb24gb24gQ1BVMwpbICAyNjEuNjQzMDg4XSBz
bXBib290OiBDUFUgMyBpcyBub3cgb2ZmbGluZQpbICAyNjEuNjQ1ODk0XSBBQ1BJOiBMb3ct
bGV2ZWwgcmVzdW1lIGNvbXBsZXRlClsgIDI2MS42NDU5NTldIFBNOiBSZXN0b3JpbmcgcGxh
dGZvcm0gTlZTIG1lbW9yeQpbICAyNjEuNjQ2NTUyXSBFbmFibGluZyBub24tYm9vdCBDUFVz
IC4uLgpbICAyNjEuNjQ2NTg4XSB4ODY6IEJvb3RpbmcgU01QIGNvbmZpZ3VyYXRpb246Clsg
IDI2MS42NDY1ODldIHNtcGJvb3Q6IEJvb3RpbmcgTm9kZSAwIFByb2Nlc3NvciAxIEFQSUMg
MHgxClsgIDI2MS42NTg4NjZdIGt2bTogZW5hYmxpbmcgdmlydHVhbGl6YXRpb24gb24gQ1BV
MQpbICAyNjEuNjYxMDgwXSBJbnRlbCBwc3RhdGUgY29udHJvbGxpbmc6IGNwdSAxClsgIDI2
MS42NjExMzZdIENQVTEgaXMgdXAKWyAgMjYxLjY2MTE1M10gc21wYm9vdDogQm9vdGluZyBO
b2RlIDAgUHJvY2Vzc29yIDIgQVBJQyAweDIKWyAgMjYxLjY3MzIyOV0ga3ZtOiBlbmFibGlu
ZyB2aXJ0dWFsaXphdGlvbiBvbiBDUFUyClsgIDI2MS42NzUzODVdIEludGVsIHBzdGF0ZSBj
b250cm9sbGluZzogY3B1IDIKWyAgMjYxLjY3NTQzMl0gQ1BVMiBpcyB1cApbICAyNjEuNjc1
NDQ1XSBzbXBib290OiBCb290aW5nIE5vZGUgMCBQcm9jZXNzb3IgMyBBUElDIDB4MwpbICAy
NjEuNjg3NDYyXSBrdm06IGVuYWJsaW5nIHZpcnR1YWxpemF0aW9uIG9uIENQVTMKWyAgMjYx
LjY4OTY4NF0gSW50ZWwgcHN0YXRlIGNvbnRyb2xsaW5nOiBjcHUgMwpbICAyNjEuNjg5NzMx
XSBDUFUzIGlzIHVwClsgIDI2MS42OTM5MzJdIEFDUEk6IFdha2luZyB1cCBmcm9tIHN5c3Rl
bSBzbGVlcCBzdGF0ZSBTMwpbICAyNjEuNzEwMzkxXSB4aGNpX2hjZCAwMDAwOjAwOjE0LjA6
IFN5c3RlbSB3YWtldXAgZGlzYWJsZWQgYnkgQUNQSQpbICAyNjEuNzEwNDg0XSBQTTogbm9p
cnEgcmVzdW1lIG9mIGRldmljZXMgY29tcGxldGUgYWZ0ZXIgMTEuNzk0IG1zZWNzClsgIDI2
MS43MTA3MTFdIFBNOiBlYXJseSByZXN1bWUgb2YgZGV2aWNlcyBjb21wbGV0ZSBhZnRlciAw
LjIwNSBtc2VjcwpbICAyNjEuNzEwODE3XSBzbmRfaGRhX2ludGVsIDAwMDA6MDA6MDMuMDog
aXJxIDYxIGZvciBNU0kvTVNJLVgKWyAgMjYxLjcxMTAzMV0gbWVpX21lIDAwMDA6MDA6MTYu
MDogaXJxIDYyIGZvciBNU0kvTVNJLVgKWyAgMjYxLjcxMTE1NV0gc25kX2hkYV9pbnRlbCAw
MDAwOjAwOjFiLjA6IGlycSA2MyBmb3IgTVNJL01TSS1YClsgIDI2MS43MjI2MzNdIHNkIDA6
MDowOjA6IFtzZGFdIFN0YXJ0aW5nIGRpc2sKWyAgMjYxLjgxNTk0Nl0gdHBtX3RpcyAwMDow
ODogVFBNIGlzIGRpc2FibGVkL2RlYWN0aXZhdGVkICgweDcpClsgIDI2Mi4wMjU3NTJdIGUx
MDAwZSAwMDAwOjAwOjE5LjA6IGlycSA2NiBmb3IgTVNJL01TSS1YClsgIDI2Mi4yMTU5OTVd
IHVzYiAxLTc6IHJlc2V0IGZ1bGwtc3BlZWQgVVNCIGRldmljZSBudW1iZXIgNSB1c2luZyB4
aGNpX2hjZApbICAyNjIuMjE2MDYwXSB4aGNpX2hjZCAwMDAwOjAwOjE0LjA6IFNldHVwIEVS
Uk9SOiBzZXR1cCBjb250ZXh0IGNvbW1hbmQgZm9yIHNsb3QgNC4KWyAgMjYyLjIxNjA2Ml0g
dXNiIDEtNzogaHViIGZhaWxlZCB0byBlbmFibGUgZGV2aWNlLCBlcnJvciAtMjIKWyAgMjYy
LjM3NTc1MF0gdXNiIDEtNzogcmVzZXQgZnVsbC1zcGVlZCBVU0IgZGV2aWNlIG51bWJlciA1
IHVzaW5nIHhoY2lfaGNkClsgIDI2Mi4zNzU4MzFdIHhoY2lfaGNkIDAwMDA6MDA6MTQuMDog
U2V0dXAgRVJST1I6IHNldHVwIGNvbnRleHQgY29tbWFuZCBmb3Igc2xvdCA0LgpbICAyNjIu
Mzc1ODMyXSB1c2IgMS03OiBodWIgZmFpbGVkIHRvIGVuYWJsZSBkZXZpY2UsIGVycm9yIC0y
MgpbICAyNjIuNTM1NjkyXSB1c2IgMS03OiByZXNldCBmdWxsLXNwZWVkIFVTQiBkZXZpY2Ug
bnVtYmVyIDUgdXNpbmcgeGhjaV9oY2QKWyAgMjYyLjU0OTcwMF0geGhjaV9oY2QgMDAwMDow
MDoxNC4wOiB4SENJIHhoY2lfZHJvcF9lbmRwb2ludCBjYWxsZWQgd2l0aCBkaXNhYmxlZCBl
cCBmZmZmODgwMDM3OTQwMDAwClsgIDI2Mi41NDk3MDFdIHhoY2lfaGNkIDAwMDA6MDA6MTQu
MDogeEhDSSB4aGNpX2Ryb3BfZW5kcG9pbnQgY2FsbGVkIHdpdGggZGlzYWJsZWQgZXAgZmZm
Zjg4MDAzNzk0MDA0OApbICAyNjIuNTQ5NzAyXSB4aGNpX2hjZCAwMDAwOjAwOjE0LjA6IHhI
Q0kgeGhjaV9kcm9wX2VuZHBvaW50IGNhbGxlZCB3aXRoIGRpc2FibGVkIGVwIGZmZmY4ODAw
Mzc5NDAwOTAKWyAgMjYyLjU0OTcwM10geGhjaV9oY2QgMDAwMDowMDoxNC4wOiB4SENJIHho
Y2lfZHJvcF9lbmRwb2ludCBjYWxsZWQgd2l0aCBkaXNhYmxlZCBlcCBmZmZmODgwMjExMTUx
NzgwClsgIDI2Mi41NDk3MDRdIHhoY2lfaGNkIDAwMDA6MDA6MTQuMDogeEhDSSB4aGNpX2Ry
b3BfZW5kcG9pbnQgY2FsbGVkIHdpdGggZGlzYWJsZWQgZXAgZmZmZjg4MDIxMTE1MTdjOApb
ICAyNjIuNzA5MTYwXSB1c2IgMS01OiByZXNldCBoaWdoLXNwZWVkIFVTQiBkZXZpY2UgbnVt
YmVyIDQgdXNpbmcgeGhjaV9oY2QKWyAgMjYyLjcwOTIzOF0geGhjaV9oY2QgMDAwMDowMDox
NC4wOiBTZXR1cCBFUlJPUjogc2V0dXAgY29udGV4dCBjb21tYW5kIGZvciBzbG90IDMuClsg
IDI2Mi43MDkyNDBdIHVzYiAxLTU6IGh1YiBmYWlsZWQgdG8gZW5hYmxlIGRldmljZSwgZXJy
b3IgLTIyClsgIDI2Mi44Njg5NDhdIHVzYiAxLTU6IHJlc2V0IGhpZ2gtc3BlZWQgVVNCIGRl
dmljZSBudW1iZXIgNCB1c2luZyB4aGNpX2hjZApbICAyNjIuODY5MDQ3XSB4aGNpX2hjZCAw
MDAwOjAwOjE0LjA6IFNldHVwIEVSUk9SOiBzZXR1cCBjb250ZXh0IGNvbW1hbmQgZm9yIHNs
b3QgMy4KWyAgMjYyLjg2OTA2MV0gdXNiIDEtNTogaHViIGZhaWxlZCB0byBlbmFibGUgZGV2
aWNlLCBlcnJvciAtMjIKWyAgMjYzLjAyODg3NV0gdXNiIDEtNTogcmVzZXQgaGlnaC1zcGVl
ZCBVU0IgZGV2aWNlIG51bWJlciA0IHVzaW5nIHhoY2lfaGNkClsgIDI2My4wNDI4NjFdIHho
Y2lfaGNkIDAwMDA6MDA6MTQuMDogeEhDSSB4aGNpX2Ryb3BfZW5kcG9pbnQgY2FsbGVkIHdp
dGggZGlzYWJsZWQgZXAgZmZmZjg4MDIxMTVlYWEyMApbICAyNjMuMTg1NDU5XSBbZHJtXSBF
bmFibGluZyBSQzYgc3RhdGVzOiBSQzYgb24sIFJDNnAgb2ZmLCBSQzZwcCBvZmYKWyAgMjYz
LjIwMjI1OV0gdXNiIDEtNDogcmVzZXQgZnVsbC1zcGVlZCBVU0IgZGV2aWNlIG51bWJlciAz
IHVzaW5nIHhoY2lfaGNkClsgIDI2My4yMDIyNjZdIHhoY2lfaGNkIDAwMDA6MDA6MTQuMDog
U2V0dXAgRVJST1I6IHNldHVwIGNvbnRleHQgY29tbWFuZCBmb3Igc2xvdCAyLgpbICAyNjMu
MjAyMjY2XSB1c2IgMS00OiBodWIgZmFpbGVkIHRvIGVuYWJsZSBkZXZpY2UsIGVycm9yIC0y
MgpbICAyNjMuMzYyMDk5XSB1c2IgMS00OiByZXNldCBmdWxsLXNwZWVkIFVTQiBkZXZpY2Ug
bnVtYmVyIDMgdXNpbmcgeGhjaV9oY2QKWyAgMjYzLjM2MjE0Nl0geGhjaV9oY2QgMDAwMDow
MDoxNC4wOiBTZXR1cCBFUlJPUjogc2V0dXAgY29udGV4dCBjb21tYW5kIGZvciBzbG90IDIu
ClsgIDI2My4zNjIxNDddIHVzYiAxLTQ6IGh1YiBmYWlsZWQgdG8gZW5hYmxlIGRldmljZSwg
ZXJyb3IgLTIyClsgIDI2My41MTg2ODddIGF0YTE6IFNBVEEgbGluayB1cCA2LjAgR2JwcyAo
U1N0YXR1cyAxMzMgU0NvbnRyb2wgMzAwKQpbICAyNjMuNTE4OTczXSBhdGExLjAwOiBBQ1BJ
IGNtZCBmNS8wMDowMDowMDowMDowMDphMCAoU0VDVVJJVFkgRlJFRVpFIExPQ0spIGZpbHRl
cmVkIG91dApbICAyNjMuNTE4OTc0XSBhdGExLjAwOiBBQ1BJIGNtZCBiMS9jMTowMDowMDow
MDowMDphMCAoREVWSUNFIENPTkZJR1VSQVRJT04gT1ZFUkxBWSkgZmlsdGVyZWQgb3V0Clsg
IDI2My41MTkxNDldIGF0YTEuMDA6IEFDUEkgY21kIGVmLzEwOjA5OjAwOjAwOjAwOmIwIChT
RVQgRkVBVFVSRVMpIHN1Y2NlZWRlZApbICAyNjMuNTIwMDI3XSBhdGExLjAwOiBBQ1BJIGNt
ZCBmNS8wMDowMDowMDowMDowMDphMCAoU0VDVVJJVFkgRlJFRVpFIExPQ0spIGZpbHRlcmVk
IG91dApbICAyNjMuNTIwMDI5XSBhdGExLjAwOiBBQ1BJIGNtZCBiMS9jMTowMDowMDowMDow
MDphMCAoREVWSUNFIENPTkZJR1VSQVRJT04gT1ZFUkxBWSkgZmlsdGVyZWQgb3V0ClsgIDI2
My41MjAxNThdIGF0YTEuMDA6IEFDUEkgY21kIGVmLzEwOjA5OjAwOjAwOjAwOmIwIChTRVQg
RkVBVFVSRVMpIHN1Y2NlZWRlZApbICAyNjMuNTIwNTQ5XSBhdGExLjAwOiBjb25maWd1cmVk
IGZvciBVRE1BLzEwMApbICAyNjMuNTI1MzE5XSB1c2IgMS00OiByZXNldCBmdWxsLXNwZWVk
IFVTQiBkZXZpY2UgbnVtYmVyIDMgdXNpbmcgeGhjaV9oY2QKWyAgMjYzLjUzMTk1NV0gYWhj
aSAwMDAwOjAwOjFmLjI6IHBvcnQgZG9lcyBub3Qgc3VwcG9ydCBkZXZpY2Ugc2xlZXAKWyAg
MjYzLjUzOTQ3MV0geGhjaV9oY2QgMDAwMDowMDoxNC4wOiB4SENJIHhoY2lfZHJvcF9lbmRw
b2ludCBjYWxsZWQgd2l0aCBkaXNhYmxlZCBlcCBmZmZmODgwMjExNWVhOTYwClsgIDI2My41
Mzk0NzNdIHhoY2lfaGNkIDAwMDA6MDA6MTQuMDogeEhDSSB4aGNpX2Ryb3BfZW5kcG9pbnQg
Y2FsbGVkIHdpdGggZGlzYWJsZWQgZXAgZmZmZjg4MDIxMTVlYTljMApbICAyNjMuNjk4ODc2
XSB1c2IgMS04OiByZXNldCBmdWxsLXNwZWVkIFVTQiBkZXZpY2UgbnVtYmVyIDYgdXNpbmcg
eGhjaV9oY2QKWyAgMjYzLjY5ODkxMF0geGhjaV9oY2QgMDAwMDowMDoxNC4wOiBTZXR1cCBF
UlJPUjogc2V0dXAgY29udGV4dCBjb21tYW5kIGZvciBzbG90IDUuClsgIDI2My42OTg5MjBd
IHVzYiAxLTg6IGh1YiBmYWlsZWQgdG8gZW5hYmxlIGRldmljZSwgZXJyb3IgLTIyClsgIDI2
My44NTg2NDVdIHVzYiAxLTg6IHJlc2V0IGZ1bGwtc3BlZWQgVVNCIGRldmljZSBudW1iZXIg
NiB1c2luZyB4aGNpX2hjZApbICAyNjMuODU4NjY2XSB4aGNpX2hjZCAwMDAwOjAwOjE0LjA6
IFNldHVwIEVSUk9SOiBzZXR1cCBjb250ZXh0IGNvbW1hbmQgZm9yIHNsb3QgNS4KWyAgMjYz
Ljg1ODY2Nl0gdXNiIDEtODogaHViIGZhaWxlZCB0byBlbmFibGUgZGV2aWNlLCBlcnJvciAt
MjIKWyAgMjY0LjAxODY4Nl0gdXNiIDEtODogcmVzZXQgZnVsbC1zcGVlZCBVU0IgZGV2aWNl
IG51bWJlciA2IHVzaW5nIHhoY2lfaGNkClsgIDI2NC4wMzI2NDVdIHhoY2lfaGNkIDAwMDA6
MDA6MTQuMDogeEhDSSB4aGNpX2Ryb3BfZW5kcG9pbnQgY2FsbGVkIHdpdGggZGlzYWJsZWQg
ZXAgZmZmZjg4MDIxMTVlYWFlMApbICAyNjQuMDk4OTg0XSB1c2IgMS01LjE6IHJlc2V0IGhp
Z2gtc3BlZWQgVVNCIGRldmljZSBudW1iZXIgNyB1c2luZyB4aGNpX2hjZApbICAyNjQuMDk4
OTk2XSB4aGNpX2hjZCAwMDAwOjAwOjE0LjA6IFNldHVwIEVSUk9SOiBzZXR1cCBjb250ZXh0
IGNvbW1hbmQgZm9yIHNsb3QgNi4KWyAgMjY0LjA5ODk5OF0gdXNiIDEtNS4xOiBodWIgZmFp
bGVkIHRvIGVuYWJsZSBkZXZpY2UsIGVycm9yIC0yMgpbICAyNjQuMTY1NDg4XSB1c2IgMS01
LjE6IHJlc2V0IGhpZ2gtc3BlZWQgVVNCIGRldmljZSBudW1iZXIgNyB1c2luZyB4aGNpX2hj
ZApbICAyNjQuMTY1NTA1XSB4aGNpX2hjZCAwMDAwOjAwOjE0LjA6IFNldHVwIEVSUk9SOiBz
ZXR1cCBjb250ZXh0IGNvbW1hbmQgZm9yIHNsb3QgNi4KWyAgMjY0LjE2NTUwN10gdXNiIDEt
NS4xOiBodWIgZmFpbGVkIHRvIGVuYWJsZSBkZXZpY2UsIGVycm9yIC0yMgpbICAyNjQuMjMy
MTQ1XSB1c2IgMS01LjE6IHJlc2V0IGhpZ2gtc3BlZWQgVVNCIGRldmljZSBudW1iZXIgNyB1
c2luZyB4aGNpX2hjZApbICAyNjQuMzEyMjg5XSB1c2IgMS01LjM6IHJlc2V0IGZ1bGwtc3Bl
ZWQgVVNCIGRldmljZSBudW1iZXIgOSB1c2luZyB4aGNpX2hjZApbICAyNjQuMzEyMzA1XSB4
aGNpX2hjZCAwMDAwOjAwOjE0LjA6IFNldHVwIEVSUk9SOiBzZXR1cCBjb250ZXh0IGNvbW1h
bmQgZm9yIHNsb3QgOC4KWyAgMjY0LjMxMjMwNl0gdXNiIDEtNS4zOiBodWIgZmFpbGVkIHRv
IGVuYWJsZSBkZXZpY2UsIGVycm9yIC0yMgpbICAyNjQuMzIwMDIxXSB4aGNpX2hjZCAwMDAw
OjAwOjE0LjA6IHhIQ0kgeGhjaV9kcm9wX2VuZHBvaW50IGNhbGxlZCB3aXRoIGRpc2FibGVk
IGVwIGZmZmY4ODAyMTE1ZWFhODAKWyAgMjY0LjM3ODY2N10gdXNiIDEtNS4zOiByZXNldCBm
dWxsLXNwZWVkIFVTQiBkZXZpY2UgbnVtYmVyIDkgdXNpbmcgeGhjaV9oY2QKWyAgMjY0LjM3
ODY4MV0geGhjaV9oY2QgMDAwMDowMDoxNC4wOiBTZXR1cCBFUlJPUjogc2V0dXAgY29udGV4
dCBjb21tYW5kIGZvciBzbG90IDguClsgIDI2NC4zNzg2ODNdIHVzYiAxLTUuMzogaHViIGZh
aWxlZCB0byBlbmFibGUgZGV2aWNlLCBlcnJvciAtMjIKWyAgMjY0LjQ0NTQxN10gdXNiIDEt
NS4zOiByZXNldCBmdWxsLXNwZWVkIFVTQiBkZXZpY2UgbnVtYmVyIDkgdXNpbmcgeGhjaV9o
Y2QKWyAgMjY0LjQ1OTIwN10geGhjaV9oY2QgMDAwMDowMDoxNC4wOiB4SENJIHhoY2lfZHJv
cF9lbmRwb2ludCBjYWxsZWQgd2l0aCBkaXNhYmxlZCBlcCBmZmZmODgwMjExNWVhZGUwClsg
IDI2NC40NTkyMjZdIHVzYiAxLTUuMzogZXAgMHg4MSAtIHJvdW5kaW5nIGludGVydmFsIHRv
IDEwMjQgbWljcm9mcmFtZXMsIGVwIGRlc2Mgc2F5cyAyMDQwIG1pY3JvZnJhbWVzClsgIDI2
NC41MjU2MjFdIHVzYiAxLTUuMjogcmVzZXQgZnVsbC1zcGVlZCBVU0IgZGV2aWNlIG51bWJl
ciA4IHVzaW5nIHhoY2lfaGNkClsgIDI2NC41MjU2NDRdIHhoY2lfaGNkIDAwMDA6MDA6MTQu
MDogU2V0dXAgRVJST1I6IHNldHVwIGNvbnRleHQgY29tbWFuZCBmb3Igc2xvdCA3LgpbICAy
NjQuNTI1NjQ3XSB1c2IgMS01LjI6IGh1YiBmYWlsZWQgdG8gZW5hYmxlIGRldmljZSwgZXJy
b3IgLTIyClsgIDI2NC41OTE5NThdIHVzYiAxLTUuMjogcmVzZXQgZnVsbC1zcGVlZCBVU0Ig
ZGV2aWNlIG51bWJlciA4IHVzaW5nIHhoY2lfaGNkClsgIDI2NC41OTE5NzNdIHhoY2lfaGNk
IDAwMDA6MDA6MTQuMDogU2V0dXAgRVJST1I6IHNldHVwIGNvbnRleHQgY29tbWFuZCBmb3Ig
c2xvdCA3LgpbICAyNjQuNTkxOTc1XSB1c2IgMS01LjI6IGh1YiBmYWlsZWQgdG8gZW5hYmxl
IGRldmljZSwgZXJyb3IgLTIyClsgIDI2NC42NTg2MDRdIHVzYiAxLTUuMjogcmVzZXQgZnVs
bC1zcGVlZCBVU0IgZGV2aWNlIG51bWJlciA4IHVzaW5nIHhoY2lfaGNkClsgIDI2NC42NzI2
ODJdIHhoY2lfaGNkIDAwMDA6MDA6MTQuMDogeEhDSSB4aGNpX2Ryb3BfZW5kcG9pbnQgY2Fs
bGVkIHdpdGggZGlzYWJsZWQgZXAgZmZmZjg4MDIxMTcxYmUwMApbICAyNjQuNjcyNjg1XSB4
aGNpX2hjZCAwMDAwOjAwOjE0LjA6IHhIQ0kgeGhjaV9kcm9wX2VuZHBvaW50IGNhbGxlZCB3
aXRoIGRpc2FibGVkIGVwIGZmZmY4ODAyMTE3MWJlNDgKWyAgMjY0LjY3MjY4N10geGhjaV9o
Y2QgMDAwMDowMDoxNC4wOiB4SENJIHhoY2lfZHJvcF9lbmRwb2ludCBjYWxsZWQgd2l0aCBk
aXNhYmxlZCBlcCBmZmZmODgwMjExNzFiZTkwClsgIDI2NC42NzI2ODldIHhoY2lfaGNkIDAw
MDA6MDA6MTQuMDogeEhDSSB4aGNpX2Ryb3BfZW5kcG9pbnQgY2FsbGVkIHdpdGggZGlzYWJs
ZWQgZXAgZmZmZjg4MDIxMTcxYmVkOApbICAyNjQuNzM4NjY5XSB1c2IgMS01LjMuMjogcmVz
ZXQgZnVsbC1zcGVlZCBVU0IgZGV2aWNlIG51bWJlciAxMCB1c2luZyB4aGNpX2hjZApbICAy
NjQuNzM4Njg5XSB4aGNpX2hjZCAwMDAwOjAwOjE0LjA6IFNldHVwIEVSUk9SOiBzZXR1cCBj
b250ZXh0IGNvbW1hbmQgZm9yIHNsb3QgOS4KWyAgMjY0LjczODY5Ml0gdXNiIDEtNS4zLjI6
IGh1YiBmYWlsZWQgdG8gZW5hYmxlIGRldmljZSwgZXJyb3IgLTIyClsgIDI2NC44MDUwNTdd
IHVzYiAxLTUuMy4yOiByZXNldCBmdWxsLXNwZWVkIFVTQiBkZXZpY2UgbnVtYmVyIDEwIHVz
aW5nIHhoY2lfaGNkClsgIDI2NC44MDUwNzddIHhoY2lfaGNkIDAwMDA6MDA6MTQuMDogU2V0
dXAgRVJST1I6IHNldHVwIGNvbnRleHQgY29tbWFuZCBmb3Igc2xvdCA5LgpbICAyNjQuODA1
MDgxXSB1c2IgMS01LjMuMjogaHViIGZhaWxlZCB0byBlbmFibGUgZGV2aWNlLCBlcnJvciAt
MjIKWyAgMjY0Ljg3MTY4NV0gdXNiIDEtNS4zLjI6IHJlc2V0IGZ1bGwtc3BlZWQgVVNCIGRl
dmljZSBudW1iZXIgMTAgdXNpbmcgeGhjaV9oY2QKWyAgMjY0Ljg4NTU3OF0geGhjaV9oY2Qg
MDAwMDowMDoxNC4wOiB4SENJIHhoY2lfZHJvcF9lbmRwb2ludCBjYWxsZWQgd2l0aCBkaXNh
YmxlZCBlcCBmZmZmODgwMDM3OTQwMzkwClsgIDI2NC44ODU1ODFdIHhoY2lfaGNkIDAwMDA6
MDA6MTQuMDogeEhDSSB4aGNpX2Ryb3BfZW5kcG9pbnQgY2FsbGVkIHdpdGggZGlzYWJsZWQg
ZXAgZmZmZjg4MDAzNzk0MDM0OApbICAyNjQuODg1NTg0XSB4aGNpX2hjZCAwMDAwOjAwOjE0
LjA6IHhIQ0kgeGhjaV9kcm9wX2VuZHBvaW50IGNhbGxlZCB3aXRoIGRpc2FibGVkIGVwIGZm
ZmY4ODAwMzc5NDAzMDAKWyAgMjY0Ljg4NTYwN10gdXNiIDEtNS4zLjI6IGVwIDB4ODEgLSBy
b3VuZGluZyBpbnRlcnZhbCB0byAxMDI0IG1pY3JvZnJhbWVzLCBlcCBkZXNjIHNheXMgMjA0
MCBtaWNyb2ZyYW1lcwpbICAyNjQuODg2NDA1XSBQTTogcmVzdW1lIG9mIGRldmljZXMgY29t
cGxldGUgYWZ0ZXIgMzE3Ni44MzQgbXNlY3MKWyAgMjY0Ljg4NzUyOV0gUE06IEZpbmlzaGlu
ZyB3YWtldXAuClsgIDI2NC44ODc1MzFdIFJlc3RhcnRpbmcgdGFza3MgLi4uIGRvbmUuClsg
IDI2NC44OTQxODRdIHZpZGVvIExOWFZJREVPOjAwOiBSZXN0b3JpbmcgYmFja2xpZ2h0IHN0
YXRlClsgIDI2NC44OTk5MTNdIEJsdWV0b290aDogaGNpMDogcmVhZCBJbnRlbCB2ZXJzaW9u
OiAzNzA3MTAwMTgwMDIwMzBkMDAKWyAgMjY0LjkwMTMwOV0gQmx1ZXRvb3RoOiBoY2kwOiBJ
bnRlbCBCbHVldG9vdGggZmlybXdhcmUgZmlsZTogaW50ZWwvaWJ0LWh3LTM3LjcuMTAtZnct
MS44MC4yLjMuZC5ic2VxClsgIDI2NS4wMDQ5MDFdIGUxMDAwZSAwMDAwOjAwOjE5LjA6IGly
cSA2NiBmb3IgTVNJL01TSS1YClsgIDI2NS4wMDg5NTFdIEJsdWV0b290aDogaGNpMDogSW50
ZWwgQmx1ZXRvb3RoIGZpcm13YXJlIHBhdGNoIGNvbXBsZXRlZCBhbmQgYWN0aXZhdGVkClsg
IDI2NS4xMDgwOTddIGUxMDAwZSAwMDAwOjAwOjE5LjA6IGlycSA2NiBmb3IgTVNJL01TSS1Y
ClsgIDI2NS4xMDgyMThdIElQdjY6IEFERFJDT05GKE5FVERFVl9VUCk6IGVucDBzMjU6IGxp
bmsgaXMgbm90IHJlYWR5ClsgIDI2NS4xMDg5NTddIElQdjY6IEFERFJDT05GKE5FVERFVl9V
UCk6IGJyMDogbGluayBpcyBub3QgcmVhZHkKWyAgMzY2LjA0NjU5M10gaXdsd2lmaSAwMDAw
OjAzOjAwLjA6IEwxIEVuYWJsZWQ7IERpc2FibGluZyBMMFMKWyAgMzY2LjA0NjgzMF0gaXds
d2lmaSAwMDAwOjAzOjAwLjA6IEwxIEVuYWJsZWQ7IERpc2FibGluZyBMMFMKWyAgMzY2LjA1
ODAyNF0gSVB2NjogQUREUkNPTkYoTkVUREVWX1VQKTogd2xwM3MwOiBsaW5rIGlzIG5vdCBy
ZWFkeQpbICAzNjkuODQ3ODY3XSB3bHAzczA6IGF1dGhlbnRpY2F0ZSB3aXRoIHh4Onh4Onh4
Onh4Onh4Onh4ClsgIDM2OS44NTAwNTddIHdscDNzMDogc2VuZCBhdXRoIHRvIHl5Onl5Onl5
Onl5Onl5Onl5ICh0cnkgMS8zKQpbICAzNjkuODUxODI5XSB3bHAzczA6IGF1dGhlbnRpY2F0
ZWQKWyAgMzY5Ljg1MjkzM10gd2xwM3MwOiBhc3NvY2lhdGUgd2l0aCB5eTp5eTp5eTp5eTp5
eTp5eSAodHJ5IDEvMykKWyAgMzY5Ljg2MjQ3Ml0gd2xwM3MwOiBSWCBBc3NvY1Jlc3AgZnJv
bSB4eDp4eDp4eDp4eDp4eDp4eCAoY2FwYWI9MHg0MzEgc3RhdHVzPTAgYWlkPTU5KQpbICAz
NjkuODY2Njg2XSB3bHAzczA6IGFzc29jaWF0ZWQKWyAgMzY5Ljg2NjcwNl0gSVB2NjogQURE
UkNPTkYoTkVUREVWX0NIQU5HRSk6IHdscDNzMDogbGluayBiZWNvbWVzIHJlYWR5Cg==
--------------070802000401000606060402--

--6H8QH1uc460EQOISKV9oJtuhX815IPsbN
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAEBAgAGBQJTlxK6AAoJEInyWbj6DRgf2eUP/1qG1ATIH0rXdpGOxgj7wgRX
dvSGk7IoKrdrhTPVdoe3t4pO8BvSr35ioob1kztw+POgkJvXPUYn8gURutNiqGD/
L0nul6lOGxa7a0Fb6+hnhVF/S9R9+Aw5B6150M2Wy9+Bgwu+SnhsS6SonOKe6vnK
MK5uLNCizJO0LZL6+rQ+XGDyfnEfau3k2aYzCwVkwdkM3i+JORFcSsgzrOTPhLxN
uL3+FBsE8CoahrapurGeCaiidtUUVTwUNQX91TXJv1PNdVYsrIIc2DYvP7xkPtI7
uIkqP1PcFr2aGwLTWOealnLAUeQpo+yBoAHFbte+zwI7VqCFyVM/s5JjV8GXxkXo
xgBACJZcTD1U3T7CgAiOKTtyFaTTPpyc27UXT2bDZSH+8kmwnXBONJyzbZtNXx+x
40Q7dgKoNnqhKHLcqLkSwQIGCDNEugQDICVrV7iuEM3VeApUMZ6PKjtkcr0yzlek
/xb0RaxyUZUV3p9GQjRpiwu89DjoQafQCl4htVXzUsGPYdh6IGSm9/kPeemJFsNI
q6+unKed6e6fTMs9LsNJdn25CXSHBzPqhpmvWS1jndkV+bz0MU/d7YwIw4ggnzwD
SZckrbfoVMFp4hO3v/57Rsa90tzTNmQgWjwqPxDz0UBGgGa5lr51j8HQ79KJpXlQ
B8T7lHyNuqCcoiAD12ee
=Ouza
-----END PGP SIGNATURE-----

--6H8QH1uc460EQOISKV9oJtuhX815IPsbN--
