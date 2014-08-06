From: Cong Wang <cwang@twopensource.com>
Subject: Re: linux-next: net/netlink/diag.c:106 suspicious rcu_dereference_protected()
 usage!
Date: Wed, 6 Aug 2014 14:20:59 -0700
Message-ID: <CAHA+R7OB_gTYPKtqw-iry+nfkTbmApw4GPpeKjqfXugcit4Guw@mail.gmail.com>
References: <CANaxB-ySsRXHPSEPOuExeKAvDX7esZ1WBZAVMTWQxtmfN2=i4w@mail.gmail.com>
	<CAHA+R7N0c83by=AAgw2nKPibYETNyv6JTEWnu5XOo-67fHMELw@mail.gmail.com>
	<20140806195127.GA26832@casper.infradead.org>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary=001a11345e0e72f2da04fffc8cc0
Cc: Andrey Wagin <avagin@gmail.com>, netdev <netdev@vger.kernel.org>
To: Thomas Graf <tgraf@suug.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f42.google.com ([209.85.215.42]:46417 "EHLO
	mail-la0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754266AbaHFVVB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Aug 2014 17:21:01 -0400
Received: by mail-la0-f42.google.com with SMTP id pv20so2840252lab.15
        for <netdev@vger.kernel.org>; Wed, 06 Aug 2014 14:21:00 -0700 (PDT)
In-Reply-To: <20140806195127.GA26832@casper.infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--001a11345e0e72f2da04fffc8cc0
Content-Type: text/plain; charset=UTF-8

On Wed, Aug 6, 2014 at 12:51 PM, Thomas Graf <tgraf@suug.ch> wrote:
> On 08/06/14 at 10:52am, Cong Wang wrote:
>>
>> Looks like we should hold rcu_read_lock() before calling __netlink_diag_dump().
>
> netlink_diag_dump() still acquires nl_table_lock which is pointless as
> a separate mutex has been introduced to protect mutations. I will send
> a patch to RCU'ify it properly.

Agreed, but that's likely a net-next material.

I think we need the following quick fix for net.

--001a11345e0e72f2da04fffc8cc0
Content-Type: text/plain; charset=US-ASCII; name="netlink-diag.diff"
Content-Disposition: attachment; filename="netlink-diag.diff"
Content-Transfer-Encoding: base64
X-Attachment-Id: f_hyj5tq9g0

ZGlmZiAtLWdpdCBhL25ldC9uZXRsaW5rL2RpYWcuYyBiL25ldC9uZXRsaW5rL2RpYWcuYwppbmRl
eCA3MzAxODUwLi4yZDk0YzQ5IDEwMDY0NAotLS0gYS9uZXQvbmV0bGluay9kaWFnLmMKKysrIGIv
bmV0L25ldGxpbmsvZGlhZy5jCkBAIC0xMDMsNyArMTAzLDcgQEAgc3RhdGljIGludCBfX25ldGxp
bmtfZGlhZ19kdW1wKHN0cnVjdCBza19idWZmICpza2IsIHN0cnVjdCBuZXRsaW5rX2NhbGxiYWNr
ICpjYiwKIHsKIAlzdHJ1Y3QgbmV0bGlua190YWJsZSAqdGJsID0gJm5sX3RhYmxlW3Byb3RvY29s
XTsKIAlzdHJ1Y3Qgcmhhc2h0YWJsZSAqaHQgPSAmdGJsLT5oYXNoOwotCWNvbnN0IHN0cnVjdCBi
dWNrZXRfdGFibGUgKmh0YmwgPSByaHRfZGVyZWZlcmVuY2UoaHQtPnRibCwgaHQpOworCWNvbnN0
IHN0cnVjdCBidWNrZXRfdGFibGUgKmh0Ymw7CiAJc3RydWN0IG5ldCAqbmV0ID0gc29ja19uZXQo
c2tiLT5zayk7CiAJc3RydWN0IG5ldGxpbmtfZGlhZ19yZXEgKnJlcTsKIAlzdHJ1Y3QgbmV0bGlu
a19zb2NrICpubHNrOwpAQCAtMTEyLDggKzExMiwxMSBAQCBzdGF0aWMgaW50IF9fbmV0bGlua19k
aWFnX2R1bXAoc3RydWN0IHNrX2J1ZmYgKnNrYiwgc3RydWN0IG5ldGxpbmtfY2FsbGJhY2sgKmNi
LAogCiAJcmVxID0gbmxtc2dfZGF0YShjYi0+bmxoKTsKIAorCXJjdV9yZWFkX2xvY2soKTsKKwlo
dGJsID0gcmh0X2RlcmVmZXJlbmNlX3JjdShodC0+dGJsLCBodCk7CisKIAlmb3IgKGkgPSAwOyBp
IDwgaHRibC0+c2l6ZTsgaSsrKSB7Ci0JCXJodF9mb3JfZWFjaF9lbnRyeShubHNrLCBodGJsLT5i
dWNrZXRzW2ldLCBodCwgbm9kZSkgeworCQlyaHRfZm9yX2VhY2hfZW50cnlfcmN1KG5sc2ssIGh0
YmwtPmJ1Y2tldHNbaV0sIG5vZGUpIHsKIAkJCXNrID0gKHN0cnVjdCBzb2NrICopbmxzazsKIAog
CQkJaWYgKCFuZXRfZXEoc29ja19uZXQoc2spLCBuZXQpKQpAQCAtMTI5LDEyICsxMzIsMTQgQEAg
c3RhdGljIGludCBfX25ldGxpbmtfZGlhZ19kdW1wKHN0cnVjdCBza19idWZmICpza2IsIHN0cnVj
dCBuZXRsaW5rX2NhbGxiYWNrICpjYiwKIAkJCQkJIE5MTV9GX01VTFRJLAogCQkJCQkgc29ja19p
X2lubyhzaykpIDwgMCkgewogCQkJCXJldCA9IDE7CisJCQkJcmN1X3JlYWRfdW5sb2NrKCk7CiAJ
CQkJZ290byBkb25lOwogCQkJfQogCiAJCQludW0rKzsKIAkJfQogCX0KKwlyY3VfcmVhZF91bmxv
Y2soKTsKIAogCXNrX2Zvcl9lYWNoX2JvdW5kKHNrLCAmdGJsLT5tY19saXN0KSB7CiAJCWlmIChz
a19oYXNoZWQoc2spKQo=
--001a11345e0e72f2da04fffc8cc0--
