From: Tommy Christensen <tommy.christensen@tpack.net>
Subject: Re: Fwd: [2.6] ethertap and af_inet.c assertion failures
Date: Tue, 11 Jan 2005 22:26:14 +0100
Message-ID: <41E44476.20303@tpack.net>
References: <200412240002.13206.simon.roscic@chello.at>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------080702090203030807050209"
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Simon Roscic <simon.roscic@chello.at>
In-Reply-To: <200412240002.13206.simon.roscic@chello.at>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------080702090203030807050209
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit

Simon Roscic wrote:
> hi,
> 
> today i upgraded my kernel from 2.6.9-rc2 to 2.6.10-rc3-bk12, now i get the
> following assertion failures while using the (closed source) phion vpn
> client, the vpn client uses ethertap, there are no closed source kernel
> modules or the like:
> 
> KERNEL: assertion (!atomic_read(&sk->sk_wmem_alloc)) failed at
> net/ipv4/af_inet.c (150)

netlink has messed up the send buffer accounting, when trimming a skb.

Patch below should fix this for ethertap. Could you give it a try?

-Tommy


--------------080702090203030807050209
Content-Type: text/plain;
 name="ethertap.c.patch"
Content-Transfer-Encoding: base64
Content-Disposition: inline;
 filename="ethertap.c.patch"

LS0tIGxpbnV4LTIuNi4xMC1iazE0L2RyaXZlcnMvbmV0L2V0aGVydGFwLmMJMjAwNC0xMi0y
NCAyMjozNDoyNi4wMDAwMDAwMDAgKzAxMDAKKysrIGxpbnV4LTIuNi4xMC13b3JrL2RyaXZl
cnMvbmV0L2V0aGVydGFwLmMJMjAwNS0wMS0xMSAyMjoxODoxOS4xMTMyOTUzMjQgKzAxMDAK
QEAgLTIwNyw4ICsyMDcsOCBAQAogCQkJcmV0dXJuIDA7CiAJCX0KIAkgIAlkZXZfa2ZyZWVf
c2tiKHNrYjIpOwotCX0KLQkvKiAuLi4gYnV0IGRvIG5vdCBvcnBoYW4gaXQgaGVyZSwgbmV0
bGluayBkb2VzIGl0IGluIGFueSBjYXNlLiAqLworCX0gZWxzZQorCQlza2Jfb3JwaGFuKHNr
Yik7CiAKIAlscC0+c3RhdHMudHhfYnl0ZXMrPXNrYi0+bGVuOwogCWxwLT5zdGF0cy50eF9w
YWNrZXRzKys7Cg==
--------------080702090203030807050209--
