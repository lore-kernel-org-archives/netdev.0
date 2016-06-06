From: Z Lim <zlim.lnx@gmail.com>
Subject: Re: [PATCH net-next 1/3] arm64: bpf: implement bpf_tail_call() helper
Date: Sun, 5 Jun 2016 21:56:00 -0700
Message-ID: <CABg9mcv0kYvk7-wsfVR3fg0nBBDVbs0QtTiWZfGRDqq7kGeFPQ@mail.gmail.com>
References: <201606050700.BLJUHUk2%fengguang.wu@intel.com> <5753DA61.3000505@iogearbox.net>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary=94eb2c03a64e9086a5053494e362
Cc: kbuild test robot <lkp@intel.com>, kbuild-all@01.org,
	"David S. Miller" <davem@davemloft.net>,
	Catalin Marinas <catalin.marinas@arm.com>,
	Will Deacon <will.deacon@arm.com>,
	Yang Shi <yang.shi@linaro.org>,
	Alexei Starovoitov <ast@kernel.org>,
	Network Development <netdev@vger.kernel.org>,
	"linux-arm-kernel@lists.infradead.org"
	<linux-arm-kernel@lists.infradead.org>,
	LKML <linux-kernel@vger.kernel.org>
To: Daniel Borkmann <daniel@iogearbox.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <5753DA61.3000505@iogearbox.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--94eb2c03a64e9086a5053494e362
Content-Type: text/plain; charset=UTF-8

Hi Daniel,

On Sun, Jun 5, 2016 at 12:53 AM, Daniel Borkmann <daniel@iogearbox.net> wrote:
> On 06/05/2016 01:46 AM, kbuild test robot wrote:
>>
>> Hi,
>>
>> [auto build test ERROR on net-next/master]
>>
>> url:
>> https://github.com/0day-ci/linux/commits/Zi-Shen-Lim/arm64-bpf-implement-bpf_tail_call-helper/20160605-060435
>> config: arm64-defconfig (attached as .config)
>> compiler: aarch64-linux-gnu-gcc (Debian 5.3.1-8) 5.3.1 20160205
>> reproduce:
>>          wget
>> https://git.kernel.org/cgit/linux/kernel/git/wfg/lkp-tests.git/plain/sbin/make.cross
>> -O ~/bin/make.cross
>>          chmod +x ~/bin/make.cross
>>          # save the attached .config to linux build tree
>>          make.cross ARCH=arm64
>>
>> All errors (new ones prefixed by >>):
>>
>>     In file included from arch/arm64/net/bpf_jit_comp.c:21:0:
>>     include/linux/bpf.h: In function 'bpf_prog_get':
>>>>
>>>> include/linux/bpf.h:235:9: error: implicit declaration of function
>>>> 'ERR_PTR' [-Werror=implicit-function-declaration]
>>
>>       return ERR_PTR(-EOPNOTSUPP);
>>              ^
>>     include/linux/bpf.h:235:9: warning: return makes pointer from integer
>> without a cast [-Wint-conversion]
>>     In file included from include/linux/rwsem.h:17:0,
>>                      from include/linux/mm_types.h:10,
>>                      from include/linux/sched.h:27,
>>                      from arch/arm64/include/asm/compat.h:25,
>>                      from arch/arm64/include/asm/stat.h:23,
>>                      from include/linux/stat.h:5,
>>                      from include/linux/compat.h:12,
>>                      from include/linux/filter.h:10,
>>                      from arch/arm64/net/bpf_jit_comp.c:22:
>>     include/linux/err.h: At top level:
>>>>
>>>> include/linux/err.h:23:35: error: conflicting types for 'ERR_PTR'
>>
>>      static inline void * __must_check ERR_PTR(long error)
>>                                        ^
>>     In file included from arch/arm64/net/bpf_jit_comp.c:21:0:
>>     include/linux/bpf.h:235:9: note: previous implicit declaration of
>> 'ERR_PTR' was here
>>       return ERR_PTR(-EOPNOTSUPP);
>>              ^
>>     cc1: some warnings being treated as errors
>
>
> Looks like including linux/bpf.h at the very beginning causes issues when
> bpf
> syscall is disabled. We should probably just include linux/err.h from bpf.h.

