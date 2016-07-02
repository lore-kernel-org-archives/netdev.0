From: Patrick McLean <patrickm@gaikai.com>
Subject: [PATCH] (resend) ixgbe: always initialize setup_fc
Date: Fri, 1 Jul 2016 18:35:59 -0700
Message-ID: <CAE2NFgXe4uPT1WDVzSq_rr54XA7xDNuedoBgHdtd2_WekNQZ+A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary=001a1143e1981c884005369d2030
Cc: intel-wired-lan@lists.osuosl.org, netdev@vger.kernel.org
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f49.google.com ([209.85.214.49]:36829 "EHLO
	mail-it0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752014AbcGBBhd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 Jul 2016 21:37:33 -0400
Received: by mail-it0-f49.google.com with SMTP id a5so31334700ita.1
        for <netdev@vger.kernel.org>; Fri, 01 Jul 2016 18:36:00 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--001a1143e1981c884005369d2030
Content-Type: text/plain; charset=UTF-8

Gmail mangled my first message, sorry about that. Second attempt.

In ixgbe_init_mac_link_ops_X550em, the code has a special case for
backplane media type, but does not fall through to the default case,
so the setup_fc never gets initialized. This causes a panic when it
later tries to set up the card, and the kernel dereferences the null
pointer.

This patch lets the the function fall through, which initialized
setup_fc properly.

--001a1143e1981c884005369d2030
Content-Type: text/x-patch; charset=US-ASCII;
	name="ixgbe-x550-always-initialize-setup_fc.patch"
Content-Disposition: attachment;
	filename="ixgbe-x550-always-initialize-setup_fc.patch"
Content-Transfer-Encoding: base64
X-Attachment-Id: f_iq4hz7bo0

ZGlmZiAtLWdpdCBhL2RyaXZlcnMvbmV0L2V0aGVybmV0L2ludGVsL2l4Z2JlL2l4Z2JlX3g1NTAu
YyBiL2RyaXZlcnMvbmV0L2V0aGVybmV0L2ludGVsL2l4Z2JlL2l4Z2JlX3g1NTAuYwppbmRleCAx
OWI3NWNkLi43M2UyZGU3IDEwMDY0NAotLS0gYS9kcml2ZXJzL25ldC9ldGhlcm5ldC9pbnRlbC9p
eGdiZS9peGdiZV94NTUwLmMKKysrIGIvZHJpdmVycy9uZXQvZXRoZXJuZXQvaW50ZWwvaXhnYmUv
aXhnYmVfeDU1MC5jCkBAIC0xNjUzLDcgKzE2NTMsNiBAQCBzdGF0aWMgdm9pZCBpeGdiZV9pbml0
X21hY19saW5rX29wc19YNTUwZW0oc3RydWN0IGl4Z2JlX2h3ICpodykKIAkJaWYgKGh3LT5kZXZp
Y2VfaWQgPT0gSVhHQkVfREVWX0lEX1g1NTBFTV9BX1NHTUlJIHx8CiAJCSAgICBody0+ZGV2aWNl
X2lkID09IElYR0JFX0RFVl9JRF9YNTUwRU1fQV9TR01JSV9MKQogCQkJbWFjLT5vcHMuc2V0dXBf
bGluayA9IGl4Z2JlX3NldHVwX3NnbWlpOwotCQlicmVhazsKIAlkZWZhdWx0OgogCQltYWMtPm9w
cy5zZXR1cF9mYyA9IGl4Z2JlX3NldHVwX2ZjX3g1NTBlbTsKIAkJYnJlYWs7Cg==
--001a1143e1981c884005369d2030--
