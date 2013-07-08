From: Andrey Wagin <avagin@gmail.com>
Subject: Re: [PATCH] ip: set the close-on-exec flag for descriptors
Date: Mon, 8 Jul 2013 19:51:08 +0400
Message-ID: <CANaxB-wjwobCnYBsL2mpR9V=WR5w7_cCgR6Pp9OA72rtVsD27A@mail.gmail.com>
References: <1370332874-584-1-git-send-email-avagin@openvz.org>
	<20130604091150.48f3b1ca@nehalam.linuxnetplumber.net>
	<1373293036.4979.105.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary=047d7b6d7f285230cb04e1020347
Cc: Stephen Hemminger <stephen@networkplumber.org>,
	netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vb0-f43.google.com ([209.85.212.43]:46470 "EHLO
	mail-vb0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751399Ab3GHPvK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Jul 2013 11:51:10 -0400
Received: by mail-vb0-f43.google.com with SMTP id e12so3520707vbg.30
        for <netdev@vger.kernel.org>; Mon, 08 Jul 2013 08:51:10 -0700 (PDT)
In-Reply-To: <1373293036.4979.105.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--047d7b6d7f285230cb04e1020347
Content-Type: text/plain; charset=ISO-8859-1

Hi Eric,

2013/7/8 Eric Dumazet <eric.dumazet@gmail.com>:
>> Applied
>
> It seems it could break ip command for old kernels, as SOCK_CLOEXEC is
> supported from 2.6.27
>
> Not sure if its worth a patch, to do the normal socket() call followed
> by legacy fcntl() one.

fcntl is not safe for multithread applications. If libnetlink isn't
going to be used for them, I don't have objection. The patch is
attached.

Thanks.

--047d7b6d7f285230cb04e1020347
Content-Type: application/octet-stream;
	name="0001-ip-avoid-using-SOCK_CLOEXEC-to-save-backward-compati.patch"
Content-Disposition: attachment;
	filename="0001-ip-avoid-using-SOCK_CLOEXEC-to-save-backward-compati.patch"
Content-Transfer-Encoding: base64
X-Attachment-Id: f_hivufvta0

RnJvbSA5NzBkMjQwOTczMjNmNWQzMTZjZjE2MGYzYmM3MTFkNWY3NDBkYjM2IE1vbiBTZXAgMTcg
MDA6MDA6MDAgMjAwMQpGcm9tOiBBbmRyZXkgVmFnaW4gPGF2YWdpbkBvcGVudnoub3JnPgpEYXRl
OiBNb24sIDggSnVsIDIwMTMgMTk6MDg6MzYgKzA0MDAKU3ViamVjdDogW1BBVENIXSBpcDogYXZv
aWQgdXNpbmcgU09DS19DTE9FWEVDIHRvIHNhdmUgYmFja3dhcmQgY29tcGF0aWJpbGl0eQoKRXJp
YyBEdW1hemV0IHdyb3RlLCB0aGF0IFNPQ0tfQ0xPRVhFQyBjb3VsZCBicmVhayBpcCBjb21tYW5k
IGZvciBvbGQKa2VybmVscywgYXMgU09DS19DTE9FWEVDIGlzIHN1cHBvcnRlZCBmcm9tIDIuNi4y
Ny4KCkJUVzogZmNudGwoU09DS19DTE9FWEVDKSBpcyBub3Qgc2FmZSBmb3IgbXVsdGl0aHJlYWQg
YXBwbGljYXRpb25zLgoKUmVwb3J0ZWQtYnk6IDxlcmljLmR1bWF6ZXRAZ21haWwuY29tPgpTaWdu
ZWQtb2ZmLWJ5OiBBbmRyZXkgVmFnaW4gPGF2YWdpbkBvcGVudnoub3JnPgotLS0KIGxpYi9saWJu
ZXRsaW5rLmMgfCA3ICsrKysrKy0KIDEgZmlsZSBjaGFuZ2VkLCA2IGluc2VydGlvbnMoKyksIDEg
ZGVsZXRpb24oLSkKCmRpZmYgLS1naXQgYS9saWIvbGlibmV0bGluay5jIGIvbGliL2xpYm5ldGxp
bmsuYwppbmRleCA5ZTJhNzk1Li45OTJhYWJkIDEwMDY0NAotLS0gYS9saWIvbGlibmV0bGluay5j
CisrKyBiL2xpYi9saWJuZXRsaW5rLmMKQEAgLTQzLDEyICs0MywxNyBAQCBpbnQgcnRubF9vcGVu
X2J5cHJvdG8oc3RydWN0IHJ0bmxfaGFuZGxlICpydGgsIHVuc2lnbmVkIHN1YnNjcmlwdGlvbnMs
CiAKIAltZW1zZXQocnRoLCAwLCBzaXplb2YoKnJ0aCkpOwogCi0JcnRoLT5mZCA9IHNvY2tldChB
Rl9ORVRMSU5LLCBTT0NLX1JBVyB8IFNPQ0tfQ0xPRVhFQywgcHJvdG9jb2wpOworCXJ0aC0+ZmQg
PSBzb2NrZXQoQUZfTkVUTElOSywgU09DS19SQVcsIHByb3RvY29sKTsKIAlpZiAocnRoLT5mZCA8
IDApIHsKIAkJcGVycm9yKCJDYW5ub3Qgb3BlbiBuZXRsaW5rIHNvY2tldCIpOwogCQlyZXR1cm4g
LTE7CiAJfQogCisJaWYgKGZjbnRsKHJ0aC0+ZmQsIEZfU0VURkQsIEZEX0NMT0VYRUMpKSB7CisJ
CXBlcnJvcigiQ2Fubm90IHNldCB0aGUgY2xvc2Utb24tZXhlYyBmbGFnIik7CisJCXJldHVybiAt
MTsKKwl9CisKIAlpZiAoc2V0c29ja29wdChydGgtPmZkLFNPTF9TT0NLRVQsU09fU05EQlVGLCZz
bmRidWYsc2l6ZW9mKHNuZGJ1ZikpIDwgMCkgewogCQlwZXJyb3IoIlNPX1NOREJVRiIpOwogCQly
ZXR1cm4gLTE7Ci0tIAoxLjguMy4xCgo=
--047d7b6d7f285230cb04e1020347--
