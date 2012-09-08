From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH net-next] netfilter: x_tables: xt_init() should run
 earlier
Date: Sat, 8 Sep 2012 19:50:27 +0200 (MEST)
Message-ID: <Pine.GSO.4.63.1209081949500.2030@stinky-local.trash.net>
References: <CAM_iQpVUZ50RYLUgEHbcm7ua996hgE7Gj-P-bWNJutuvm1nUoQ@mail.gmail.com>
  <1346860506.13121.148.camel@edumazet-glaptop>  <1346861569.13121.149.camel@edumazet-glaptop>
 <1346863073.13121.155.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="-559023410-851401618-1347126627=:2030"
Cc: Cong Wang <xiyou.wangcong@gmail.com>,
	Pablo Neira Ayuso <pablo@netfilter.org>,
	netfilter-devel@vger.kernel.org,
	Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:36530 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754002Ab2IHRua (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 8 Sep 2012 13:50:30 -0400
In-Reply-To: <1346863073.13121.155.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---559023410-851401618-1347126627=:2030
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed

On Wed, 5 Sep 2012, Eric Dumazet wrote:

> From: Eric Dumazet <edumazet@google.com>
>
> Cong Wang reported a NULL dereference in xt_register_target()
>
> It turns out xt_nat_init() was called before xt_init(), so xt array
> was not yet setup.
>
> xt_init() should be marked core_initcall() to solve this problem.
>
> Reported-by: Cong Wang <xiyou.wangcong@gmail.com>
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> ---
> net/netfilter/x_tables.c |    2 +-
> 1 file changed, 1 insertion(+), 1 deletion(-)
>
> diff --git a/net/netfilter/x_tables.c b/net/netfilter/x_tables.c
> index 8d987c3..afcea11 100644
> --- a/net/netfilter/x_tables.c
> +++ b/net/netfilter/x_tables.c
> @@ -1390,6 +1390,6 @@ static void __exit xt_fini(void)
> 	kfree(xt);
> }
>
> -module_init(xt_init);
> +core_initcall(xt_init);
> module_exit(xt_fini);

Shouldn't we simply change the Makefile order?
---559023410-851401618-1347126627=:2030
Content-Type: TEXT/PLAIN; charset=US-ASCII; name=nat-oops.diff
Content-Transfer-Encoding: BASE64
Content-ID: <Pine.GSO.4.63.1209081950270.2030@stinky-local.trash.net>
Content-Description: 
Content-Disposition: attachment; filename=nat-oops.diff

Y29tbWl0IGVjYzQ1MDhlNDc2ZTQzMjVlNzQ3ZGFkNWQ4NmMwMzI0OGVkMTYy
NzENCkF1dGhvcjogUGF0cmljayBNY0hhcmR5IDxrYWJlckB0cmFzaC5uZXQ+
DQpEYXRlOiAgIFNhdCBTZXAgOCAxOTo0NToxMiAyMDEyICswMjAwDQoNCiAg
ICBuZXRmaWx0ZXI6IGZpeCB4dF9uYXQgbGluayBvcmRlcg0KICAgIA0KICAg
IENvbmcgV2FuZyByZXBvcnRlZCBhIE5VTEwgZGVyZWZlcmVuY2UgaW4geHRf
cmVnaXN0ZXJfdGFyZ2V0KCkNCiAgICANCiAgICBJdCB0dXJucyBvdXQgeHRf
bmF0X2luaXQoKSB3YXMgY2FsbGVkIGJlZm9yZSB4dF9pbml0KCksIHNvIHh0
IGFycmF5DQogICAgd2FzIG5vdCB5ZXQgc2V0dXAuDQogICAgDQogICAgTW92
ZSB4dF9uYXQgZG93biBpbiB0aGUgTWFrZWZpbGUgdG8gYXZvaWQgaW5pdGlh
bGl6YXRpb24gYmVmb3JlDQogICAgeF90YWJsZXMgaXMgaW5pdGlhbGl6ZWQu
DQogICAgDQogICAgQmFzZWQgb24gcGF0Y2ggZnJvbSBFcmljIER1bWF6ZXQu
DQogICAgDQogICAgUmVwb3J0ZWQtYnk6IENvbmcgV2FuZyA8eGl5b3Uud2Fu
Z2NvbmdAZ21haWwuY29tPg0KICAgIFNpZ25lZC1vZmYtYnk6IFBhdHJpY2sg
TWNIYXJkeSA8a2FiZXJAdHJhc2gubmV0Pg0KDQpkaWZmIC0tZ2l0IGEvbmV0
L25ldGZpbHRlci9NYWtlZmlsZSBiL25ldC9uZXRmaWx0ZXIvTWFrZWZpbGUN
CmluZGV4IDk4MjQ0ZDQuLjZhZDY2MTYgMTAwNjQ0DQotLS0gYS9uZXQvbmV0
ZmlsdGVyL01ha2VmaWxlDQorKysgYi9uZXQvbmV0ZmlsdGVyL01ha2VmaWxl
DQpAQCAtNDcsNyArNDcsNiBAQCBuZl9uYXQteQk6PSBuZl9uYXRfY29yZS5v
IG5mX25hdF9wcm90b191bmtub3duLm8gbmZfbmF0X3Byb3RvX2NvbW1vbi5v
IFwNCiAJCSAgIG5mX25hdF9wcm90b191ZHAubyBuZl9uYXRfcHJvdG9fdGNw
Lm8gbmZfbmF0X2hlbHBlci5vDQogDQogb2JqLSQoQ09ORklHX05GX05BVCkg
Kz0gbmZfbmF0Lm8NCi1vYmotJChDT05GSUdfTkZfTkFUKSArPSB4dF9uYXQu
bw0KIA0KICMgTkFUIHByb3RvY29scyAobmZfbmF0KQ0KIG9iai0kKENPTkZJ
R19ORl9OQVRfUFJPVE9fRENDUCkgKz0gbmZfbmF0X3Byb3RvX2RjY3Aubw0K
QEAgLTkzLDYgKzkyLDcgQEAgb2JqLSQoQ09ORklHX05FVEZJTFRFUl9YVF9U
QVJHRVRfVENQT1BUU1RSSVApICs9IHh0X1RDUE9QVFNUUklQLm8NCiBvYmot
JChDT05GSUdfTkVURklMVEVSX1hUX1RBUkdFVF9URUUpICs9IHh0X1RFRS5v
DQogb2JqLSQoQ09ORklHX05FVEZJTFRFUl9YVF9UQVJHRVRfVFJBQ0UpICs9
IHh0X1RSQUNFLm8NCiBvYmotJChDT05GSUdfTkVURklMVEVSX1hUX1RBUkdF
VF9JRExFVElNRVIpICs9IHh0X0lETEVUSU1FUi5vDQorb2JqLSQoQ09ORklH
X05GX05BVCkgKz0geHRfbmF0Lm8NCiANCiAjIG1hdGNoZXMNCiBvYmotJChD
T05GSUdfTkVURklMVEVSX1hUX01BVENIX0FERFJUWVBFKSArPSB4dF9hZGRy
dHlwZS5vDQo=

---559023410-851401618-1347126627=:2030--
