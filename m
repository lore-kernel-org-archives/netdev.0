From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [net-next-2.6 PATCH] ethtool: Add n-tuple string length to drvinfo
 and return it
Date: Fri, 26 Feb 2010 08:56:43 -0500
Message-ID: <4B87D31B.4000001@garzik.org>
References: <20100226115355.20213.59254.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------020304070302040201030705"
Cc: davem@davemloft.net, netdev@vger.kernel.org, gospo@redhat.com,
	Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f197.google.com ([209.85.211.197]:46054 "EHLO
	mail-yw0-f197.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S936217Ab0BZN4q (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 Feb 2010 08:56:46 -0500
Received: by ywh35 with SMTP id 35so42466ywh.4
        for <netdev@vger.kernel.org>; Fri, 26 Feb 2010 05:56:45 -0800 (PST)
In-Reply-To: <20100226115355.20213.59254.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------020304070302040201030705
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit

On 02/26/2010 06:54 AM, Jeff Kirsher wrote:
> From: Peter Waskiewicz<peter.p.waskiewicz.jr@intel.com>
>
> The drvinfo struct should include the number of strings that
> get_rx_ntuple will return.  It will be variable if an underlying
> driver implements its own get_rx_ntuple routine, so userspace
> needs to know how much data is coming.
>
> Signed-off-by: Peter P Waskiewicz Jr<peter.p.waskiewicz.jr@intel.com>
> Signed-off-by: Jeff Kirsher<jeffrey.t.kirsher@intel.com>
> ---
>
>   include/linux/ethtool.h |    1 +
>   net/core/ethtool.c      |    3 +++
>   2 files changed, 4 insertions(+), 0 deletions(-)

(resending reply, standard patch-sending box is having trouble sending 
to vger)


As noted in the other email, your patch breaks ABI.  The proper path is
to decrease the size of reserved struct member, and NOT shift the offset
of other members.



However, perhaps consider the following patch for returning n-tuple
count, for four reasons:

1) space in ethtool_drvinfo is limited

2) the patch below permits trivial string set addition, without
    ABI changes beyond adding a new ETH_SS_xxx constant.

3) the patch below permits direct access to ops->get_sset_count(),
    rather than implicit access via ethtool_drvinfo

4) ethtool_drvinfo interface does not permit indication of
    ops->get_sset_count() failure, versus returning zero value.  The
    patch below does so, via output sset_mask.

WARNING: this patch is compile-tested only.

NOTE: I added a cosmetic fix to ETHTOOL_[GS]RXNTUPLE constants, making
their indentation consistent with the rest of the list of constants.

Signed-off-by: Jeff Garzik <jgarzik@redhat.com>



--------------020304070302040201030705
Content-Type: text/plain;
 name="patch"
Content-Transfer-Encoding: base64
Content-Disposition: attachment;
 filename="patch"

