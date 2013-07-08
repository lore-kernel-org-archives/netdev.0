From: Andrey Wagin <avagin@gmail.com>
Subject: Re: [PATCH] ip: set the close-on-exec flag for descriptors
Date: Mon, 8 Jul 2013 23:23:35 +0400
Message-ID: <CANaxB-zLiUsr2OG2J65jb8sa6G4i93m2j=-3F5_p+WB-Xd8ZhA@mail.gmail.com>
References: <1370332874-584-1-git-send-email-avagin@openvz.org>
	<20130604091150.48f3b1ca@nehalam.linuxnetplumber.net>
	<1373293036.4979.105.camel@edumazet-glaptop>
	<CANaxB-wjwobCnYBsL2mpR9V=WR5w7_cCgR6Pp9OA72rtVsD27A@mail.gmail.com>
	<1373299506.4979.112.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary=20cf307d066a176ea104e104fbb7
Cc: Stephen Hemminger <stephen@networkplumber.org>,
	netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vb0-f54.google.com ([209.85.212.54]:40167 "EHLO
	mail-vb0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752912Ab3GHTXg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Jul 2013 15:23:36 -0400
Received: by mail-vb0-f54.google.com with SMTP id q12so3703081vbe.41
        for <netdev@vger.kernel.org>; Mon, 08 Jul 2013 12:23:35 -0700 (PDT)
In-Reply-To: <1373299506.4979.112.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--20cf307d066a176ea104e104fbb7
Content-Type: text/plain; charset=ISO-8859-1

2013/7/8 Eric Dumazet <eric.dumazet@gmail.com>:
> On Mon, 2013-07-08 at 19:51 +0400, Andrey Wagin wrote:
>> Hi Eric,
>>
>> 2013/7/8 Eric Dumazet <eric.dumazet@gmail.com>:
>> >> Applied
>> >
>> > It seems it could break ip command for old kernels, as SOCK_CLOEXEC is
>> > supported from 2.6.27
>> >
>> > Not sure if its worth a patch, to do the normal socket() call followed
>> > by legacy fcntl() one.
>>
>> fcntl is not safe for multithread applications. If libnetlink isn't
>> going to be used for them, I don't have objection. The patch is
>> attached.
>>
>
> If you want multithread safety, you could attempt the SOCK_CLOEXEC, and
> fall back in case of error to legacy socket()/fcntl()
>

Yes, it's good idea. Look at the attached patch.

Thanks.

>
>

--20cf307d066a176ea104e104fbb7
Content-Type: application/octet-stream;
	name="0001-ip-try-to-create-socket-w-o-SOCK_CLOEXEC-if-previous.patch"
Content-Disposition: attachment;
	filename="0001-ip-try-to-create-socket-w-o-SOCK_CLOEXEC-if-previous.patch"
Content-Transfer-Encoding: base64
X-Attachment-Id: f_hiw21c7m0

RnJvbSA5ZTRiYzE3ZDQ1N2FkZWQwNWMwY2JiOWM1ODI4NWYxNWY0ZjFjNDA2IE1vbiBTZXAgMTcg
MDA6MDA6MDAgMjAwMQpGcm9tOiBBbmRyZXkgVmFnaW4gPGF2YWdpbkBvcGVudnoub3JnPgpEYXRl
OiBNb24sIDggSnVsIDIwMTMgMTk6MDg6MzYgKzA0MDAKU3ViamVjdDogW1BBVENIXSBpcDogdHJ5
IHRvIGNyZWF0ZSBzb2NrZXQgdy9vIFNPQ0tfQ0xPRVhFQywgaWYgcHJldmlvdXMKIGF0dGVtcHQg
ZmFpbGVkCgpTT0NLX0NMT0VYRUMgaXMgc3VwcG9ydGVkIGZyb20gMi42LjI3CgpDcmVhdGUgc29j
a2V0IHdpdGggU09DS19DTE9FWEVDLCBpZiB0aGlzIG9wZXJhdGlvbiBmYWlsZWQgd2l0aCBFSU5W
QUwsCnRyeSB0byBjcmVhdGUgc29ja2V0IHcvbyBTT0NLX0NMT0VYRUMgYW5kIHNldCBTT0NLX0NM
T0VYRUMgd2l0aCBoZWxwCmZjbnRsLgoKVGhlIHNlY29uZCB3YXkgaXMgbm90IHNhZmUgZm9yIG11
bHRpdGhyZWFkZWQgYXBwbGljYXRpb24sIGJ1dCBpdCdzCmJldHRlciB0aGFuIGRvbid0IGNsb3Nl
IGZkIGF0IGFsbC4KClJlcG9ydGVkLWJ5OiBFcmljIER1bWF6ZXQgPGVyaWMuZHVtYXpldEBnbWFp
bC5jb20+ClNpZ25lZC1vZmYtYnk6IEFuZHJleSBWYWdpbiA8YXZhZ2luQG9wZW52ei5vcmc+Ci0t
LQogbGliL2xpYm5ldGxpbmsuYyB8IDEwICsrKysrKysrKysKIDEgZmlsZSBjaGFuZ2VkLCAxMCBp
bnNlcnRpb25zKCspCgpkaWZmIC0tZ2l0IGEvbGliL2xpYm5ldGxpbmsuYyBiL2xpYi9saWJuZXRs
aW5rLmMKaW5kZXggOWUyYTc5NS4uNDhhNGRhMiAxMDA2NDQKLS0tIGEvbGliL2xpYm5ldGxpbmsu
YworKysgYi9saWIvbGlibmV0bGluay5jCkBAIC00NCw2ICs0NCwxNiBAQCBpbnQgcnRubF9vcGVu
X2J5cHJvdG8oc3RydWN0IHJ0bmxfaGFuZGxlICpydGgsIHVuc2lnbmVkIHN1YnNjcmlwdGlvbnMs
CiAJbWVtc2V0KHJ0aCwgMCwgc2l6ZW9mKCpydGgpKTsKIAogCXJ0aC0+ZmQgPSBzb2NrZXQoQUZf
TkVUTElOSywgU09DS19SQVcgfCBTT0NLX0NMT0VYRUMsIHByb3RvY29sKTsKKwlpZiAocnRoLT5m
ZCA8IDAgJiYgZXJybm8gPT0gRUlOVkFMKSB7CisJCS8qIFNPQ0tfQ0xPRVhFQyBpcyBzdXBwb3J0
ZWQgZnJvbSAyLjYuMjcgKi8KKwkJcnRoLT5mZCA9IHNvY2tldChBRl9ORVRMSU5LLCBTT0NLX1JB
VywgcHJvdG9jb2wpOworCQlpZiAocnRoLT5mZCA+PSAwKQorCQkJaWYgKGZjbnRsKHJ0aC0+ZmQs
IEZfU0VURkQsIEZEX0NMT0VYRUMpKSB7CisJCQkJcGVycm9yKCJDYW5ub3Qgc2V0IHRoZSBjbG9z
ZS1vbi1leGVjIGZsYWciKTsKKwkJCQlyZXR1cm4gLTE7CisJCQl9CisJfQorCiAJaWYgKHJ0aC0+
ZmQgPCAwKSB7CiAJCXBlcnJvcigiQ2Fubm90IG9wZW4gbmV0bGluayBzb2NrZXQiKTsKIAkJcmV0
dXJuIC0xOwotLSAKMS44LjMuMQoK
--20cf307d066a176ea104e104fbb7--
