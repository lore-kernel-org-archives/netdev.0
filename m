From: "Jason A. Donenfeld" <Jason@zx2c4.com>
Subject: Re: cross namespace interface notification for tun devices
Date: Tue, 19 Sep 2017 03:24:05 +0200
Message-ID: <CAHmME9pACTes07b3=JKgh8GOCOX4w64EwxrGmGbSRGQtssNHMQ@mail.gmail.com>
References: <CAHmME9pD_kees+xrjTeWXgi26UdhbMVgvoddbCyueTZkbguvAg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="001a113ceb8e17083c055980b778"
Cc: Mathias <mathias@hall-andersen.dk>
To: Netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from frisell.zx2c4.com ([192.95.5.64]:36961 "EHLO frisell.zx2c4.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751307AbdISBYI (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 18 Sep 2017 21:24:08 -0400
Received: by frisell.zx2c4.com (ZX2C4 Mail Server) with ESMTP id 51628b6c
        for <netdev@vger.kernel.org>;
        Tue, 19 Sep 2017 01:16:07 +0000 (UTC)
Received: by frisell.zx2c4.com (ZX2C4 Mail Server) with ESMTPSA id 8218788b (TLSv1.2:ECDHE-RSA-AES128-GCM-SHA256:128:NO)
        for <netdev@vger.kernel.org>;
        Tue, 19 Sep 2017 01:16:06 +0000 (UTC)
Received: by mail-io0-f178.google.com with SMTP id m103so6460030iod.13
        for <netdev@vger.kernel.org>; Mon, 18 Sep 2017 18:24:06 -0700 (PDT)
In-Reply-To: <CAHmME9pD_kees+xrjTeWXgi26UdhbMVgvoddbCyueTZkbguvAg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--001a113ceb8e17083c055980b778
Content-Type: text/plain; charset="UTF-8"

On Mon, Sep 18, 2017 at 8:47 PM, Jason A. Donenfeld <Jason@zx2c4.com> wrote:
> The best I've come up with is, in a sleep loop, writing to the tun
> device's fd something with a NULL or invalid payload. If the interface
> is down, the kernel returns -EIO. If the interface is up, the kernel
> returns -EINVAL. This seems to be a reliable distinguisher, but is a
> pretty insane way of doing it. And sleep loops are somewhat different
> from events too.

Specifically, I'm referring to the horrific hack exemplified in the
attached .c file, in case anybody is curious about the details of what
I'd rather not use.

--001a113ceb8e17083c055980b778
Content-Type: text/x-csrc; charset="US-ASCII"; name="tuntest.c"
Content-Disposition: attachment; filename="tuntest.c"
Content-Transfer-Encoding: base64
X-Attachment-Id: f_j7qx1u5f0

I2luY2x1ZGUgPHN0ZGlvLmg+CiNpbmNsdWRlIDxzdGRsaWIuaD4KI2luY2x1ZGUgPHVuaXN0ZC5o
PgojaW5jbHVkZSA8ZmNudGwuaD4KI2luY2x1ZGUgPGVycm5vLmg+CiNpbmNsdWRlIDxzeXMvaW9j
dGwuaD4KI2luY2x1ZGUgPHN5cy90eXBlcy5oPgojaW5jbHVkZSA8c3lzL3N5c2NhbGwuaD4KI2lu
Y2x1ZGUgPGxpbnV4L2lmLmg+CiNpbmNsdWRlIDxsaW51eC9pZl90dW4uaD4KCmludCBtYWluKGlu
dCBhcmdjLCBjaGFyICphcmd2W10pCnsKCS8qIElmIElGRl9OT19QSSBpcyBzcGVjaWZpZWQsIHRo
aXMgc3RpbGwgc29ydCBvZiB3b3JrcyBidXQgaXQKCSAqIGJ1bXBzIHRoZSBkZXZpY2UgZXJyb3Ig
Y291bnRlcnMsIHdoaWNoIHdlIGRvbid0IHdhbnQsIHNvCgkgKiBpdCdzIGJlc3Qgbm90IHRvIHVz
ZSB0aGlzIHRyaWNrIHdpdGggSUZGX05PX1BJLiAqLwoJc3RydWN0IGlmcmVxIGlmciA9IHsgLmlm
cl9mbGFncyA9IElGRl9UVU4gfTsKCWludCB0dW4sIHNvY2ssIHJldDsKCgl0dW4gPSBvcGVuKCIv
ZGV2L25ldC90dW4iLCBPX1JEV1IpOwoJaWYgKHR1biA8IDApIHsKCQlwZXJyb3IoIlstXSBvcGVu
KC9kZXYvbmV0L3R1bikiKTsKCQlyZXR1cm4gMTsKCX0KCglzb2NrID0gc29ja2V0KEFGX0lORVQs
IFNPQ0tfREdSQU0sIDApOwoJaWYgKHNvY2sgPCAwKSB7CgkJcGVycm9yKCJbLV0gc29ja2V0KEFG
X0lORVQsIFNPQ0tfREdSQU0pIik7CgkJcmV0dXJuIDE7Cgl9CgoJcmV0ID0gaW9jdGwodHVuLCBU
VU5TRVRJRkYsICZpZnIpOwoJaWYgKHJldCA8IDApIHsKCQlwZXJyb3IoIlstXSBpb2N0bChUVU5T
RVRJRkYpIik7CgkJcmV0dXJuIDE7Cgl9CgoJaWYgKHdyaXRlKHR1biwgTlVMTCwgMCkgPj0gMCB8
fCBlcnJubyAhPSBFSU8pCgkJcGVycm9yKCJbLV0gd3JpdGUoaWY6ZG93biwgTlVMTCwgMCkgZGlk
IG5vdCByZXR1cm4gLUVJTyIpOwoJZWxzZQoJCWZwcmludGYoc3RkZXJyLCAiWytdIHdyaXRlKGlm
OmRvd24sIE5VTEwsIDApIHJldHVybmVkIC1FSU86IHRlc3Qgc3VjY2Vzc2Z1bFxuIik7CgoJaWZy
Lmlmcl9mbGFncyA9IElGRl9VUDsKCXJldCA9IGlvY3RsKHNvY2ssIFNJT0NTSUZGTEFHUywgJmlm
cik7CglpZiAocmV0IDwgMCkgewoJCXBlcnJvcigiWy1dIGlvY3RsKFNJT0NTSUZGTEFHUykiKTsK
CQlyZXR1cm4gMTsKCX0KCglpZiAod3JpdGUodHVuLCBOVUxMLCAwKSA+PSAwIHx8IGVycm5vICE9
IEVJTlZBTCkKCQlwZXJyb3IoIlstXSB3cml0ZShpZjp1cCwgTlVMTCwgMCkgZGlkIG5vdCByZXR1
cm4gLUVJTlZBTCIpOwoJZWxzZQoJCWZwcmludGYoc3RkZXJyLCAiWytdIHdyaXRlKGlmOnVwLCBO
VUxMLCAwKSByZXR1cm5lZCAtRUlOVkFMOiB0ZXN0IHN1Y2Nlc3NmdWxcbiIpOwoJCglyZXR1cm4g
MDsKfQo=
--001a113ceb8e17083c055980b778--
