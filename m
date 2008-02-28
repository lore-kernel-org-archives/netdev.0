From: Louis JANG <louis-6CAt/Z4uMM0@public.gmane.org>
Subject: Re: [Bluez-devel] forcing SCO connection patch
Date: Thu, 28 Feb 2008 11:49:43 +0900
Message-ID: <47C62147.90007@mizi.com>
References: <47666E1F.2000902@mizi.com>	 <a8e1da0802242330l765b8b1ava62b857baf8a5568@mail.gmail.com>	 <47C28A33.4070102@mizi.com> <a8e1da0802250155u1b7af481va203849f68d9106b@mail.gmail.com> <47C2A7FA.2060902@mizi.com> <70692DDF-93B7-447E-ABEE-3CDBD94F15F1@holtmann.org> <47C38D40.3040809@mizi.com> <B96BD3FE-F490-4AD5-9315-ECD42CE9C728@holtmann.org> <47C4C3D4.8010902@mizi.com> <2A7EF87C-1340-45D7-B457-F81799674B1E@holtmann.org> <47C555E5.2000903@mizi.com> <5D9353FF-6A69-4039-9033-C0EBD1CDA756@holtmann.org>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------070300070203030909050207"
Cc: Dave Young <hidave.darkstar-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	linux-bluetooth-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Linux Kernel <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	bmidgley-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	Netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, littletux-QFiJtcdG+fw@public.gmane.org
To: Marcel Holtmann <marcel-kz+m5ild9QBg9hUCZPvPmw@public.gmane.org>
Return-path: <linux-bluetooth-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <5D9353FF-6A69-4039-9033-C0EBD1CDA756-kz+m5ild9QBg9hUCZPvPmw@public.gmane.org>
Sender: linux-bluetooth-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------070300070203030909050207
Content-Type: text/plain; charset=EUC-KR
Content-Transfer-Encoding: 8bit

Hi Marcel,

I changed what you said below and attached patch again.

And did you check Guillaume's patch for this issue? his patch try to
find again when ev->link_type is SCO_LINK only. I think his way is
better than mine. I haven't saw other case (LM is not support esco but
ESCO_LINK is connected) and I think it shouldn't happen in a normal
situation.

Best regards,
Louis JANG


Marcel Holtmann ¾´ ±Û:
> Hi Louis,
>
>> When bluez tried to connect SCO channel with
>> HCI_OP_SETUP_SYNC_CONN(ESCO_LINK),
>> a real connection may be connected with SCO_LINK instead of ESCO_LINK
>> when
>> peer device doesn't support eSCO. however bluez try to find
>> connection handle
>> by event's link type(SCO_LINK in above case) and the valid connection
>> handle
>> for this event is waiting for ESCO_LINK. so bluez can't find
>> connection handle
>> and discarded the event.
>
> using HCI_OP_SETUP_SYNC_CONN doesn't mean eSCO. It is perfectly fine
> to request SCO links via that command. The difference here is
> Bluetooth 1.1 or 1.2 and later.
>
>> This patch is to handle different type of synchronous link is
>> estabilished
>> with its request.
>>
>> If bluez can't find connection handle, it try to find with different
>> link type again. (For the above case, if bluez can't find connection
>> handle with SCO_LINK, it try to find connection handle with ESCO_LINK
>> again.)
>> and update link type of this connection handle with event's link type.
>
> Inside the kernel it is not called BlueZ :) It simply is the Bluetooth
> subsystem and in case the HCI core.
>
> Regards
>
> Marcel
>
> -
> To unsubscribe from this list: send the line "unsubscribe
> linux-bluetooth" in
> the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
> More majordomo info at http://vger.kernel.org/majordomo-info.html
>


--------------070300070203030909050207
Content-Type: text/plain;
 name="patch_hci_event.c7"
Content-Transfer-Encoding: base64
Content-Disposition: inline;
 filename="patch_hci_event.c7"

