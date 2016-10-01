From: Martin Blumenstingl <martin.blumenstingl@googlemail.com>
Subject: Re: stmmac/RTL8211F/Meson GXBB: TX throughput problems
Date: Sat, 1 Oct 2016 22:40:59 +0200
Message-ID: <CAFBinCAA9J4o2cs4ruSuPRH4qK6izDoxJCneE=Uogk0c+_DSkQ@mail.gmail.com>
References: <CAFBinCALSL_-izJ2tEsAjevAw90kGNTrQ3na3D1YV8f1dS1=Xg@mail.gmail.com>
 <ce15ad26-2d07-655d-b813-947ad86696ac@st.com> <CAFBinCC0HiEXx5mELztH6jYfUq2f1u0Tb+pSzAvwQSu9vYydGQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary=001a114cbec0be1796053dd3bb40
Cc: netdev@vger.kernel.org, linux-amlogic@lists.infradead.org,
        Alexandre Torgue <alexandre.torgue@st.com>,
        Johnson Leung <r58129@freescale.com>
To: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f48.google.com ([74.125.82.48]:36026 "EHLO
        mail-wm0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750947AbcJAUlW (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 1 Oct 2016 16:41:22 -0400
Received: by mail-wm0-f48.google.com with SMTP id k125so84444133wma.1
        for <netdev@vger.kernel.org>; Sat, 01 Oct 2016 13:41:21 -0700 (PDT)
In-Reply-To: <CAFBinCC0HiEXx5mELztH6jYfUq2f1u0Tb+pSzAvwQSu9vYydGQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--001a114cbec0be1796053dd3bb40
Content-Type: text/plain; charset=UTF-8

On Sat, Oct 1, 2016 at 10:15 PM, Martin Blumenstingl
<martin.blumenstingl@googlemail.com> wrote:
> On Wed, Sep 14, 2016 at 5:30 PM, Giuseppe CAVALLARO
> <peppe.cavallaro@st.com> wrote:
>> Also you could check the AXI tuning and PBL value. To be honest
>> (thinking about your problem) I can actually suspect some related
>> problem on bus setup. So I suggest you to play with these value
>> (better if you ask for having values from HW validation on your side).
>> Otherwise the stmmac uses a default that cannot be good for your
>> platform. For example, sometime I have seen that PBL is better if
>> reduced to 8 instead of 32 and w/o 4xPBL...
> unfortunately the original kernel/firmware shipped with my device
> seems to be also affected by that TX bug, so comparing with the
> "stock" values does not work for me.
I tried the following changes:
- snps,pbl = <4>; in .dts
- snps,pbl = <2>; in .dts
- snps,pbl = <8>; in .dts and disabled DMA_BUS_MODE_MAXPBL (= 4xPBL) in stmmac

None of these seem to have any impact on the TX problem

--001a114cbec0be1796053dd3bb40
Content-Type: text/x-patch; charset=US-ASCII; name="meson-stmmac-pbl.patch"
Content-Disposition: attachment; filename="meson-stmmac-pbl.patch"
Content-Transfer-Encoding: base64
X-Attachment-Id: f_itrnwe6w0

ZGlmZiAtLWdpdCBhL2FyY2gvYXJtNjQvYm9vdC9kdHMvYW1sb2dpYy9tZXNvbi1neGJiLmR0c2kg
Yi9hcmNoL2FybTY0L2Jvb3QvZHRzL2FtbG9naWMvbWVzb24tZ3hiYi5kdHNpCmluZGV4IDJlODll
YzQuLjdkZWFiN2EgMTAwNjQ0Ci0tLSBhL2FyY2gvYXJtNjQvYm9vdC9kdHMvYW1sb2dpYy9tZXNv
bi1neGJiLmR0c2kKKysrIGIvYXJjaC9hcm02NC9ib290L2R0cy9hbWxvZ2ljL21lc29uLWd4YmIu
ZHRzaQpAQCAtNjk4LDYgKzY5OCw3IEBACiAJCQkJIDwmY2xrYyBDTEtJRF9NUExMMj47CiAJCQlj
bG9jay1uYW1lcyA9ICJzdG1tYWNldGgiLCAiY2xraW4wIiwgImNsa2luMSI7CiAJCQlwaHktbW9k
ZSA9ICJyZ21paSI7CisJCQlzbnBzLHBibCA9IDw4PjsKIAkJCXN0YXR1cyA9ICJkaXNhYmxlZCI7
CiAJCX07CiAJfTsKZGlmZiAtLWdpdCBhL2RyaXZlcnMvbmV0L2V0aGVybmV0L3N0bWljcm8vc3Rt
bWFjL2R3bWFjMTAwMF9kbWEuYyBiL2RyaXZlcnMvbmV0L2V0aGVybmV0L3N0bWljcm8vc3RtbWFj
L2R3bWFjMTAwMF9kbWEuYwppbmRleCA5OTA3NDY5NS4uZmZmYjQwNyAxMDA2NDQKLS0tIGEvZHJp
dmVycy9uZXQvZXRoZXJuZXQvc3RtaWNyby9zdG1tYWMvZHdtYWMxMDAwX2RtYS5jCisrKyBiL2Ry
aXZlcnMvbmV0L2V0aGVybmV0L3N0bWljcm8vc3RtbWFjL2R3bWFjMTAwMF9kbWEuYwpAQCAtOTcs
NyArOTcsNyBAQCBzdGF0aWMgdm9pZCBkd21hYzEwMDBfZG1hX2luaXQodm9pZCBfX2lvbWVtICpp
b2FkZHIsIGludCBwYmwsIGludCBmYiwgaW50IG1iLAogCSAqIHNvIG9ubHkgdGhlIGJpdHM6IDEz
LTggYXJlIHByb2dyYW1tZWQgd2l0aCB0aGUgUEJMIHBhc3NlZCBmcm9tIHRoZQogCSAqIHBsYXRm
b3JtLgogCSAqLwotCXZhbHVlIHw9IERNQV9CVVNfTU9ERV9NQVhQQkw7CisJdmFsdWUgJj0gfkRN
QV9CVVNfTU9ERV9NQVhQQkw7CiAJdmFsdWUgJj0gfkRNQV9CVVNfTU9ERV9QQkxfTUFTSzsKIAl2
YWx1ZSB8PSAocGJsIDw8IERNQV9CVVNfTU9ERV9QQkxfU0hJRlQpOwogCg==
--001a114cbec0be1796053dd3bb40--
