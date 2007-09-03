From: Masahide NAKAMURA <nakam@linux-ipv6.org>
Subject: Re: [-mm patch] IPV6 must select XFRM
Date: Mon, 03 Sep 2007 19:43:51 +0900
Message-ID: <20070903193711.6A1D.NAKAM@linux-ipv6.org>
References: <20070831215822.26e1432b.akpm@linux-foundation.org> <20070902112557.GK16016@stusta.de>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="------_46DBE3D76AA40B35F140_MULTIPART_MIXED_"
Content-Transfer-Encoding: 7bit
Cc: Andrew Morton <akpm@linux-foundation.org>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	nakam@linux-ipv6.org
To: Adrian Bunk <bunk@kernel.org>, David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [203.178.140.9] ([203.178.140.9]:53176 "EHLO mail.gomagoma.org"
	rhost-flags-FAIL-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1753478AbXICKlY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 3 Sep 2007 06:41:24 -0400
In-Reply-To: <20070902112557.GK16016@stusta.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--------_46DBE3D76AA40B35F140_MULTIPART_MIXED_
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit

Hello,

On Sun, 2 Sep 2007 13:25:57 +0200
Adrian Bunk <bunk@kernel.org> wrote:

> On Fri, Aug 31, 2007 at 09:58:22PM -0700, Andrew Morton wrote:
> >...
> > Changes since 2.6.23-rc3-mm1:
> >...
> >  git-net.patch
> >...
> >  git trees
> >...
> 
> This patch fixes the following compile error:
> 
> <--  snip  -->
> 
> ...
>   LD      .tmp_vmlinux1
> net/built-in.o: In function `inet6_csk_xmit':
> (.text+0x72b0f): undefined reference to `flow_cache_genid'
> net/built-in.o: In function `inet6_csk_xmit':
> (.text+0x72be5): undefined reference to `flow_cache_genid'
> make[1]: *** [.tmp_vmlinux1] Error 1
> 
> <--  snip  -->
> 
> Signed-off-by: Adrian Bunk <bunk@kernel.org>
> 
> ---
> --- a/net/ipv6/Kconfig
> +++ b/net/ipv6/Kconfig
> @@ -5,6 +5,7 @@
>  #   IPv6 as module will cause a CRASH if you try to unload it
>  config IPV6
>  	tristate "The IPv6 protocol"
> +	select XFRM
>  	default m
>  	---help---
>  	  This is complemental support for the IP version 6.
> 
> -


Thank you for catching this. the issue is caused with patch
"[IPV6] XFRM: Fix connected socket to use transformation."
which I sent to netdev.
(a85d5450ddeb959bdf9e4603f9c06e9d79217cfa on net-2.6.24).

I'd prefer to modify the original patch to use "ifdef CONFIG_XFRM"
than changing kernel config depends. Does it make sense?

Please review the attached patch.

-- 
Masahide NAKAMURA

--------_46DBE3D76AA40B35F140_MULTIPART_MIXED_
Content-Type: application/octet-stream;
 name="0001-PATCH-IPV6-XFRM-Fix-dependency-issue-at-inet6_csk_xmit.txt"
Content-Disposition: attachment;
 filename="0001-PATCH-IPV6-XFRM-Fix-dependency-issue-at-inet6_csk_xmit.txt"
Content-Transfer-Encoding: base64

RnJvbSBjOWIwZDE1ZjgyMjJkZTc4NTRhNmFkNTA0YzQ1NjIwMDRiOTllNDg3IE1vbiBTZXAgMTcg
MDA6MDA6MDAgMjAwMQpGcm9tOiBNYXNhaGlkZSBOQUtBTVVSQSA8bmFrYW1AbGludXgtaXB2Ni5v
cmc+CkRhdGU6IE1vbiwgMyBTZXAgMjAwNyAxOTozMTozMiArMDkwMApTdWJqZWN0OiBbUEFUQ0hd
IFtJUFY2XSBYRlJNOiBGaXggZGVwZW5kZW5jeSBpc3N1ZSBhdCBpbmV0Nl9jc2tfeG1pdC4KClNp
Z25lZC1vZmYtYnk6IE1hc2FoaWRlIE5BS0FNVVJBIDxuYWthbUBsaW51eC1pcHY2Lm9yZz4KLS0t
CiBpbmNsdWRlL25ldC9pcDZfZmliLmggICAgICAgICAgICB8ICAgIDIgKysKIG5ldC9pcHY2L2lu
ZXQ2X2Nvbm5lY3Rpb25fc29jay5jIHwgICAzMSArKysrKysrKysrKysrKysrKystLS0tLS0tLS0t
LS0tCiAyIGZpbGVzIGNoYW5nZWQsIDIwIGluc2VydGlvbnMoKyksIDEzIGRlbGV0aW9ucygtKQoK
ZGlmZiAtLWdpdCBhL2luY2x1ZGUvbmV0L2lwNl9maWIuaCBiL2luY2x1ZGUvbmV0L2lwNl9maWIu
aAppbmRleCA4NWQ2ZDlmLi44NTc4MjEzIDEwMDY0NAotLS0gYS9pbmNsdWRlL25ldC9pcDZfZmli
LmgKKysrIGIvaW5jbHVkZS9uZXQvaXA2X2ZpYi5oCkBAIC0xMDYsNyArMTA2LDkgQEAgc3RydWN0
IHJ0Nl9pbmZvCiAKIAl1OAkJCQlydDZpX3Byb3RvY29sOwogCisjaWZkZWYgQ09ORklHX1hGUk0K
IAl1MzIJCQkJcnQ2aV9mbG93X2NhY2hlX2dlbmlkOworI2VuZGlmCiB9OwogCiBzdGF0aWMgaW5s
aW5lIHN0cnVjdCBpbmV0Nl9kZXYgKmlwNl9kc3RfaWRldihzdHJ1Y3QgZHN0X2VudHJ5ICpkc3Qp
CmRpZmYgLS1naXQgYS9uZXQvaXB2Ni9pbmV0Nl9jb25uZWN0aW9uX3NvY2suYyBiL25ldC9pcHY2
L2luZXQ2X2Nvbm5lY3Rpb25fc29jay5jCmluZGV4IGYzODkzMjIuLjI1YjkzMTcgMTAwNjQ0Ci0t
LSBhL25ldC9pcHY2L2luZXQ2X2Nvbm5lY3Rpb25fc29jay5jCisrKyBiL25ldC9pcHY2L2luZXQ2
X2Nvbm5lY3Rpb25fc29jay5jCkBAIC0xNDMsMjkgKzE0MywzNCBAQCBzdGF0aWMgaW5saW5lCiB2
b2lkIF9faW5ldDZfY3NrX2RzdF9zdG9yZShzdHJ1Y3Qgc29jayAqc2ssIHN0cnVjdCBkc3RfZW50
cnkgKmRzdCwKIAkJCSAgIHN0cnVjdCBpbjZfYWRkciAqZGFkZHIsIHN0cnVjdCBpbjZfYWRkciAq
c2FkZHIpCiB7Ci0Jc3RydWN0IHJ0Nl9pbmZvICpydCA9IChzdHJ1Y3QgcnQ2X2luZm8gKilkc3Q7
Ci0KIAlfX2lwNl9kc3Rfc3RvcmUoc2ssIGRzdCwgZGFkZHIsIHNhZGRyKTsKLQlydC0+cnQ2aV9m
bG93X2NhY2hlX2dlbmlkID0gYXRvbWljX3JlYWQoJmZsb3dfY2FjaGVfZ2VuaWQpOworCisjaWZk
ZWYgQ09ORklHX1hGUk0KKwlpZiAoZHN0KSB7CisJCXN0cnVjdCBydDZfaW5mbyAqcnQgPSAoc3Ry
dWN0IHJ0Nl9pbmZvICAqKWRzdDsKKwkJcnQtPnJ0NmlfZmxvd19jYWNoZV9nZW5pZCA9IGF0b21p
Y19yZWFkKCZmbG93X2NhY2hlX2dlbmlkKTsKKwl9CisjZW5kaWYKIH0KIAogc3RhdGljIGlubGlu
ZQogc3RydWN0IGRzdF9lbnRyeSAqX19pbmV0Nl9jc2tfZHN0X2NoZWNrKHN0cnVjdCBzb2NrICpz
aywgdTMyIGNvb2tpZSkKIHsKIAlzdHJ1Y3QgZHN0X2VudHJ5ICpkc3Q7Ci0Jc3RydWN0IHJ0Nl9p
bmZvICpydDsKIAogCWRzdCA9IF9fc2tfZHN0X2NoZWNrKHNrLCBjb29raWUpOwotCWlmICghZHN0
KQotCQlnb3RvIGVuZDsKLQotCXJ0ID0gKHN0cnVjdCBydDZfaW5mbyAqKWRzdDsKLQlpZiAocnQt
PnJ0NmlfZmxvd19jYWNoZV9nZW5pZCAhPSBhdG9taWNfcmVhZCgmZmxvd19jYWNoZV9nZW5pZCkp
IHsKLQkJc2stPnNrX2RzdF9jYWNoZSA9IE5VTEw7Ci0JCWRzdF9yZWxlYXNlKGRzdCk7Ci0JCWRz
dCA9IE5VTEw7CisKKyNpZmRlZiBDT05GSUdfWEZSTQorCWlmIChkc3QpIHsKKwkJc3RydWN0IHJ0
Nl9pbmZvICpydCA9IChzdHJ1Y3QgcnQ2X2luZm8gKilkc3Q7CisJCWlmIChydC0+cnQ2aV9mbG93
X2NhY2hlX2dlbmlkICE9IGF0b21pY19yZWFkKCZmbG93X2NhY2hlX2dlbmlkKSkgeworCQkJc2st
PnNrX2RzdF9jYWNoZSA9IE5VTEw7CisJCQlkc3RfcmVsZWFzZShkc3QpOworCQkJZHN0ID0gTlVM
TDsKKwkJfQogCX0KLSBlbmQ6CisjZW5kaWYKKwogCXJldHVybiBkc3Q7CiB9CiAKLS0gCjEuNC40
LjIKCg==
--------_46DBE3D76AA40B35F140_MULTIPART_MIXED_--