V2hlbiBIQ0kgY29yZSB0cmllZCB0byBjb25uZWN0IFNDTyBjaGFubmVsIHdpdGggSENJX09Q
X1NFVFVQX1NZTkNfQ09OTiwgSENJIGNvcmUKaXMgdXNpbmcgRVNDT19MSU5LIGxpbmsgdHlw
ZSBpZiBMTSBzdXBwb3J0cyBlU0NPLiBob3dldmVyIGEgcmVhbCBjb25uZWN0aW9uIG1heSBi
ZSAKY29ubmVjdGVkIHdpdGggU0NPX0xJTksgaW5zdGVhZCBvZiBFU0NPX0xJTksgd2hlbiBw
ZWVyIGRldmljZSBkb2Vzbid0IHN1cHBvcnQgZVNDTy4gIAoKSG93ZXZlciBIQ0kgY29yZSB0
cnkgdG8gZmluZCBjb25uZWN0aW9uIGhhbmRsZSBieSBldmVudCdzIGxpbmsgdHlwZSAKKFND
T19MSU5LIGluIGFib3ZlIGNhc2UpICBpbiB0aGlzIGNhc2UsIHRoZSB2YWxpZCBjb25uZWN0
aW9uIGhhbmRsZSBmb3IgdGhpcyBldmVudCAKaXMgd2FpdGluZyBmb3IgRVNDT19MSU5LLiBI
Q0kgY29yZSBjYW4ndCBmaW5kIGNvbm5lY3Rpb24gaGFuZGxlIGFuZCBkaXNjYXJkZWQgdGhl
IGV2ZW50LiAKClRoaXMgcGF0Y2ggaXMgdG8gaGFuZGxlIGRpZmZlcmVudCB0eXBlIG9mIHN5
bmNocm9ub3VzIGxpbmsgaXMgZXN0YWJpbGlzaGVkIAp3aXRoIGl0cyByZXF1ZXN0LiAKCklm
IEhDSSBjb3JlIGNhbid0IGZpbmQgY29ubmVjdGlvbiBoYW5kbGUsIGl0IHRyeSB0byBmaW5k
IHdpdGggZGlmZmVyZW50IApsaW5rIHR5cGUgYWdhaW4uIChGb3IgdGhlIGFib3ZlIGNhc2Us
IGlmIEhDSSBjb3JlIGNhbid0IGZpbmQgY29ubmVjdGlvbiAKaGFuZGxlIHdpdGggU0NPX0xJ
TkssIGl0IHRyeSB0byBmaW5kIGNvbm5lY3Rpb24gaGFuZGxlIHdpdGggRVNDT19MSU5LIGFn
YWluLikKYW5kIHVwZGF0ZSBsaW5rIHR5cGUgb2YgdGhpcyBjb25uZWN0aW9uIGhhbmRsZSB3
aXRoIGV2ZW50J3MgbGluayB0eXBlLgoKU2lnbmVkLW9mZi1ieTogTG91aXMgSkFORyA8bG91
aXNAbWl6aS5jb20+Ci0tLSBsaW51eC0yLjYuMjMvbmV0L2JsdWV0b290aC9oY2lfZXZlbnQu
Yy5vcmlnCTIwMDgtMDItMjYgMTI6NDY6MzYuMDAwMDAwMDAwICswOTAwCisrKyBsaW51eC0y
LjYuMjMvbmV0L2JsdWV0b290aC9oY2lfZXZlbnQuYwkyMDA4LTAyLTI3IDEwOjQ4OjI5LjAw
MDAwMDAwMCArMDkwMApAQCAtMTMxMyw4ICsxMzEzLDE1IEBACiAJaGNpX2Rldl9sb2NrKGhk
ZXYpOwogCiAJY29ubiA9IGhjaV9jb25uX2hhc2hfbG9va3VwX2JhKGhkZXYsIGV2LT5saW5r
X3R5cGUsICZldi0+YmRhZGRyKTsKLQlpZiAoIWNvbm4pCi0JCWdvdG8gdW5sb2NrOworCWlm
ICghY29ubikgeworCQlfX3U4IGxpbmtfdHlwZSA9IChldi0+bGlua190eXBlID09IEVTQ09f
TElOSykgPyBTQ09fTElOSyA6IEVTQ09fTElOSzsKKworCQljb25uID0gaGNpX2Nvbm5faGFz
aF9sb29rdXBfYmEoaGRldiwgbGlua190eXBlLCAmZXYtPmJkYWRkcik7CisJCWlmICghY29u
bikKKwkJCWdvdG8gdW5sb2NrOworCisJCWNvbm4tPnR5cGUgPSBldi0+bGlua190eXBlOwor
CX0KIAogCWlmICghZXYtPnN0YXR1cykgewogCQljb25uLT5oYW5kbGUgPSBfX2xlMTZfdG9f
Y3B1KGV2LT5oYW5kbGUpOwo=
--------------070300070203030909050207--
-
To unsubscribe from this list: send the line "unsubscribe linux-bluetooth" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
