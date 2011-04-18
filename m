From: Patrick McHardy <kaber@trash.net>
Subject: Re: BUG: unable to handle kernel NULL pointer dereference at 000002c0
  / IP: [<c04c70f2>] in6_dev_finish_destroy+0x35/0x8c
Date: Mon, 18 Apr 2011 15:34:39 +0200
Message-ID: <4DAC3DEF.6070702@trash.net>
References: <4DA77AE5.9060501@simon.arlott.org.uk>	 <0b5f315dd0f6e8eefabbd8b38b1d43e181fdd728@8b5064a13e22126c1b9329f0dc35b8915774b7c3.invalid>	 <1302872983.3613.10.camel@edumazet-laptop> <1302873876.3613.11.camel@edumazet-laptop> <4DA86FE5.8080507@simon.arlott.org.uk>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------030102080707030002020304"
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>,
	Netfilter Development Mailinglist
	<netfilter-devel@vger.kernel.org>
To: Simon Arlott <simon@fire.lp0.eu>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <4DA86FE5.8080507@simon.arlott.org.uk>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------030102080707030002020304
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit

Am 15.04.2011 18:18, schrieb Simon Arlott:
> On 15/04/11 14:24, Eric Dumazet wrote:
>> Hmm.. a more complete patch :
>>
>> diff --git a/net/ipv6/netfilter/nf_conntrack_reasm.c b/net/ipv6/netfilter/nf_conntrack_reasm.c
>> index 0857272..6f0bed0 100644
> 
> I applied the patch by recompiling and then reloading the nf_conntrack_ipv6
> module (temporarily flushing and then restoring all ip6tables rules).
> Then this happened 10 minutes later:
> 
> [33876.950100] BUG: unable to handle kernel NULL pointer dereference at 00000014
> [33876.951060] IP: [<f9b012bb>] nf_ct_frag6_gather+0x864/0x881 [nf_conntrack_ipv6]

nf_ct_frag6_reasm() can return NULL, so we need to check for a non-NULL
ret_skb before trying to set the device.

Does this patch (based on Eric's second version) help?


--------------030102080707030002020304
Content-Type: text/plain;
 name="x"
Content-Transfer-Encoding: base64
Content-Disposition: attachment;
 filename="x"

ZGlmZiAtLWdpdCBhL25ldC9pcHY2L25ldGZpbHRlci9uZl9jb25udHJhY2tfcmVhc20uYyBi
L25ldC9pcHY2L25ldGZpbHRlci9uZl9jb25udHJhY2tfcmVhc20uYwppbmRleCAwODU3Mjcy
Li5iN2VjZmNlIDEwMDY0NAotLS0gYS9uZXQvaXB2Ni9uZXRmaWx0ZXIvbmZfY29ubnRyYWNr
X3JlYXNtLmMKKysrIGIvbmV0L2lwdjYvbmV0ZmlsdGVyL25mX2Nvbm50cmFja19yZWFzbS5j
CkBAIC01NzYsNyArNTc2LDkgQEAgc3RydWN0IHNrX2J1ZmYgKm5mX2N0X2ZyYWc2X2dhdGhl
cihzdHJ1Y3Qgc2tfYnVmZiAqc2tiLCB1MzIgdXNlcikKIAlpZiAoZnEtPnEubGFzdF9pbiA9
PSAoSU5FVF9GUkFHX0ZJUlNUX0lOIHwgSU5FVF9GUkFHX0xBU1RfSU4pICYmCiAJICAgIGZx
LT5xLm1lYXQgPT0gZnEtPnEubGVuKSB7CiAJCXJldF9za2IgPSBuZl9jdF9mcmFnNl9yZWFz
bShmcSwgZGV2KTsKLQkJaWYgKHJldF9za2IgPT0gTlVMTCkKKwkJaWYgKHJldF9za2IgIT0g
TlVMTCkKKwkJCXJldF9za2ItPmRldiA9IGRldjsKKwkJZWxzZQogCQkJcHJfZGVidWcoIkNh
bid0IHJlYXNzZW1ibGUgZnJhZ21lbnRlZCBwYWNrZXRzXG4iKTsKIAl9CiAJc3Bpbl91bmxv
Y2tfYmgoJmZxLT5xLmxvY2spOwpAQCAtNjAyLDcgKzYwNCw3IEBAIHZvaWQgbmZfY3RfZnJh
ZzZfb3V0cHV0KHVuc2lnbmVkIGludCBob29rbnVtLCBzdHJ1Y3Qgc2tfYnVmZiAqc2tiLAog
CiAJCXMyID0gcy0+bmV4dDsKIAkJcy0+bmV4dCA9IE5VTEw7Ci0KKwkJcy0+ZGV2ID0gaW47
CiAJCU5GX0hPT0tfVEhSRVNIKE5GUFJPVE9fSVBWNiwgaG9va251bSwgcywgaW4sIG91dCwg
b2tmbiwKIAkJCSAgICAgICBORl9JUDZfUFJJX0NPTk5UUkFDS19ERUZSQUcgKyAxKTsKIAkJ
cyA9IHMyOwo=
--------------030102080707030002020304--
