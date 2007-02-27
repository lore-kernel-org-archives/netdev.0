From: David Stevens <dlstevens@us.ibm.com>
Subject: [PATCH] /proc/net/anycast6 unbalanced inet6_dev refcnt
Date: Mon, 26 Feb 2007 17:22:10 -0700
Message-ID: <OF11F5BC96.16E9F85A-ON8825728F.00018101-8825728F.00020608@us.ibm.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="=_mixed 000206028825728F_="
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from e34.co.us.ibm.com ([32.97.110.152]:41574 "EHLO
	e34.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751461AbXB0AWN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Feb 2007 19:22:13 -0500
Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e34.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id l1R0MCiT010548
	for <netdev@vger.kernel.org>; Mon, 26 Feb 2007 19:22:12 -0500
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by d03relay04.boulder.ibm.com (8.13.8/8.13.8/NCO v8.2) with ESMTP id l1R0MCrj537688
	for <netdev@vger.kernel.org>; Mon, 26 Feb 2007 17:22:12 -0700
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l1R0MBwi027913
	for <netdev@vger.kernel.org>; Mon, 26 Feb 2007 17:22:12 -0700
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--=_mixed 000206028825728F_=
Content-Type: text/plain; charset="US-ASCII"

Reading /proc/net/anycast6 when there is no anycast address
on an interface results in an ever-increasing inet6_dev reference
count, as well as a reference to the netdevice you can't get rid of.

Patch below & attached.

                                                +-DLS

Signed-off-by: David L Stevens <dlstevens@us.ibm.com>
--- linux-2.6.20.1/net/ipv6/anycast.c   2007-02-19 22:34:32.000000000 
-0800
+++ linux-2.6.20.1T1/net/ipv6/anycast.c 2007-02-26 15:37:04.000000000 
-0800
@@ -462,6 +462,7 @@ static inline struct ifacaddr6 *ac6_get_
                        break;
                }
                read_unlock_bh(&idev->lock);
+               in6_dev_put(idev);
        }
        return im;
 }


--=_mixed 000206028825728F_=
Content-Type: application/octet-stream; name="ac6.patch"
Content-Disposition: attachment; filename="ac6.patch"
Content-Transfer-Encoding: base64

LS0tIGxpbnV4LTIuNi4yMC4xL25ldC9pcHY2L2FueWNhc3QuYwkyMDA3LTAyLTE5IDIyOjM0OjMy
LjAwMDAwMDAwMCAtMDgwMAorKysgbGludXgtMi42LjIwLjFUMS9uZXQvaXB2Ni9hbnljYXN0LmMJ
MjAwNy0wMi0yNiAxNTozNzowNC4wMDAwMDAwMDAgLTA4MDAKQEAgLTQ2Miw2ICs0NjIsNyBAQCBz
dGF0aWMgaW5saW5lIHN0cnVjdCBpZmFjYWRkcjYgKmFjNl9nZXRfCiAJCQlicmVhazsKIAkJfQog
CQlyZWFkX3VubG9ja19iaCgmaWRldi0+bG9jayk7CisJCWluNl9kZXZfcHV0KGlkZXYpOwogCX0K
IAlyZXR1cm4gaW07CiB9Cg==

--=_mixed 000206028825728F_=--
