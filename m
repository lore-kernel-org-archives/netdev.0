From: Roy Marples <roy@marples.name>
Subject: [PATCH] ipv6: do not add link-local address if one already exists
Date: Sun, 10 Aug 2014 19:56:05 +0000
Message-ID: <d630f87aa617098553c3a3361fcf50aa@mail.marples.name>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="=_fbe933066cfc96b5fd3bc878457d5377"
Cc: "David S. Miller\" <davem@davemloft.net>, Alexey Kuznetsov
	<kuznet@ms2.inr.ac.ru>, Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy" <kaber@trash.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from uberserver.marples.name ([77.75.106.61]:56464 "EHLO
	mail.marples.name" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751134AbaHJUGT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 10 Aug 2014 16:06:19 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--=_fbe933066cfc96b5fd3bc878457d5377
Content-Transfer-Encoding: 7bit
Content-Type: text/plain; charset=US-ASCII;
 format=flowed

Hi

Currently the kernel will always add an IPv6 link-local address
based on the hardware address when the interface is brought up.
This is probably based on the assumption that userland would
never add one before the interface is brought up.

However, one at least one userland application (dhcpcd) does this so
it can implement RFC7217 which can be used for link-local addresses
as well.

Attached is a patch which checks to see if a link-local address exists
before indiscriminately adding one.

Thanks

Roy
--=_fbe933066cfc96b5fd3bc878457d5377
Content-Transfer-Encoding: base64
Content-Type: text/x-diff;
 name=linux-ipv6-onelladdr.diff
Content-Disposition: attachment;
 filename=linux-ipv6-onelladdr.diff;
 size=598

VGhpcyBhbGxvd3MgdXNlcmxhbmQgdG8gc2V0IGEgcG9zc2libHkgZGlmZmVyZW50IGxpbmstbG9j
YWwgYWRkcmVzcwpsaWtlIHNheSBvbmUgYmFzZWQgb24gUkZDNzIxNy4KClNpZ25lZC1vZmYtYnk6
IFJveSBNYXJwbGVzIDxyb3lAbWFycGxlcy5uYW1lPgoKLS0tIG5ldC9pcHY2L2FkZHJjb25mLmMu
b3JpZwkyMDE0LTA4LTEwIDE5OjM5OjUwLjM3NzA3MzQxNyArMDAwMAorKysgbmV0L2lwdjYvYWRk
cmNvbmYuYwkyMDE0LTA4LTEwIDIwOjE5OjAzLjEzOTAwMjA1MSArMDAwMApAQCAtMjc1MSw2ICsy
NzUxLDExIEBAIHN0YXRpYyB2b2lkIGFkZHJjb25mX2Rldl9jb25maWcoc3RydWN0IG4KIAlpZiAo
SVNfRVJSKGlkZXYpKQogCQlyZXR1cm47CiAKKwkvKiBJZiB3ZSBhbHJlYWR5IGhhdmUgYSBsaW5r
LWxvY2FsIGFkZHJlc3MsIGRvbid0IGJvdGhlcgorCSAqIGFkZGluZyBhIG5ldyBvbmUuICovCisJ
aWYgKGlwdjZfZ2V0X2xsYWRkcihkZXYsICZhZGRyLCAwKSA9PSAwKQorCQlyZXR1cm47CisKIAlt
ZW1zZXQoJmFkZHIsIDAsIHNpemVvZihzdHJ1Y3QgaW42X2FkZHIpKTsKIAlhZGRyLnM2X2FkZHIz
MlswXSA9IGh0b25sKDB4RkU4MDAwMDApOwogCg==
--=_fbe933066cfc96b5fd3bc878457d5377--