ZGlmZiAtLWdpdCBhL2luY2x1ZGUvbGludXgvZXRodG9vbC5oIGIvaW5jbHVkZS9saW51eC9l
dGh0b29sLmgKaW5kZXggZjc5OTJhMi4uMDRlY2YxOCAxMDA2NDQKLS0tIGEvaW5jbHVkZS9s
aW51eC9ldGh0b29sLmgKKysrIGIvaW5jbHVkZS9saW51eC9ldGh0b29sLmgKQEAgLTI1NCw2
ICsyNTQsMTcgQEAgc3RydWN0IGV0aHRvb2xfZ3N0cmluZ3MgewogCV9fdTgJZGF0YVswXTsK
IH07CiAKK3N0cnVjdCBldGh0b29sX3NzZXRfaW5mbyB7CisJX191MzIJY21kOwkJLyogRVRI
VE9PTF9HU1NFVF9JTkZPICovCisJX191MzIJcmVzZXJ2ZWQ7CisJX191NjQJc3NldF9tYXNr
OwkvKiBpbnB1dDogZWFjaCBiaXQgc2VsZWN0cyBhbiBzc2V0IHRvIHF1ZXJ5ICovCisJCQkJ
Lyogb3V0cHV0OiBlYWNoIGJpdCBhIHJldHVybmVkIHNzZXQgKi8KKwlfX3UzMglkYXRhWzBd
OwkvKiBFVEhfU1NfeHh4IGNvdW50LCBpbiBvcmRlciwgYmFzZWQgb24gYml0cworCQkJCSAg
IGluIHNzZXRfbWFzay4gIE9uZSBiaXQgaW1wbGllcyBvbmUKKwkJCQkgICBfX3UzMiwgdHdv
IGJpdHMgaW1wbGllcyB0d28KKwkJCQkgICBfX3UzMidzLCBldGMuICovCit9OworCiBlbnVt
IGV0aHRvb2xfdGVzdF9mbGFncyB7CiAJRVRIX1RFU1RfRkxfT0ZGTElORQk9ICgxIDw8IDAp
LAkvKiBvbmxpbmUgLyBvZmZsaW5lICovCiAJRVRIX1RFU1RfRkxfRkFJTEVECT0gKDEgPDwg
MSksCS8qIHRlc3QgcGFzc2VkIC8gZmFpbGVkICovCkBAIC02MDcsOSArNjE4LDkgQEAgc3Ry
dWN0IGV0aHRvb2xfb3BzIHsKICNkZWZpbmUJRVRIVE9PTF9TUlhDTFNSTElOUwkweDAwMDAw
MDMyIC8qIEluc2VydCBSWCBjbGFzc2lmaWNhdGlvbiBydWxlICovCiAjZGVmaW5lCUVUSFRP
T0xfRkxBU0hERVYJMHgwMDAwMDAzMyAvKiBGbGFzaCBmaXJtd2FyZSB0byBkZXZpY2UgKi8K
ICNkZWZpbmUJRVRIVE9PTF9SRVNFVAkJMHgwMDAwMDAzNCAvKiBSZXNldCBoYXJkd2FyZSAq
LwotCi0jZGVmaW5lIEVUSFRPT0xfU1JYTlRVUExFCTB4MDAwMDAwMzUgLyogQWRkIGFuIG4t
dHVwbGUgZmlsdGVyIHRvIGRldmljZSAqLwotI2RlZmluZSBFVEhUT09MX0dSWE5UVVBMRQkw
eDAwMDAwMDM2IC8qIEdldCBuLXR1cGxlIGZpbHRlcnMgZnJvbSBkZXZpY2UgKi8KKyNkZWZp
bmUJRVRIVE9PTF9TUlhOVFVQTEUJMHgwMDAwMDAzNSAvKiBBZGQgYW4gbi10dXBsZSBmaWx0
ZXIgdG8gZGV2aWNlICovCisjZGVmaW5lCUVUSFRPT0xfR1JYTlRVUExFCTB4MDAwMDAwMzYg
LyogR2V0IG4tdHVwbGUgZmlsdGVycyBmcm9tIGRldmljZSAqLworI2RlZmluZQlFVEhUT09M
X0dTU0VUX0lORk8JMHgwMDAwMDAzNyAvKiBHZXQgc3RyaW5nIHNldCBpbmZvICovCiAKIC8q
IGNvbXBhdGliaWxpdHkgd2l0aCBvbGRlciBjb2RlICovCiAjZGVmaW5lIFNQQVJDX0VUSF9H
U0VUCQlFVEhUT09MX0dTRVQKZGlmZiAtLWdpdCBhL25ldC9jb3JlL2V0aHRvb2wuYyBiL25l
dC9jb3JlL2V0aHRvb2wuYwppbmRleCAxYzk0ZjQ4Li5jMDE5ZjkyIDEwMDY0NAotLS0gYS9u
ZXQvY29yZS9ldGh0b29sLmMKKysrIGIvbmV0L2NvcmUvZXRodG9vbC5jCkBAIC0yNDEsNiAr
MjQxLDY5IEBAIHN0YXRpYyBub2lubGluZSBpbnQgZXRodG9vbF9nZXRfZHJ2aW5mbyhzdHJ1
Y3QgbmV0X2RldmljZSAqZGV2LCB2b2lkIF9fdXNlciAqdXNlCiAvKgogICogbm9pbmxpbmUg
YXR0cmlidXRlIHNvIHRoYXQgZ2NjIGRvZXNudCB1c2UgdG9vIG11Y2ggc3RhY2sgaW4gZGV2
X2V0aHRvb2woKQogICovCitzdGF0aWMgbm9pbmxpbmUgaW50IGV0aHRvb2xfZ2V0X3NzZXRf
aW5mbyhzdHJ1Y3QgbmV0X2RldmljZSAqZGV2LCB2b2lkIF9fdXNlciAqdXNlcmFkZHIpCit7
CisJc3RydWN0IGV0aHRvb2xfc3NldF9pbmZvIGluZm87CisJY29uc3Qgc3RydWN0IGV0aHRv
b2xfb3BzICpvcHMgPSBkZXYtPmV0aHRvb2xfb3BzOworCXU2NCBzc2V0X21hc2s7CisJaW50
IGksIGlkeCA9IDAsIG5fYml0cyA9IDAsIHJldCwgcmM7CisJdTMyICppbmZvX2J1ZiA9IE5V
TEw7CisKKwlpZiAoIW9wcy0+Z2V0X3NzZXRfY291bnQpCisJCXJldHVybiAtRU9QTk9UU1VQ
UDsKKworCWlmIChjb3B5X2Zyb21fdXNlcigmaW5mbywgdXNlcmFkZHIsIHNpemVvZihpbmZv
KSkpCisJCXJldHVybiAtRUZBVUxUOworCisJLyogc3RvcmUgY29weSBvZiBtYXNrLCBiZWNh
dXNlIHdlIHplcm8gc3RydWN0IGxhdGVyIG9uICovCisJc3NldF9tYXNrID0gaW5mby5zc2V0
X21hc2s7CisJaWYgKCFzc2V0X21hc2spCisJCXJldHVybiAwOworCisJLyogY2FsY3VsYXRl
IHNpemUgb2YgcmV0dXJuIGJ1ZmZlciAqLworCWZvciAoaSA9IDA7IGkgPCA2NDsgaSsrKQor
CQlpZiAoc3NldF9tYXNrICYgKDFVTEwgPDwgaSkpCisJCQluX2JpdHMrKzsKKworCW1lbXNl
dCgmaW5mbywgMCwgc2l6ZW9mKGluZm8pKTsKKwlpbmZvLmNtZCA9IEVUSFRPT0xfR1NTRVRf
SU5GTzsKKworCWluZm9fYnVmID0ga3phbGxvYyhuX2JpdHMgKiBzaXplb2YodTMyKSwgR0ZQ
X1VTRVIpOworCWlmICghaW5mb19idWYpCisJCXJldHVybiAtRU5PTUVNOworCisJLyogZmls
bCByZXR1cm4gYnVmZmVyIGJhc2VkIG9uIGlucHV0IGJpdG1hc2sgYW5kIHN1Y2Nlc3NmdWwg
CisJICogZ2V0X3NzZXRfY291bnQgcmV0dXJuCisJICovCisJZm9yIChpID0gMDsgaSA8IDY0
OyBpKyspIHsKKwkJaWYgKCEoc3NldF9tYXNrICYgKDFVTEwgPDwgaSkpKQorCQkJY29udGlu
dWU7CisKKwkJcmMgPSBvcHMtPmdldF9zc2V0X2NvdW50KGRldiwgaSk7CisJCWlmIChyYyA+
PSAwKSB7CisJCQlpbmZvLnNzZXRfbWFzayB8PSAoMVVMTCA8PCBpKTsKKwkJCWluZm9fYnVm
W2lkeCsrXSA9IHJjOworCQl9CisJfQorCisJcmV0ID0gLUVGQVVMVDsKKwlpZiAoY29weV90
b191c2VyKHVzZXJhZGRyLCAmaW5mbywgc2l6ZW9mKGluZm8pKSkKKwkJZ290byBvdXQ7CisK
Kwl1c2VyYWRkciArPSBvZmZzZXRvZihzdHJ1Y3QgZXRodG9vbF9zc2V0X2luZm8sIGRhdGEp
OworCWlmIChjb3B5X3RvX3VzZXIodXNlcmFkZHIsIGluZm9fYnVmLCBpZHggKiBzaXplb2Yo
dTMyKSkpCisJCWdvdG8gb3V0OworCisJcmV0ID0gMDsKKworb3V0OgorCWtmcmVlKGluZm9f
YnVmKTsKKwlyZXR1cm4gcmV0OworfQorCisvKgorICogbm9pbmxpbmUgYXR0cmlidXRlIHNv
IHRoYXQgZ2NjIGRvZXNudCB1c2UgdG9vIG11Y2ggc3RhY2sgaW4gZGV2X2V0aHRvb2woKQor
ICovCiBzdGF0aWMgbm9pbmxpbmUgaW50IGV0aHRvb2xfc2V0X3J4bmZjKHN0cnVjdCBuZXRf
ZGV2aWNlICpkZXYsIHZvaWQgX191c2VyICp1c2VyYWRkcikKIHsKIAlzdHJ1Y3QgZXRodG9v
bF9yeG5mYyBjbWQ7CkBAIC0xNDcyLDYgKzE1MzUsOSBAQCBpbnQgZGV2X2V0aHRvb2woc3Ry
dWN0IG5ldCAqbmV0LCBzdHJ1Y3QgaWZyZXEgKmlmcikKIAljYXNlIEVUSFRPT0xfR1JYTlRV
UExFOgogCQlyYyA9IGV0aHRvb2xfZ2V0X3J4X250dXBsZShkZXYsIHVzZXJhZGRyKTsKIAkJ
YnJlYWs7CisJY2FzZSBFVEhUT09MX0dTU0VUX0lORk86CisJCXJjID0gZXRodG9vbF9nZXRf
c3NldF9pbmZvKGRldiwgdXNlcmFkZHIpOworCQlicmVhazsKIAlkZWZhdWx0OgogCQlyYyA9
IC1FT1BOT1RTVVBQOwogCX0K
--------------020304070302040201030705--
