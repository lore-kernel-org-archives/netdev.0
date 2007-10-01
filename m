From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: 2.6.21 -> 2.6.22 & 2.6.23-rc8 performance regression
Date: Mon, 01 Oct 2007 22:10:03 +0200
Message-ID: <4701541B.70108@cosmosbay.com>
References: <20070930144443.M52139@visp.net.lb> <46FFE17C.9020202@cosmosbay.com> <200709301425.37564.nickpiggin@yahoo.com.au> <20070930223503.M8966@nuclearcat.com> <47008CB0.7010808@cosmosbay.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------000902080203060001020400"
Cc: linux-kernel@vger.kernel.org,
	Linux Netdev List <netdev@vger.kernel.org>
To: Denys <nuclearcat@nuclearcat.com>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([86.65.150.130]:34831 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751423AbXJAUKR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Oct 2007 16:10:17 -0400
In-Reply-To: <47008CB0.7010808@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------000902080203060001020400
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit

So maybe the following patch is necessary...

I believe IPV6 & DCCP are immune to this problem.

Thanks again Denys for spotting this.

Eric

[PATCH] TCP : secure_tcp_sequence_number() should not use a too fast clock

TCP V4 sequence numbers are 32bits, and RFC 793 assumed a 250 KHz clock.
In order to follow network speed increase, we can use a faster clock, but
we should limit this clock so that the delay between two rollovers is
greater than MSL (TCP Maximum Segment Lifetime : 2 minutes)

Choosing a 64 nsec clock should be OK, since the rollovers occur every
274 seconds.

Problem spotted by Denys Fedoryshchenko

Signed-off-by: Eric Dumazet <dada1@cosmosbay.com>


--------------000902080203060001020400
Content-Type: text/plain;
 name="seq.patch"
Content-Transfer-Encoding: base64
Content-Disposition: inline;
 filename="seq.patch"

LS0tIGxpbnV4LTIuNi4yMi9kcml2ZXJzL2NoYXIvcmFuZG9tLmMJMjAwNy0xMC0wMSAxMDox
ODo0Mi4wMDAwMDAwMDAgKzAyMDAKKysrIGxpbnV4LTIuNi4yMi1lZC9kcml2ZXJzL2NoYXIv
cmFuZG9tLmMJMjAwNy0xMC0wMSAyMTo0Nzo1OC4wMDAwMDAwMDAgKzAyMDAKQEAgLTE1NTAs
MTEgKzE1NTAsMTMgQEAgX191MzIgc2VjdXJlX3RjcF9zZXF1ZW5jZV9udW1iZXIoX19iZTMy
IAogCSAqCUFzIGNsb3NlIGFzIHBvc3NpYmxlIHRvIFJGQyA3OTMsIHdoaWNoCiAJICoJc3Vn
Z2VzdHMgdXNpbmcgYSAyNTAga0h6IGNsb2NrLgogCSAqCUZ1cnRoZXIgcmVhZGluZyBzaG93
cyB0aGlzIGFzc3VtZXMgMiBNYi9zIG5ldHdvcmtzLgotCSAqCUZvciAxMCBHYi9zIEV0aGVy
bmV0LCBhIDEgR0h6IGNsb2NrIGlzIGFwcHJvcHJpYXRlLgotCSAqCVRoYXQncyBmdW5ueSwg
TGludXggaGFzIG9uZSBidWlsdCBpbiEgIFVzZSBpdCEKLQkgKgkoTmV0d29ya3MgYXJlIGZh
c3RlciBub3cgLSBzaG91bGQgdGhpcyBiZSBpbmNyZWFzZWQ/KQorCSAqCUZvciAxMCBNYi9z
IEV0aGVybmV0LCBhIDEgTUh6IGNsb2NrIGlzIGFwcHJvcHJpYXRlLgorCSAqCUZvciAxMCBH
Yi9zIEV0aGVybmV0LCBhIDEgR0h6IGNsb2NrIHNob3VsZCBiZSBvaywgYnV0CisJICoJd2Ug
YWxzbyBuZWVkIHRvIGxpbWl0IHRoZSByZXNvbHV0aW9uIHNvIHRoYXQgdGhlIHUzMiBzZXEK
KwkgKglvdmVybGFwcyBsZXNzIHRoYW4gb25lIHRpbWUgcGVyIE1TTCAoMiBtaW51dGVzKS4K
KwkgKglDaG9vc2luZyBhIGNsb2NrIG9mIDY0IG5zIHBlcmlvZCBpcyBPSy4gKHBlcmlvZCBv
ZiAyNzQgcykKIAkgKi8KLQlzZXEgKz0ga3RpbWVfZ2V0X3JlYWwoKS50djY0OworCXNlcSAr
PSBrdGltZV9nZXRfcmVhbCgpLnR2NjQgPj4gNjsKICNpZiAwCiAJcHJpbnRrKCJpbml0X3Nl
cSglbHgsICVseCwgJWQsICVkKSA9ICVkXG4iLAogCSAgICAgICBzYWRkciwgZGFkZHIsIHNw
b3J0LCBkcG9ydCwgc2VxKTsK
--------------000902080203060001020400--
