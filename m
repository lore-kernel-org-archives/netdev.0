From: Risto Suominen <risto.suominen@gmail.com>
Subject: Fwd: [PATCH 001/002] de2104x: force correct order when writing to rx
	ring
Date: Mon, 9 Feb 2009 09:27:04 +0200
Message-ID: <46e1c7760902082327w38719aa9j97e7158b045bc0f9@mail.gmail.com>
References: <46e1c7760902071330u10427d33p3f49e82a2e4b1ddc@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary=001636c5acd122f3160462774c21
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f161.google.com ([209.85.218.161]:53370 "EHLO
	mail-bw0-f161.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753809AbZBIH1H (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Feb 2009 02:27:07 -0500
Received: by bwz5 with SMTP id 5so913199bwz.13
        for <netdev@vger.kernel.org>; Sun, 08 Feb 2009 23:27:04 -0800 (PST)
In-Reply-To: <46e1c7760902071330u10427d33p3f49e82a2e4b1ddc@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--001636c5acd122f3160462774c21
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit

---------- Forwarded message ----------
From: Risto Suominen <risto.suominen@gmail.com>
Date: 2009/2/7
Subject: [PATCH 001/002] de2104x: force correct order when writing to rx ring
To: Jeff Garzik <jgarzik@pobox.com>, lkml <linux-kernel@vger.kernel.org>


DescOwn should not be set, thus allowing the chip to use the descriptor, before
everything else is set up correctly.

Signed-off-by: Risto Suominen <Risto.Suominen@gmail.com>
---
The testing is done on kernel version 2.6.18.

--- drivers/net/tulip/de2104x.c.org     2006-09-20 06:42:06.000000000 +0300
+++ drivers/net/tulip/de2104x.c 2009-02-07 15:04:04.000000000 +0200
@@ -465,13 +465,14 @@ static void de_rx (struct de_private *de
                       drop = 1;

 rx_next:
-               de->rx_ring[rx_tail].opts1 = cpu_to_le32(DescOwn);
               if (rx_tail == (DE_RX_RING_SIZE - 1))
                       de->rx_ring[rx_tail].opts2 =
                               cpu_to_le32(RingEnd | de->rx_buf_sz);
               else
                       de->rx_ring[rx_tail].opts2 = cpu_to_le32(de->rx_buf_sz);
               de->rx_ring[rx_tail].addr1 = cpu_to_le32(mapping);
+               wmb();
+               de->rx_ring[rx_tail].opts1 = cpu_to_le32(DescOwn);
               rx_tail = NEXT_RX(rx_tail);
       }

--001636c5acd122f3160462774c21
Content-Type: text/x-diff; charset=US-ASCII; name="de2104x-rx.patch"
Content-Disposition: attachment; filename="de2104x-rx.patch"
Content-Transfer-Encoding: base64
X-Attachment-Id: f_fqwsgev20

RGVzY093biBzaG91bGQgbm90IGJlIHNldCwgdGh1cyBhbGxvd2luZyB0aGUgY2hpcCB0byB1c2Ug
dGhlIGRlc2NyaXB0b3IsIGJlZm9yZQpldmVyeXRoaW5nIGVsc2UgaXMgc2V0IHVwIGNvcnJlY3Rs
eS4KClNpZ25lZC1vZmYtYnk6IFJpc3RvIFN1b21pbmVuIDxSaXN0by5TdW9taW5lbkBnbWFpbC5j
b20+Ci0tLQpUaGUgdGVzdGluZyBpcyBkb25lIG9uIGtlcm5lbCB2ZXJzaW9uIDIuNi4xOC4KCi0t
LSBkcml2ZXJzL25ldC90dWxpcC9kZTIxMDR4LmMub3JnCTIwMDYtMDktMjAgMDY6NDI6MDYuMDAw
MDAwMDAwICswMzAwCisrKyBkcml2ZXJzL25ldC90dWxpcC9kZTIxMDR4LmMJMjAwOS0wMi0wNyAx
NTowNDowNC4wMDAwMDAwMDAgKzAyMDAKQEAgLTQ2NSwxMyArNDY1LDE0IEBAIHN0YXRpYyB2b2lk
IGRlX3J4IChzdHJ1Y3QgZGVfcHJpdmF0ZSAqZGUKIAkJCWRyb3AgPSAxOwogCiByeF9uZXh0Ogot
CQlkZS0+cnhfcmluZ1tyeF90YWlsXS5vcHRzMSA9IGNwdV90b19sZTMyKERlc2NPd24pOwogCQlp
ZiAocnhfdGFpbCA9PSAoREVfUlhfUklOR19TSVpFIC0gMSkpCiAJCQlkZS0+cnhfcmluZ1tyeF90
YWlsXS5vcHRzMiA9CiAJCQkJY3B1X3RvX2xlMzIoUmluZ0VuZCB8IGRlLT5yeF9idWZfc3opOwog
CQllbHNlCiAJCQlkZS0+cnhfcmluZ1tyeF90YWlsXS5vcHRzMiA9IGNwdV90b19sZTMyKGRlLT5y
eF9idWZfc3opOwogCQlkZS0+cnhfcmluZ1tyeF90YWlsXS5hZGRyMSA9IGNwdV90b19sZTMyKG1h
cHBpbmcpOworCQl3bWIoKTsKKwkJZGUtPnJ4X3JpbmdbcnhfdGFpbF0ub3B0czEgPSBjcHVfdG9f
bGUzMihEZXNjT3duKTsKIAkJcnhfdGFpbCA9IE5FWFRfUlgocnhfdGFpbCk7CiAJfQogCg==
--001636c5acd122f3160462774c21--
