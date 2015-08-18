From: David Ahern <dsa@cumulusnetworks.com>
Subject: Re: [net-next]: unable to add routes to tables
Date: Tue, 18 Aug 2015 11:26:15 -0600
Message-ID: <55D36AB7.3040005@cumulusnetworks.com>
References: <1029376325.2912846.1439917035503.JavaMail.zimbra@tpip.net>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------040206000502020600030202"
To: Andreas Schultz <aschultz@tpip.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f172.google.com ([209.85.223.172]:36464 "EHLO
	mail-io0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751801AbbHRR0V (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 Aug 2015 13:26:21 -0400
Received: by iodv127 with SMTP id v127so181783535iod.3
        for <netdev@vger.kernel.org>; Tue, 18 Aug 2015 10:26:20 -0700 (PDT)
In-Reply-To: <1029376325.2912846.1439917035503.JavaMail.zimbra@tpip.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------040206000502020600030202
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit

On 8/18/15 10:57 AM, Andreas Schultz wrote:
> Hi,
>
> It seems that the policy for adding routes to tables has changed between
> Linux 4.2-rc6 and net-next.
>
> In Linux main line (tested up to 4.2-rc6), with this main routing table:
> # ip route show table main
> ...
> 172.28.0.0/24 dev vnf-xe1p0  proto kernel  scope link  src 172.28.0.16
>
> and an empty table 100, this works:
>
> # ip route add 10.0.0.0/8 via 172.28.0.32 table 100 dev vnf-xe1p0
>
> With net-next at commit d52736e24fe2e927c26817256f8d1a3c8b5d51a0, the
> same command leads to an:
>
> # ip route add 10.0.0.0/8 via 172.28.0.32 table 100 dev vnf-xe1p0
> RTNETLINK answers: Resource temporarily unavailable
>
> Is this expected behavior?
>

The attached works for me and so does my original problem. Can you 
confirm it resolves your problem? If so I'll send a formal patch.

David



--------------040206000502020600030202
Content-Type: text/plain; charset=UTF-8; x-mac-type="0"; x-mac-creator="0";
 name="fix-nexthop-lookup.path"
Content-Transfer-Encoding: base64
Content-Disposition: attachment;
 filename="fix-nexthop-lookup.path"

ZGlmZiAtLWdpdCBhL25ldC9pcHY0L2ZpYl9zZW1hbnRpY3MuYyBiL25ldC9pcHY0L2ZpYl9z
ZW1hbnRpY3MuYwppbmRleCBjODAyNTg1MWRhYzcuLjAxYTIzNzI3OGRkMiAxMDA2NDQKLS0t
IGEvbmV0L2lwdjQvZmliX3NlbWFudGljcy5jCisrKyBiL25ldC9pcHY0L2ZpYl9zZW1hbnRp
Y3MuYwpAQCAtNzEwLDkgKzcxMCwxNiBAQCBzdGF0aWMgaW50IGZpYl9jaGVja19uaChzdHJ1
Y3QgZmliX2NvbmZpZyAqY2ZnLCBzdHJ1Y3QgZmliX2luZm8gKmZpLAogCQkJCWVyciA9IGZp
Yl90YWJsZV9sb29rdXAodGJsLCAmZmw0LCAmcmVzLAogCQkJCQkJICAgICAgIEZJQl9MT09L
VVBfSUdOT1JFX0xJTktTVEFURSB8CiAJCQkJCQkgICAgICAgRklCX0xPT0tVUF9OT1JFRik7
Ci0JCQllbHNlCisKKwkJCS8qIG9uIGVycm9yIG9yIGlmIG5vIHRhYmxlIGdpdmVuIGRvIGZ1
bGwgbG9va3VwLiBUaGlzIGlzCisJCQkgKiBuZWVkZWQgZm9yIGV4YW1wbGUgd2hlbiBuZXh0
aG9wcyBhcmUgaW4gdGhlIGxvY2FsIHRhYmxlCisJCQkgKiByYXRoZXIgdGhhbiB0aGUgZ2l2
ZW4gdGFibGUKKwkJCSAqLworCQkJaWYgKCF0YmwgfHwgZXJyKSB7CiAJCQkJZXJyID0gZmli
X2xvb2t1cChuZXQsICZmbDQsICZyZXMsCiAJCQkJCQkgRklCX0xPT0tVUF9JR05PUkVfTElO
S1NUQVRFKTsKKwkJCX0KKwogCQkJaWYgKGVycikgewogCQkJCXJjdV9yZWFkX3VubG9jaygp
OwogCQkJCXJldHVybiBlcnI7Cg==
--------------040206000502020600030202--