How about the attached patch? Fixes compilation error on build
!CONFIG_BPF_SYSCALL.

Also, should this patch be sent to net or net-next (along with this series)?

Thanks,
z

--94eb2c03a64e9086a5053494e362
Content-Type: text/x-patch; charset=US-ASCII;
	name="0001-bpf-fix-missing-header-inclusion.patch"
Content-Disposition: attachment;
	filename="0001-bpf-fix-missing-header-inclusion.patch"
Content-Transfer-Encoding: base64
X-Attachment-Id: f_ip3jmo2h0

RnJvbSAwNjMzZTNlNTI4ZTExYjA5NjkxZmJmNTMzYmE3ZmRhZjRjNTJmNzcyIE1vbiBTZXAgMTcg
MDA6MDA6MDAgMjAwMQpGcm9tOiBaaSBTaGVuIExpbSA8emxpbS5sbnhAZ21haWwuY29tPgpEYXRl
OiBTdW4sIDUgSnVuIDIwMTYgMjE6NDM6MTQgLTA3MDAKU3ViamVjdDogW1BBVENIXSBicGY6IGZp
eCBtaXNzaW5nIGhlYWRlciBpbmNsdXNpb24KCkNvbW1pdCAwZmMxNzRkZWE1NDUgKCJlYnBmOiBt
YWtlIGludGVybmFsIGJwZiBBUEkgaW5kZXBlbmRlbnQgb2YKQ09ORklHX0JQRl9TWVNDQUxMIGlm
ZGVmcyIpIGludHJvZHVjZWQgdXNhZ2Ugb2YgRVJSX1BUUigpIGluCmJwZl9wcm9nX2dldCgpLCBo
b3dldmVyIGRpZCBub3QgaW5jbHVkZSBsaW51eC9lcnIuaC4KCldpdGhvdXQgdGhpcyBwYXRjaCwg
d2hlbiBjb21waWxpbmcgYXJtNjQgQlBGIHdpdGhvdXQgQ09ORklHX0JQRl9TWVNDQUxMOgouLi4K
SW4gZmlsZSBpbmNsdWRlZCBmcm9tIGFyY2gvYXJtNjQvbmV0L2JwZl9qaXRfY29tcC5jOjIxOjA6
CmluY2x1ZGUvbGludXgvYnBmLmg6IEluIGZ1bmN0aW9uICdicGZfcHJvZ19nZXQnOgppbmNsdWRl
L2xpbnV4L2JwZi5oOjIzNTo5OiBlcnJvcjogaW1wbGljaXQgZGVjbGFyYXRpb24gb2YgZnVuY3Rp
b24gJ0VSUl9QVFInIFstV2Vycm9yPWltcGxpY2l0LWZ1bmN0aW9uLWRlY2xhcmF0aW9uXQogIHJl
dHVybiBFUlJfUFRSKC1FT1BOT1RTVVBQKTsKICAgICAgICAgXgppbmNsdWRlL2xpbnV4L2JwZi5o
OjIzNTo5OiB3YXJuaW5nOiByZXR1cm4gbWFrZXMgcG9pbnRlciBmcm9tIGludGVnZXIgd2l0aG91
dCBhIGNhc3QgWy1XaW50LWNvbnZlcnNpb25dCkluIGZpbGUgaW5jbHVkZWQgZnJvbSBpbmNsdWRl
L2xpbnV4L3J3c2VtLmg6MTc6MCwKICAgICAgICAgICAgICAgICBmcm9tIGluY2x1ZGUvbGludXgv
bW1fdHlwZXMuaDoxMCwKICAgICAgICAgICAgICAgICBmcm9tIGluY2x1ZGUvbGludXgvc2NoZWQu
aDoyNywKICAgICAgICAgICAgICAgICBmcm9tIGFyY2gvYXJtNjQvaW5jbHVkZS9hc20vY29tcGF0
Lmg6MjUsCiAgICAgICAgICAgICAgICAgZnJvbSBhcmNoL2FybTY0L2luY2x1ZGUvYXNtL3N0YXQu
aDoyMywKICAgICAgICAgICAgICAgICBmcm9tIGluY2x1ZGUvbGludXgvc3RhdC5oOjUsCiAgICAg
ICAgICAgICAgICAgZnJvbSBpbmNsdWRlL2xpbnV4L2NvbXBhdC5oOjEyLAogICAgICAgICAgICAg
ICAgIGZyb20gaW5jbHVkZS9saW51eC9maWx0ZXIuaDoxMCwKICAgICAgICAgICAgICAgICBmcm9t
IGFyY2gvYXJtNjQvbmV0L2JwZl9qaXRfY29tcC5jOjIyOgppbmNsdWRlL2xpbnV4L2Vyci5oOiBB
dCB0b3AgbGV2ZWw6CmluY2x1ZGUvbGludXgvZXJyLmg6MjM6MzU6IGVycm9yOiBjb25mbGljdGlu
ZyB0eXBlcyBmb3IgJ0VSUl9QVFInCiBzdGF0aWMgaW5saW5lIHZvaWQgKiBfX211c3RfY2hlY2sg
RVJSX1BUUihsb25nIGVycm9yKQogICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgIF4K
SW4gZmlsZSBpbmNsdWRlZCBmcm9tIGFyY2gvYXJtNjQvbmV0L2JwZl9qaXRfY29tcC5jOjIxOjA6
CmluY2x1ZGUvbGludXgvYnBmLmg6MjM1Ojk6IG5vdGU6IHByZXZpb3VzIGltcGxpY2l0IGRlY2xh
cmF0aW9uIG9mICdFUlJfUFRSJyB3YXMgaGVyZQogIHJldHVybiBFUlJfUFRSKC1FT1BOT1RTVVBQ
KTsKICAgICAgICAgXgouLi4KCkZpeGVzOiAwZmMxNzRkZWE1NDUgKCJlYnBmOiBtYWtlIGludGVy
bmFsIGJwZiBBUEkgaW5kZXBlbmRlbnQgb2YgQ09ORklHX0JQRl9TWVNDQUxMIGlmZGVmcyIpClN1
Z2dlc3RlZC1ieTogRGFuaWVsIEJvcmttYW5uIDxkYW5pZWxAaW9nZWFyYm94Lm5ldD4KU2lnbmVk
LW9mZi1ieTogWmkgU2hlbiBMaW0gPHpsaW0ubG54QGdtYWlsLmNvbT4KLS0tCiBpbmNsdWRlL2xp
bnV4L2JwZi5oIHwgMSArCiAxIGZpbGUgY2hhbmdlZCwgMSBpbnNlcnRpb24oKykKCmRpZmYgLS1n
aXQgYS9pbmNsdWRlL2xpbnV4L2JwZi5oIGIvaW5jbHVkZS9saW51eC9icGYuaAppbmRleCA4ZWUy
N2I4Li4xYmNhZTgyIDEwMDY0NAotLS0gYS9pbmNsdWRlL2xpbnV4L2JwZi5oCisrKyBiL2luY2x1
ZGUvbGludXgvYnBmLmgKQEAgLTExLDYgKzExLDcgQEAKICNpbmNsdWRlIDxsaW51eC93b3JrcXVl
dWUuaD4KICNpbmNsdWRlIDxsaW51eC9maWxlLmg+CiAjaW5jbHVkZSA8bGludXgvcGVyY3B1Lmg+
CisjaW5jbHVkZSA8bGludXgvZXJyLmg+CiAKIHN0cnVjdCBicGZfbWFwOwogCi0tIAoxLjkuMQoK
--94eb2c03a64e9086a5053494e362--
