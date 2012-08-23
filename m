From: Rami Rosen <rosenr@marvell.com>
Subject: [PATCH net-next] packet: fix broken build.
Date: Thu, 23 Aug 2012 15:55:41 +0300
Message-ID: <309002C0DA137042828828FC53D7A934012B21B8CCCE@IL-MB01.marvell.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
	boundary="_002_309002C0DA137042828828FC53D7A934012B21B8CCCEILMB01marve_"
Cc: "xemul@parallels.com" <xemul@parallels.com>,
	"edumazet@google.com" <edumazet@google.com>
To: "davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from galiil.marvell.com ([199.203.130.254]:6907 "EHLO
	galiil.marvell.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932993Ab2HWNBG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Aug 2012 09:01:06 -0400
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--_002_309002C0DA137042828828FC53D7A934012B21B8CCCEILMB01marve_
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable

This patch fixes a broken build due to a missing header:=20
...
  CC      net/ipv4/proc.o
In file included from include/net/net_namespace.h:15,
                 from net/ipv4/proc.c:35:
include/net/netns/packet.h:11: error: field 'sklist_lock' has incomplete ty=
pe
...

The lock of netns_packet has been replaced by a recent patch to be a mutex =
instead of a spinlock,=20
but we need to replace the header file to be linux/mutex.h instead of linux=
/spinlock.h as well.

See commit 0fa7fa98dbcc2789409ed24e885485e645803d7f:
packet: Protect packet sk list with mutex (v2) patch,=20

Signed-off-by: Rami Rosen <rosenr@marvell.com>=

--_002_309002C0DA137042828828FC53D7A934012B21B8CCCEILMB01marve_
Content-Type: text/plain; name="patch.txt"
Content-Description: patch.txt
Content-Disposition: attachment; filename="patch.txt"; size=348;
	creation-date="Thu, 23 Aug 2012 12:45:24 GMT";
	modification-date="Thu, 23 Aug 2012 12:45:24 GMT"
Content-Transfer-Encoding: base64

ZGlmZiAtLWdpdCBhL2luY2x1ZGUvbmV0L25ldG5zL3BhY2tldC5oIGIvaW5jbHVkZS9uZXQvbmV0
bnMvcGFja2V0LmgKaW5kZXggNDc4MGIwOC4uMTdlYzJiOSAxMDA2NDQKLS0tIGEvaW5jbHVkZS9u
ZXQvbmV0bnMvcGFja2V0LmgKKysrIGIvaW5jbHVkZS9uZXQvbmV0bnMvcGFja2V0LmgKQEAgLTUs
NyArNSw3IEBACiAjZGVmaW5lIF9fTkVUTlNfUEFDS0VUX0hfXwogCiAjaW5jbHVkZSA8bGludXgv
cmN1bGlzdC5oPgotI2luY2x1ZGUgPGxpbnV4L3NwaW5sb2NrLmg+CisjaW5jbHVkZSA8bGludXgv
bXV0ZXguaD4KIAogc3RydWN0IG5ldG5zX3BhY2tldCB7CiAJc3RydWN0IG11dGV4CQlza2xpc3Rf
bG9jazsK

--_002_309002C0DA137042828828FC53D7A934012B21B8CCCEILMB01marve_--
