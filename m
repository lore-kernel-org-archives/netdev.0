From: Risto Suominen <risto.suominen@gmail.com>
Subject: Re: [PATCH 002/002] de2104x: support for systems lacking cache
	coherence
Date: Wed, 11 Feb 2009 14:18:52 +0200
Message-ID: <46e1c7760902110418n276de9b2xa2169839b9e25dc0@mail.gmail.com>
References: <46e1c7760902090022g1d903ca0nf314f0c1cc6b07c8@mail.gmail.com>
	 <m3vdrja6oe.fsf@intrepid.localdomain>
	 <46e1c7760902091122m6ec7fbb5nefd9cc9789880c0f@mail.gmail.com>
	 <20090210.152143.176850113.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary=001636c59909556c260462a39ba3
Cc: khc@pm.waw.pl, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f20.google.com ([209.85.220.20]:43593 "EHLO
	mail-fx0-f20.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751873AbZBKMSy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Feb 2009 07:18:54 -0500
Received: by fxm13 with SMTP id 13so421377fxm.13
        for <netdev@vger.kernel.org>; Wed, 11 Feb 2009 04:18:52 -0800 (PST)
In-Reply-To: <20090210.152143.176850113.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--001636c59909556c260462a39ba3
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit

2009/2/11 David Miller <davem@davemloft.net>:
>
> I think the pci_alloc_consistent() implementation for your particular
> platform should be fixed instead :-)
>
Looks like it works as expected with 2.6.24. This patch is all that is needed.

Still I think that my first solution was beautiful in its simplicity
:) (and usable with older kernels)

Risto

Allow setting NOT_COHERENT_CACHE explicitly.

Signed-off-by: Risto Suominen <Risto.Suominen@gmail.com>
---
The testing is done on kernel version 2.6.24.

--- a/arch/powerpc/platforms/powermac/Kconfig.org	2008-01-25
00:58:37.000000000 +0200
+++ b/arch/powerpc/platforms/powermac/Kconfig	2009-02-10
17:44:24.000000000 +0200
@@ -18,4 +18,10 @@ config PPC_PMAC64
 	select PPC_970_NAP
 	default y

-
+config NOT_COHERENT_CACHE
+	bool "Incoherent cache"
+	default n
+	help
+	  Setting this option may be necessary for avoiding cache-related
+	  problems with some network cards on some platforms. An example is
+	  2104x and PowerMac 5500.

--001636c59909556c260462a39ba3
Content-Type: text/x-diff; charset=US-ASCII; name="incoherent_cache.patch"
Content-Disposition: attachment; filename="incoherent_cache.patch"
Content-Transfer-Encoding: base64
X-Attachment-Id: f_fr1ypeh50

QWxsb3cgc2V0dGluZyBOT1RfQ09IRVJFTlRfQ0FDSEUgZXhwbGljaXRseS4KClNpZ25lZC1vZmYt
Ynk6IFJpc3RvIFN1b21pbmVuIDxSaXN0by5TdW9taW5lbkBnbWFpbC5jb20+Ci0tLQpUaGUgdGVz
dGluZyBpcyBkb25lIG9uIGtlcm5lbCB2ZXJzaW9uIDIuNi4yNC4KCi0tLSBhL2FyY2gvcG93ZXJw
Yy9wbGF0Zm9ybXMvcG93ZXJtYWMvS2NvbmZpZy5vcmcJMjAwOC0wMS0yNSAwMDo1ODozNy4wMDAw
MDAwMDAgKzAyMDAKKysrIGIvYXJjaC9wb3dlcnBjL3BsYXRmb3Jtcy9wb3dlcm1hYy9LY29uZmln
CTIwMDktMDItMTAgMTc6NDQ6MjQuMDAwMDAwMDAwICswMjAwCkBAIC0xOCw0ICsxOCwxMCBAQCBj
b25maWcgUFBDX1BNQUM2NAogCXNlbGVjdCBQUENfOTcwX05BUAogCWRlZmF1bHQgeQogCi0KK2Nv
bmZpZyBOT1RfQ09IRVJFTlRfQ0FDSEUKKwlib29sICJJbmNvaGVyZW50IGNhY2hlIgorCWRlZmF1
bHQgbgorCWhlbHAKKwkgIFNldHRpbmcgdGhpcyBvcHRpb24gbWF5IGJlIG5lY2Vzc2FyeSBmb3Ig
YXZvaWRpbmcgY2FjaGUtcmVsYXRlZAorCSAgcHJvYmxlbXMgd2l0aCBzb21lIG5ldHdvcmsgY2Fy
ZHMgb24gc29tZSBwbGF0Zm9ybXMuIEFuIGV4YW1wbGUgaXMKKwkgIDIxMDR4IGFuZCBQb3dlck1h
YyA1NTAwLgo=
--001636c59909556c260462a39ba3--
