From: Pablo Bitton <pablo.bitton@gmail.com>
Subject: Re: A small fix to davinci_emac driver
Date: Thu, 25 Jun 2009 16:13:59 +0300
Message-ID: <7448ec710906250613p5fde8b44s24842a32e42dce37@mail.gmail.com>
References: <028901c9f54b$4579eae0$d06dc0a0$@com>
	 <B85A65D85D7EB246BE421B3FB0FBB59301D829C4CE@dbde02.ent.ti.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary=000e0cd28eae3173e3046d2bff72
Cc: "Rajashekhara, Sudhakar" <sudhakar.raj@ti.com>,
	"Subrahmanya, Chaithrika" <chaithrika@ti.com>,
	davinci-linux-open-source@linux.davincidsp.com
To: "Nori, Sekhar" <nsekhar@ti.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from fg-out-1718.google.com ([72.14.220.155]:21354 "EHLO
	fg-out-1718.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751718AbZFYNN5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Jun 2009 09:13:57 -0400
Received: by fg-out-1718.google.com with SMTP id e21so272529fga.17
        for <netdev@vger.kernel.org>; Thu, 25 Jun 2009 06:13:59 -0700 (PDT)
In-Reply-To: <B85A65D85D7EB246BE421B3FB0FBB59301D829C4CE@dbde02.ent.ti.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--000e0cd28eae3173e3046d2bff72
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit

Hello all,

I have attached a small fix for the following problem:
When davinci_emac interface is down, changing MAC address results in
kernel oops, due to NULL pointer dereference.

I apologize for not inlining the patch into the message (since GMail
is the only web client I can use, and it does not allow me to inline
it correctly).
Remarks are welcomed.

Thanks in advance.

On Thu, Jun 25, 2009 at 11:31 AM, Nori, Sekhar<nsekhar@ti.com> wrote:
>
> Pablo,
>
> Chaithrika's mails to gmail.com are bouncing, so I am replying
> on her behalf.
>
> "
> You are right there is indeed an issue. We looked at other
> drivers and found that this is solved by checking for netif_running
> to be true before going ahead and setting the mac address. Have a
> look at how this is done in tg3.c driver
>
> http://git.kernel.org/?p=linux/kernel/git/khilman/linux-davinci.git;a=blob;f=drivers/net/tg3.c;h=201be425643a6fb7acb8801bbbb718897c9a6431;hb=35265abf67337f57a023ffeae5f4c492e7f8ea24#l6589
> "
>
> Can you please go ahead and submit a fix for this to netdev
> mailing list and CC linux-davinci ML?
>
> Thanks,
> Sekhar
>
>> -----Original Message-----
>> From: Pablo Bitton [mailto:pablo.bitton@gmail.com]
>> Sent: Wednesday, June 24, 2009 7:13 PM
>> To: Subrahmanya, Chaithrika
>> Subject: A small fix to davinci_emac driver
>>
>> Hello,
>>
>> In drivers/net/davinci_emac.c file, at emac_dev_setmac_addr() function, rxch
>> is NULL when DaVinci EMAC is down (using "ifconfig eth0 down").
>>
>> So when MAC address is changed using "ifconfig eth0 hw ether
>> 00:11:22:33:44:55",
>> emac_dev_setmac_addr() performs an illegal access to rxch->mac_addr, which
>> causes a kernel oops.
>>
>> In order to fix this situation, the attached patch is applied (I've couldn't
>> inline it correctly into GMail).
>> Remarks are welcomed.
>>
>> Thanks in advance.
>

--000e0cd28eae3173e3046d2bff72
Content-Type: text/plain; charset=US-ASCII;
	name="0002-davinci_emac-fix-kernel-oops-when-changing-mac-addr.patch.txt"
Content-Disposition: attachment;
	filename="0002-davinci_emac-fix-kernel-oops-when-changing-mac-addr.patch.txt"
Content-Transfer-Encoding: base64
X-Attachment-Id: f_fwdfb3jq0

RnJvbSBhZTk0ODBhZjI2ZWJhMzMwMjYxNGVhM2Q5MjA3N2E4MDM0MWNkMTkwIE1vbiBTZXAgMTcg
MDA6MDA6MDAgMjAwMQpGcm9tOiBQYWJsbyBCaXR0b24gPHBhYmxvLmJpdHRvbkBnbWFpbC5jb20+
CkRhdGU6IFR1ZSwgMjMgSnVuIDIwMDkgMTU6NDU6NDMgKzAzMDAKU3ViamVjdDogW1BBVENIXSBk
YXZpbmNpX2VtYWM6IGZpeCBrZXJuZWwgb29wcyB3aGVuIGNoYW5naW5nIE1BQyBhZGRyZXNzIHdo
aWxlIGludGVyZmFjZSBpcyBkb3duCgpyeGNoID09IE5VTEwgd2hlbiBEYVZpbmNpIEVNQUMgaXMg
ZG93biAodXNpbmcgImlmY29uZmlnIGV0aDAgZG93biIpLgpTbyB3aGVuIE1BQyBhZGRyZXNzIGlz
IGNoYW5nZWQgdXNpbmcgImlmY29uZmlnIGV0aDAgaHcgZXRoZXIgMDA6MTE6MjI6MzM6NDQ6NTUi
LAplbWFjX2Rldl9zZXRtYWNfYWRkcigpIHBlcmZvcm1zIGFuIGlsbGVnYWwgYWNjZXNzIHRvIHJ4
Y2gtPm1hY19hZGRyLCB3aGljaApjYXVzZXMgYSBrZXJuZWwgb29wcy4KClNpZ25lZC1vZmYtYnk6
IFBhYmxvIEJpdHRvbiA8cGFibG8uYml0dG9uQGdtYWlsLmNvbT4KLS0tCiBkcml2ZXJzL25ldC9k
YXZpbmNpX2VtYWMuYyB8ICAgIDkgKysrKysrKy0tCiAxIGZpbGVzIGNoYW5nZWQsIDcgaW5zZXJ0
aW9ucygrKSwgMiBkZWxldGlvbnMoLSkKCmRpZmYgLS1naXQgYS9kcml2ZXJzL25ldC9kYXZpbmNp
X2VtYWMuYyBiL2RyaXZlcnMvbmV0L2RhdmluY2lfZW1hYy5jCmluZGV4IGNmNjg5YTAuLmNkMTE0
ZDkgMTAwNjQ0Ci0tLSBhL2RyaXZlcnMvbmV0L2RhdmluY2lfZW1hYy5jCisrKyBiL2RyaXZlcnMv
bmV0L2RhdmluY2lfZW1hYy5jCkBAIC0xODIzLDkgKzE4MjMsMTQgQEAgc3RhdGljIGludCBlbWFj
X2Rldl9zZXRtYWNfYWRkcihzdHJ1Y3QgbmV0X2RldmljZSAqbmRldiwgdm9pZCAqYWRkcikKIAog
CS8qIFN0b3JlIG1hYyBhZGRyIGluIHByaXYgYW5kIHJ4IGNoYW5uZWwgYW5kIHNldCBpdCBpbiBF
TUFDIGh3ICovCiAJbWVtY3B5KHByaXYtPm1hY19hZGRyLCBzYS0+c2FfZGF0YSwgbmRldi0+YWRk
cl9sZW4pOwotCW1lbWNweShyeGNoLT5tYWNfYWRkciwgc2EtPnNhX2RhdGEsIG5kZXYtPmFkZHJf
bGVuKTsKIAltZW1jcHkobmRldi0+ZGV2X2FkZHIsIHNhLT5zYV9kYXRhLCBuZGV2LT5hZGRyX2xl
bik7Ci0JZW1hY19zZXRtYWMocHJpdiwgRU1BQ19ERUZfUlhfQ0gsIHJ4Y2gtPm1hY19hZGRyKTsK
KworCS8qIElmIHRoZSBpbnRlcmZhY2UgaXMgZG93biAtIHJ4Y2ggaXMgTlVMTC4gKi8KKwkvKiBN
QUMgYWRkcmVzcyBpcyBjb25maWd1cmVkIG9ubHkgYWZ0ZXIgdGhlIGludGVyZmFjZSBpcyBlbmFi
bGVkLiAqLworCWlmIChuZXRpZl9ydW5uaW5nKG5kZXYpKSB7CisJCW1lbWNweShyeGNoLT5tYWNf
YWRkciwgc2EtPnNhX2RhdGEsIG5kZXYtPmFkZHJfbGVuKTsKKwkJZW1hY19zZXRtYWMocHJpdiwg
RU1BQ19ERUZfUlhfQ0gsIHJ4Y2gtPm1hY19hZGRyKTsKKwl9CiAKIAlpZiAobmV0aWZfbXNnX2Ry
dihwcml2KSkKIAkJZGV2X25vdGljZShlbWFjX2RldiwgIkRhVmluY2kgRU1BQzogZW1hY19kZXZf
c2V0bWFjX2FkZHIgJXNcbiIsCi0tIAoxLjUuNC4zCgo=
--000e0cd28eae3173e3046d2bff72--
