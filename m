From: Krishna Kumar2 <krkumar2@in.ibm.com>
Subject: Re: [PATCH] Fix panic in virtnet_remove
Date: Sat, 16 Jul 2011 11:02:43 +0530
Message-ID: <OFD93CA49F.2B3E595B-ON652578CF.001E1324-652578CF.001E7034@in.ibm.com>
References: <20110715091650.23026.78221.sendpatchset@krkumar2.in.ibm.com> <20110715.081909.1693878001743345571.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: multipart/mixed;
	Boundary="0__=EABBF25CDF8D95B48f9e8a93df938690918cEABBF25CDF8D95B4"
Cc: netdev@vger.kernel.org, shemminger@vyatta.com, mst@redhat.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e28smtp09.in.ibm.com ([122.248.162.9]:59762 "EHLO
	e28smtp09.in.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750733Ab1GPFcf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 16 Jul 2011 01:32:35 -0400
Received: from d28relay05.in.ibm.com (d28relay05.in.ibm.com [9.184.220.62])
	by e28smtp09.in.ibm.com (8.14.4/8.13.1) with ESMTP id p6G5DCIt029519
	for <netdev@vger.kernel.org>; Sat, 16 Jul 2011 10:43:12 +0530
Received: from d28av01.in.ibm.com (d28av01.in.ibm.com [9.184.220.63])
	by d28relay05.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p6G5WUFG1138720
	for <netdev@vger.kernel.org>; Sat, 16 Jul 2011 11:02:30 +0530
Received: from d28av01.in.ibm.com (loopback [127.0.0.1])
	by d28av01.in.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p6G5WTAB012843
	for <netdev@vger.kernel.org>; Sat, 16 Jul 2011 11:02:30 +0530
In-Reply-To: <20110715.081909.1693878001743345571.davem@davemloft.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--0__=EABBF25CDF8D95B48f9e8a93df938690918cEABBF25CDF8D95B4
Content-type: text/plain; charset=US-ASCII

David Miller <davem@davemloft.net> wrote on 07/15/2011 08:49:09 PM:

> > modprobe -r virtio_net panics in free_netdev() as the
> > dev is already freed in the newly introduced virtnet_free
> > (commit 3fa2a1df9094). Since virtnet_remove doesn't require
> > dev after unregister, I am removing the free_netdev call
> > in virtnet_remove instead of in virtnet_free (which seems
> > to be the right place to free the dev). Confirmed that
> > the panic is fixed with this patch.
> >
> > Signed-off-by: Krishna Kumar <krkumar2@in.ibm.com>
>
> I guess the virtio NET maintainers don't deserve to get CC:'d on a fix
> like this? :-(
>
> Michael Tsirkin is who maintains this driver actively and is the one
> who will merge this kind of fix to me, therefore if you don't CC:
> him it might not get integrated at all.

Sorry, but it was not intentional. I saw that Stephen had
made that change so cc'd him instead.

Michael, I am attaching the patch below, please let me know if
you need it inlined:


(See attached file: patch)

Thanks,

- KK
--0__=EABBF25CDF8D95B48f9e8a93df938690918cEABBF25CDF8D95B4
Content-type: application/octet-stream;
	name="patch"
Content-Disposition: attachment; filename="patch"
Content-transfer-encoding: base64

bW9kcHJvYmUgLXIgdmlydGlvX25ldCBwYW5pY3MgaW4gZnJlZV9uZXRkZXYoKSBhcyB0aGUKZGV2
IGlzIGFscmVhZHkgZnJlZWQgaW4gdGhlIG5ld2x5IGludHJvZHVjZWQgdmlydG5ldF9mcmVlCihj
b21taXQgM2ZhMmExZGY5MDk0KS4gU2luY2UgdmlydG5ldF9yZW1vdmUgZG9lc24ndCByZXF1aXJl
CmRldiBhZnRlciB1bnJlZ2lzdGVyLCBJIGFtIHJlbW92aW5nIHRoZSBmcmVlX25ldGRldiBjYWxs
CmluIHZpcnRuZXRfcmVtb3ZlIGluc3RlYWQgb2YgaW4gdmlydG5ldF9mcmVlICh3aGljaCBzZWVt
cwp0byBiZSB0aGUgcmlnaHQgcGxhY2UgdG8gZnJlZSB0aGUgZGV2KS4gQ29uZmlybWVkIHRoYXQK
dGhlIHBhbmljIGlzIGZpeGVkIHdpdGggdGhpcyBwYXRjaC4KClNpZ25lZC1vZmYtYnk6IEtyaXNo
bmEgS3VtYXIgPGtya3VtYXIyQGluLmlibS5jb20+Ci0tLQogZHJpdmVycy9uZXQvdmlydGlvX25l
dC5jIHwgICAgMiAtLQogMSBmaWxlIGNoYW5nZWQsIDIgZGVsZXRpb25zKC0pCgpkaWZmIC1ydU5w
IG9yZy9kcml2ZXJzL25ldC92aXJ0aW9fbmV0LmMgbmV3L2RyaXZlcnMvbmV0L3ZpcnRpb19uZXQu
YwotLS0gb3JnL2RyaXZlcnMvbmV0L3ZpcnRpb19uZXQuYwkyMDExLTA3LTA0IDEwOjM4OjMzLjAw
MDAwMDAwMCArMDUzMAorKysgbmV3L2RyaXZlcnMvbmV0L3ZpcnRpb19uZXQuYwkyMDExLTA3LTE1
IDE0OjI3OjQ4LjAwMDAwMDAwMCArMDUzMApAQCAtMTEyMSw4ICsxMTIxLDYgQEAgc3RhdGljIHZv
aWQgX19kZXZleGl0IHZpcnRuZXRfcmVtb3ZlKHN0cgogCiAJd2hpbGUgKHZpLT5wYWdlcykKIAkJ
X19mcmVlX3BhZ2VzKGdldF9hX3BhZ2UodmksIEdGUF9LRVJORUwpLCAwKTsKLQotCWZyZWVfbmV0
ZGV2KHZpLT5kZXYpOwogfQogCiBzdGF0aWMgc3RydWN0IHZpcnRpb19kZXZpY2VfaWQgaWRfdGFi
bGVbXSA9IHsK

--0__=EABBF25CDF8D95B48f9e8a93df938690918cEABBF25CDF8D95B4--

