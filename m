From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: [2.6.31-rc5] BUG kmalloc-2048: Poison overwritten
Date: Wed,  5 Aug 2009 11:13:36 +0900 (JST)
Message-ID: <20090805110924.5B99.A69D9226__7954.78349687091$1249438456$gmane$org@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: kosaki.motohiro@jp.fujitsu.com
To: LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>,
	Pekka Enberg <penberg@cs.helsinki.fi>,
	Christoph Lameter <cl@linux-foundation.org>,
	netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fgwmail6.fujitsu.co.jp ([192.51.44.36]:47599 "EHLO
	fgwmail6.fujitsu.co.jp" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933245AbZHECNn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Aug 2009 22:13:43 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Today, 2.6.31-rc5 crashed with following error.
Is this known problem? I didn't reproduce this problem again.




=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D
BUG kmalloc-2048: Poison overwritten
-----------------------------------------------------------------------=
------

INFO: 0xe00000000fd4086a-0xe00000000fd408b5. First byte 0x28 instead of=
 0x6b
INFO: Allocated in __netdev_alloc_skb+0x50/0xc0 age=3D35574 cpu=3D0 pid=
=3D0
INFO: Freed in skb_release_data+0x1b0/0x1e0 age=3D0 cpu=3D0 pid=3D0
INFO: Slab 0xa04000000003f500 objects=3D30 used=3D14 fp=3D0xe00000000fd=
40848 flags=3D0x00c3
INFO: Object 0xe00000000fd40848 @offset=3D2120 fp=3D0xe00000000fd41090

Bytes b4 0xe00000000fd40838:  2c db da 00 01 00 00 00 5a 5a 5a 5a 5a 5a=
 5a 5a ,=DB=DA.....ZZZZZZZZ
  Object 0xe00000000fd40848:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b=
 6b 6b kkkkkkkkkkkkkkkk
  Object 0xe00000000fd40858:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b=
 6b 6b kkkkkkkkkkkkkkkk
  Object 0xe00000000fd40868:  6b 6b 28 a0 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b=
 3c c0 kk(.kkkkkkkkkk<=C0
  Object 0xe00000000fd40878:  6b 6b 00 0b 5d 6e 40 10 00 22 0c 34 72 44=
 08 00 kk..]n@..".4rD..
  Object 0xe00000000fd40888:  45 00 00 28 b1 36 40 00 7e 06 bb c1 0a 7c=
 64 b3 E..(=B16@.~.=BB=C1.|d=B3
  Object 0xe00000000fd40898:  0a 7c 16 2d 05 15 00 16 0c 26 35 4b a9 f3=
 b6 6e .|.-.....&5K=A9=F3=B6n
  Object 0xe00000000fd408a8:  50 10 ff ff 78 fe 00 00 00 00 00 00 00 00=
 6b 6b P.=FF=FFx=FE........kk
  Object 0xe00000000fd408b8:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b=
 6b 6b kkkkkkkkkkkkkkkk
  Object 0xe00000000fd408c8:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b=
 6b 6b kkkkkkkkkkkkkkkk
  Object 0xe00000000fd408d8:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b=
 6b 6b kkkkkkkkkkkkkkkk
  Object 0xe00000000fd408e8:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b=
 6b 6b kkkkkkkkkkkkkkkk
  Object 0xe00000000fd408f8:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b=
 6b 6b kkkkkkkkkkkkkkkk
  Object 0xe00000000fd40908:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b=
 6b 6b kkkkkkkkkkkkkkkk
  Object 0xe00000000fd40918:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b=
 6b 6b kkkkkkkkkkkkkkkk
  Object 0xe00000000fd40928:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b=
 6b 6b kkkkkkkkkkkkkkkk
  Object 0xe00000000fd40938:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b=
 6b 6b kkkkkkkkkkkkkkkk
  Object 0xe00000000fd40948:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b=
 6b 6b kkkkkkkkkkkkkkkk
  Object 0xe00000000fd40958:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b=
 6b 6b kkkkkkkkkkkkkkkk
  Object 0xe00000000fd40968:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b=
 6b 6b kkkkkkkkkkkkkkkk
  Object 0xe00000000fd40978:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b=
 6b 6b kkkkkkkkkkkkkkkk
  Object 0xe00000000fd40988:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b=
 6b 6b kkkkkkkkkkkkkkkk
  Object 0xe00000000fd40998:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b=
 6b 6b kkkkkkkkkkkkkkkk
  Object 0xe00000000fd409a8:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b=
 6b 6b kkkkkkkkkkkkkkkk
  Object 0xe00000000fd409b8:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b=
 6b 6b kkkkkkkkkkkkkkkk
  Object 0xe00000000fd409c8:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b=
 6b 6b kkkkkkkkkkkkkkkk
  Object 0xe00000000fd409d8:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b=
 6b 6b kkkkkkkkkkkkkkkk
  Object 0xe00000000fd409e8:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b=
 6b 6b kkkkkkkkkkkkkkkk
  Object 0xe00000000fd409f8:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b=
 6b 6b kkkkkkkkkkkkkkkk
  Object 0xe00000000fd40a08:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b=
 6b 6b kkkkkkkkkkkkkkkk
  Object 0xe00000000fd40a18:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b=
 6b 6b kkkkkkkkkkkkkkkk
  Object 0xe00000000fd40a28:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b=
 6b 6b kkkkkkkkkkkkkkkk
  Object 0xe00000000fd40a38:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b=
 6b 6b kkkkkkkkkkkkkkkk
  Object 0xe00000000fd40a48:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b=
 6b 6b kkkkkkkkkkkkkkkk
  Object 0xe00000000fd40a58:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b=
 6b 6b kkkkkkkkkkkkkkkk
  Object 0xe00000000fd40a68:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b=
 6b 6b kkkkkkkkkkkkkkkk
  Object 0xe00000000fd40a78:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b=
 6b 6b kkkkkkkkkkkkkkkk
  Object 0xe00000000fd40a88:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b=
 6b 6b kkkkkkkkkkkkkkkk
  Object 0xe00000000fd40a98:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b=
 6b 6b kkkkkkkkkkkkkkkk
  Object 0xe00000000fd40aa8:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b=
 6b 6b kkkkkkkkkkkkkkkk
  Object 0xe00000000fd40ab8:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b=
 6b 6b kkkkkkkkkkkkkkkk
  Object 0xe00000000fd40ac8:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b=
 6b 6b kkkkkkkkkkkkkkkk
  Object 0xe00000000fd40ad8:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b=
 6b 6b kkkkkkkkkkkkkkkk
  Object 0xe00000000fd40ae8:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b=
 6b 6b kkkkkkkkkkkkkkkk
  Object 0xe00000000fd40af8:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b=
 6b 6b kkkkkkkkkkkkkkkk
  Object 0xe00000000fd40b08:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b=
 6b 6b kkkkkkkkkkkkkkkk
  Object 0xe00000000fd40b18:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b=
 6b 6b kkkkkkkkkkkkkkkk
  Object 0xe00000000fd40b28:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b=
 6b 6b kkkkkkkkkkkkkkkk
  Object 0xe00000000fd40b38:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b=
 6b 6b kkkkkkkkkkkkkkkk
  Object 0xe00000000fd40b48:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b=
 6b 6b kkkkkkkkkkkkkkkk
  Object 0xe00000000fd40b58:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b=
 6b 6b kkkkkkkkkkkkkkkk
  Object 0xe00000000fd40b68:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b=
 6b 6b kkkkkkkkkkkkkkkk
  Object 0xe00000000fd40b78:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b=
 6b 6b kkkkkkkkkkkkkkkk
  Object 0xe00000000fd40b88:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b=
 6b 6b kkkkkkkkkkkkkkkk
  Object 0xe00000000fd40b98:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b=
 6b 6b kkkkkkkkkkkkkkkk
  Object 0xe00000000fd40ba8:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b=
 6b 6b kkkkkkkkkkkkkkkk
  Object 0xe00000000fd40bb8:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b=
 6b 6b kkkkkkkkkkkkkkkk
  Object 0xe00000000fd40bc8:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b=
 6b 6b kkkkkkkkkkkkkkkk
  Object 0xe00000000fd40bd8:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b=
 6b 6b kkkkkkkkkkkkkkkk
  Object 0xe00000000fd40be8:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b=
 6b 6b kkkkkkkkkkkkkkkk
  Object 0xe00000000fd40bf8:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b=
 6b 6b kkkkkkkkkkkkkkkk
  Object 0xe00000000fd40c08:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b=
 6b 6b kkkkkkkkkkkkkkkk
  Object 0xe00000000fd40c18:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b=
 6b 6b kkkkkkkkkkkkkkkk
  Object 0xe00000000fd40c28:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b=
 6b 6b kkkkkkkkkkkkkkkk
  Object 0xe00000000fd40c38:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b=
 6b 6b kkkkkkkkkkkkkkkk
  Object 0xe00000000fd40c48:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b=
 6b 6b kkkkkkkkkkkkkkkk
  Object 0xe00000000fd40c58:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b=
 6b 6b kkkkkkkkkkkkkkkk
  Object 0xe00000000fd40c68:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b=
 6b 6b kkkkkkkkkkkkkkkk
  Object 0xe00000000fd40c78:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b=
 6b 6b kkkkkkkkkkkkkkkk
  Object 0xe00000000fd40c88:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b=
 6b 6b kkkkkkkkkkkkkkkk
  Object 0xe00000000fd40c98:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b=
 6b 6b kkkkkkkkkkkkkkkk
  Object 0xe00000000fd40ca8:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b=
 6b 6b kkkkkkkkkkkkkkkk
  Object 0xe00000000fd40cb8:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b=
 6b 6b kkkkkkkkkkkkkkkk
  Object 0xe00000000fd40cc8:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b=
 6b 6b kkkkkkkkkkkkkkkk
  Object 0xe00000000fd40cd8:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b=
 6b 6b kkkkkkkkkkkkkkkk
  Object 0xe00000000fd40ce8:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b=
 6b 6b kkkkkkkkkkkkkkkk
  Object 0xe00000000fd40cf8:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b=
 6b 6b kkkkkkkkkkkkkkkk
  Object 0xe00000000fd40d08:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b=
 6b 6b kkkkkkkkkkkkkkkk
  Object 0xe00000000fd40d18:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b=
 6b 6b kkkkkkkkkkkkkkkk
  Object 0xe00000000fd40d28:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b=
 6b 6b kkkkkkkkkkkkkkkk
  Object 0xe00000000fd40d38:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b=
 6b 6b kkkkkkkkkkkkkkkk
  Object 0xe00000000fd40d48:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b=
 6b 6b kkkkkkkkkkkkkkkk
  Object 0xe00000000fd40d58:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b=
 6b 6b kkkkkkkkkkkkkkkk
  Object 0xe00000000fd40d68:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b=
 6b 6b kkkkkkkkkkkkkkkk
  Object 0xe00000000fd40d78:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b=
 6b 6b kkkkkkkkkkkkkkkk
  Object 0xe00000000fd40d88:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b=
 6b 6b kkkkkkkkkkkkkkkk
  Object 0xe00000000fd40d98:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b=
 6b 6b kkkkkkkkkkkkkkkk
  Object 0xe00000000fd40da8:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b=
 6b 6b kkkkkkkkkkkkkkkk
  Object 0xe00000000fd40db8:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b=
 6b 6b kkkkkkkkkkkkkkkk
  Object 0xe00000000fd40dc8:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b=
 6b 6b kkkkkkkkkkkkkkkk
  Object 0xe00000000fd40dd8:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b=
 6b 6b kkkkkkkkkkkkkkkk
  Object 0xe00000000fd40de8:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b=
 6b 6b kkkkkkkkkkkkkkkk
  Object 0xe00000000fd40df8:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b=
 6b 6b kkkkkkkkkkkkkkkk
  Object 0xe00000000fd40e08:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b=
 6b 6b kkkkkkkkkkkkkkkk
  Object 0xe00000000fd40e18:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b=
 6b 6b kkkkkkkkkkkkkkkk
  Object 0xe00000000fd40e28:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b=
 6b 6b kkkkkkkkkkkkkkkk
  Object 0xe00000000fd40e38:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b=
 6b 6b kkkkkkkkkkkkkkkk
  Object 0xe00000000fd40e48:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b=
 6b 6b kkkkkkkkkkkkkkkk
  Object 0xe00000000fd40e58:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b=
 6b 6b kkkkkkkkkkkkkkkk
  Object 0xe00000000fd40e68:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b=
 6b 6b kkkkkkkkkkkkkkkk
  Object 0xe00000000fd40e78:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b=
 6b 6b kkkkkkkkkkkkkkkk
  Object 0xe00000000fd40e88:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b=
 6b 6b kkkkkkkkkkkkkkkk
  Object 0xe00000000fd40e98:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b=
 6b 6b kkkkkkkkkkkkkkkk
  Object 0xe00000000fd40ea8:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b=
 6b 6b kkkkkkkkkkkkkkkk
  Object 0xe00000000fd40eb8:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b=
 6b 6b kkkkkkkkkkkkkkkk
  Object 0xe00000000fd40ec8:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b=
 6b 6b kkkkkkkkkkkkkkkk
  Object 0xe00000000fd40ed8:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b=
 6b 6b kkkkkkkkkkkkkkkk
  Object 0xe00000000fd40ee8:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b=
 6b 6b kkkkkkkkkkkkkkkk
  Object 0xe00000000fd40ef8:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b=
 6b 6b kkkkkkkkkkkkkkkk
  Object 0xe00000000fd40f08:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b=
 6b 6b kkkkkkkkkkkkkkkk
  Object 0xe00000000fd40f18:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b=
 6b 6b kkkkkkkkkkkkkkkk
  Object 0xe00000000fd40f28:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b=
 6b 6b kkkkkkkkkkkkkkkk
  Object 0xe00000000fd40f38:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b=
 6b 6b kkkkkkkkkkkkkkkk
  Object 0xe00000000fd40f48:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b=
 6b 6b kkkkkkkkkkkkkkkk
  Object 0xe00000000fd40f58:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b=
 6b 6b kkkkkkkkkkkkkkkk
  Object 0xe00000000fd40f68:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b=
 6b 6b kkkkkkkkkkkkkkkk
  Object 0xe00000000fd40f78:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b=
 6b 6b kkkkkkkkkkkkkkkk
  Object 0xe00000000fd40f88:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b=
 6b 6b kkkkkkkkkkkkkkkk
  Object 0xe00000000fd40f98:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b=
 6b 6b kkkkkkkkkkkkkkkk
  Object 0xe00000000fd40fa8:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b=
 6b 6b kkkkkkkkkkkkkkkk
  Object 0xe00000000fd40fb8:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b=
 6b 6b kkkkkkkkkkkkkkkk
  Object 0xe00000000fd40fc8:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b=
 6b 6b kkkkkkkkkkkkkkkk
  Object 0xe00000000fd40fd8:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b=
 6b 6b kkkkkkkkkkkkkkkk
  Object 0xe00000000fd40fe8:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b=
 6b 6b kkkkkkkkkkkkkkkk
  Object 0xe00000000fd40ff8:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b=
 6b 6b kkkkkkkkkkkkkkkk
  Object 0xe00000000fd41008:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b=
 6b 6b kkkkkkkkkkkkkkkk
  Object 0xe00000000fd41018:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b=
 6b 6b kkkkkkkkkkkkkkkk
  Object 0xe00000000fd41028:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b=
 6b 6b kkkkkkkkkkkkkkkk
  Object 0xe00000000fd41038:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b=
 6b a5 kkkkkkkkkkkkkkk=A5
 Redzone 0xe00000000fd41048:  bb bb bb bb bb bb bb bb                  =
       =BB=BB=BB=BB=BB=BB=BB=BB   =20
 Padding 0xe00000000fd41088:  5a 5a 5a 5a 5a 5a 5a 5a                  =
       ZZZZZZZZ   =20

Call Trace:
 [<a000000100019be0>] show_stack+0x80/0xa0
                                sp=3Da000000100cff9d0 bsp=3Da000000100c=
f1700
 [<a000000100019c30>] dump_stack+0x30/0x60
                                sp=3Da000000100cffba0 bsp=3Da000000100c=
f16e8
 [<a00000010022d7a0>] print_trailer+0x2a0/0x2c0
                                sp=3Da000000100cffba0 bsp=3Da000000100c=
f16a8
 [<a00000010022e450>] check_bytes_and_report+0x150/0x1e0
                                sp=3Da000000100cffba0 bsp=3Da000000100c=
f1640
 [<a00000010022e7d0>] check_object+0x2f0/0x540
                                sp=3Da000000100cffba0 bsp=3Da000000100c=
f15e8
 [<a000000100236370>] __slab_alloc+0xc30/0xea0
                                sp=3Da000000100cffba0 bsp=3Da000000100c=
f1570
 [<a0000001002387d0>] __kmalloc_node_track_caller+0x510/0x760
                                sp=3Da000000100cffbb0 bsp=3Da000000100c=
f1510
 [<a00000010075bfd0>] __alloc_skb+0xb0/0x2c0
                                sp=3Da000000100cffbb0 bsp=3Da000000100c=
f14c8
 [<a00000010075ca50>] __netdev_alloc_skb+0x50/0xc0
                                sp=3Da000000100cffbb0 bsp=3Da000000100c=
f1498
 [<a00000010063d040>] e100_rx_alloc_skb+0x40/0x440
                                sp=3Da000000100cffbb0 bsp=3Da000000100c=
f1440
 [<a000000100641c70>] e100_poll+0x4d0/0xe20
                                sp=3Da000000100cffbb0 bsp=3Da000000100c=
f1350
 [<a00000010077ca30>] net_rx_action+0x410/0x8a0
                                sp=3Da000000100cffbb0 bsp=3Da000000100c=
f12b8
 [<a0000001000fde10>] __do_softirq+0x3b0/0x8c0
                                sp=3Da000000100cffbb0 bsp=3Da000000100c=
f11d8
 [<a0000001000fe480>] do_softirq+0x160/0x1e0
                                sp=3Da000000100cffbb0 bsp=3Da000000100c=
f1178
 [<a0000001000fe6a0>] irq_exit+0x1a0/0x1c0
                                sp=3Da000000100cffbb0 bsp=3Da000000100c=
f1160
 [<a000000100015660>] ia64_handle_irq+0x420/0x900
                                sp=3Da000000100cffbb0 bsp=3Da000000100c=
f10f8
 [<a00000010008dea0>] paravirt_leave_kernel+0x0/0x40
                                sp=3Da000000100cffbb0 bsp=3Da000000100c=
f10f8
 [<a00000010001b160>] default_idle+0x380/0x3c0
                                sp=3Da000000100cffd80 bsp=3Da000000100c=
f1090
 [<a000000100019700>] cpu_idle+0x2e0/0x600
                                sp=3Da000000100cffe20 bsp=3Da000000100c=
f1030
 [<a00000010088c360>] rest_init+0x140/0x160
                                sp=3Da000000100cffe20 bsp=3Da000000100c=
f1018
 [<a000000100b01ab0>] start_kernel+0x8f0/0xa00
                                sp=3Da000000100cffe20 bsp=3Da000000100c=
f0f98
 [<a0000001008dc110>] _start+0x7d0/0x7f0
                                sp=3Da000000100cffe30 bsp=3Da000000100c=
f0f00
=46IX kmalloc-2048: Restoring 0xe00000000fd4086a-0xe00000000fd408b5=3D0=
x6b

=46IX kmalloc-2048: Marking all objects used
aa=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D
BUG kmalloc-2048: Poison overwritten
-----------------------------------------------------------------------=
------

INFO: 0xe00000000fd4be9a-0xe00000000fd4bf33. First byte 0x2a instead of=
 0x6b
INFO: Allocated in __netdev_alloc_skb+0x50/0xc0 age=3D62772 cpu=3D0 pid=
=3D0
INFO: Freed in skb_release_data+0x1b0/0x1e0 age=3D26989 cpu=3D0 pid=3D4=
192
INFO: Slab 0xa04000000003f500 objects=3D30 used=3D29 fp=3D0xe00000000fd=
4be78 flags=3D0x00c3
INFO: Object 0xe00000000fd4be78 @offset=3D48760 fp=3D0x(null)

Bytes b4 0xe00000000fd4be68:  f6 62 db 00 01 00 00 00 5a 5a 5a 5a 5a 5a=
 5a 5a =F6b=DB.....ZZZZZZZZ
  Object 0xe00000000fd4be78:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b=
 6b 6b kkkkkkkkkkkkkkkk
  Object 0xe00000000fd4be88:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b=
 6b 6b kkkkkkkkkkkkkkkk
  Object 0xe00000000fd4be98:  6b 6b 2a a0 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b=
 89 c0 kk*.kkkkkkkkkk.=C0
  Object 0xe00000000fd4bea8:  6b 6b 01 00 5e 00 00 fb 00 0b 5d 6e 44 9b=
 08 00 kk..^..=81E.]nD...
  Object 0xe00000000fd4beb8:  45 00 00 7c 00 00 40 00 ff 11 79 83 0a 7c=
 16 76 E..|..@.=FF.y..|.v
  Object 0xe00000000fd4bec8:  e0 00 00 fb 14 e9 14 e9 00 68 bd ef 00 00=
 84 00 =81E.=81E=81E=81Eh=BD=81E...
  Object 0xe00000000fd4bed8:  00 00 00 02 00 00 00 00 09 5f 73 65 72 76=
 69 63 ........._servic
  Object 0xe00000000fd4bee8:  65 73 07 5f 64 6e 73 2d 73 64 04 5f 75 64=
 70 05 es._dns-sd._udp.
  Object 0xe00000000fd4bef8:  6c 6f 63 61 6c 00 00 0c 00 01 00 00 11 94=
 00 14 local...........
  Object 0xe00000000fd4bf08:  0c 5f 77 6f 72 6b 73 74 61 74 69 6f 6e 04=
 5f 74 ._workstation._t
  Object 0xe00000000fd4bf18:  63 70 c0 23 c0 0c 00 0c 00 01 00 00 11 94=
 00 0c cp=C0#=C0...........
  Object 0xe00000000fd4bf28:  09 5f 73 66 74 70 2d 73 73 68 c0 41 6b 6b=
 6b 6b ._sftp-ssh=C0Akkkk
  Object 0xe00000000fd4bf38:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b=
 6b 6b kkkkkkkkkkkkkkkk
  Object 0xe00000000fd4bf48:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b=
 6b 6b kkkkkkkkkkkkkkkk
  Object 0xe00000000fd4bf58:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b=
 6b 6b kkkkkkkkkkkkkkkk
  Object 0xe00000000fd4bf68:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b=
 6b 6b kkkkkkkkkkkkkkkk
  Object 0xe00000000fd4bf78:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b=
 6b 6b kkkkkkkkkkkkkkkk
  Object 0xe00000000fd4bf88:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b=
 6b 6b kkkkkkkkkkkkkkkk
  Object 0xe00000000fd4bf98:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b=
 6b 6b kkkkkkkkkkkkkkkk
  Object 0xe00000000fd4bfa8:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b=
 6b 6b kkkkkkkkkkkkkkkk
  Object 0xe00000000fd4bfb8:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b=
 6b 6b kkkkkkkkkkkkkkkk
  Object 0xe00000000fd4bfc8:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b=
 6b 6b kkkkkkkkkkkkkkkk
  Object 0xe00000000fd4bfd8:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b=
 6b 6b kkkkkkkkkkkkkkkk
  Object 0xe00000000fd4bfe8:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b=
 6b 6b kkkkkkkkkkkkkkkk
  Object 0xe00000000fd4bff8:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b=
 6b 6b kkkkkkkkkkkkkkkk
  Object 0xe00000000fd4c008:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b=
 6b 6b kkkkkkkkkkkkkkkk
  Object 0xe00000000fd4c018:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b=
 6b 6b kkkkkkkkkkkkkkkk
  Object 0xe00000000fd4c028:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b=
 6b 6b kkkkkkkkkkkkkkkk
  Object 0xe00000000fd4c038:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b=
 6b 6b kkkkkkkkkkkkkkkk
  Object 0xe00000000fd4c048:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b=
 6b 6b kkkkkkkkkkkkkkkk
  Object 0xe00000000fd4c058:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b=
 6b 6b kkkkkkkkkkkkkkkk
  Object 0xe00000000fd4c068:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b=
 6b 6b kkkkkkkkkkkkkkkk
  Object 0xe00000000fd4c078:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b=
 6b 6b kkkkkkkkkkkkkkkk
  Object 0xe00000000fd4c088:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b=
 6b 6b kkkkkkkkkkkkkkkk
  Object 0xe00000000fd4c098:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b=
 6b 6b kkkkkkkkkkkkkkkk
  Object 0xe00000000fd4c0a8:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b=
 6b 6b kkkkkkkkkkkkkkkk
  Object 0xe00000000fd4c0b8:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b=
 6b 6b kkkkkkkkkkkkkkkk
  Object 0xe00000000fd4c0c8:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b=
 6b 6b kkkkkkkkkkkkkkkk
  Object 0xe00000000fd4c0d8:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b=
 6b 6b kkkkkkkkkkkkkkkk
  Object 0xe00000000fd4c0e8:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b=
 6b 6b kkkkkkkkkkkkkkkk
  Object 0xe00000000fd4c0f8:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b=
 6b 6b kkkkkkkkkkkkkkkk
  Object 0xe00000000fd4c108:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b=
 6b 6b kkkkkkkkkkkkkkkk
  Object 0xe00000000fd4c118:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b=
 6b 6b kkkkkkkkkkkkkkkk
  Object 0xe00000000fd4c128:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b=
 6b 6b kkkkkkkkkkkkkkkk
  Object 0xe00000000fd4c138:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b=
 6b 6b kkkkkkkkkkkkkkkk
  Object 0xe00000000fd4c148:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b=
 6b 6b kkkkkkkkkkkkkkkk
  Object 0xe00000000fd4c158:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b=
 6b 6b kkkkkkkkkkkkkkkk
  Object 0xe00000000fd4c168:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b=
 6b 6b kkkkkkkkkkkkkkkk
  Object 0xe00000000fd4c178:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b=
 6b 6b kkkkkkkkkkkkkkkk
  Object 0xe00000000fd4c188:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b=
 6b 6b kkkkkkkkkkkkkkkk
  Object 0xe00000000fd4c198:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b=
 6b 6b kkkkkkkkkkkkkkkk
  Object 0xe00000000fd4c1a8:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b=
 6b 6b kkkkkkkkkkkkkkkk
  Object 0xe00000000fd4c1b8:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b=
 6b 6b kkkkkkkkkkkkkkkk
  Object 0xe00000000fd4c1c8:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b=
 6b 6b kkkkkkkkkkkkkkkk
  Object 0xe00000000fd4c1d8:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b=
 6b 6b kkkkkkkkkkkkkkkk
  Object 0xe00000000fd4c1e8:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b=
 6b 6b kkkkkkkkkkkkkkkk
  Object 0xe00000000fd4c1f8:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b=
 6b 6b kkkkkkkkkkkkkkkk
  Object 0xe00000000fd4c208:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b=
 6b 6b kkkkkkkkkkkkkkkk
  Object 0xe00000000fd4c218:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b=
 6b 6b kkkkkkkkkkkkkkkk
  Object 0xe00000000fd4c228:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b=
 6b 6b kkkkkkkkkkkkkkkk
  Object 0xe00000000fd4c238:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b=
 6b 6b kkkkkkkkkkkkkkkk
  Object 0xe00000000fd4c248:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b=
 6b 6b kkkkkkkkkkkkkkkk
  Object 0xe00000000fd4c258:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b=
 6b 6b kkkkkkkkkkkkkkkk
  Object 0xe00000000fd4c268:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b=
 6b 6b kkkkkkkkkkkkkkkk
  Object 0xe00000000fd4c278:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b=
 6b 6b kkkkkkkkkkkkkkkk
  Object 0xe00000000fd4c288:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b=
 6b 6b kkkkkkkkkkkkkkkk
  Object 0xe00000000fd4c298:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b=
 6b 6b kkkkkkkkkkkkkkkk
  Object 0xe00000000fd4c2a8:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b=
 6b 6b kkkkkkkkkkkkkkkk
  Object 0xe00000000fd4c2b8:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b=
 6b 6b kkkkkkkkkkkkkkkk
  Object 0xe00000000fd4c2c8:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b=
 6b 6b kkkkkkkkkkkkkkkk
  Object 0xe00000000fd4c2d8:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b=
 6b 6b kkkkkkkkkkkkkkkk
  Object 0xe00000000fd4c2e8:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b=
 6b 6b kkkkkkkkkkkkkkkk
  Object 0xe00000000fd4c2f8:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b=
 6b 6b kkkkkkkkkkkkkkkk
  Object 0xe00000000fd4c308:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b=
 6b 6b kkkkkkkkkkkkkkkk
  Object 0xe00000000fd4c318:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b=
 6b 6b kkkkkkkkkkkkkkkk
  Object 0xe00000000fd4c328:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b=
 6b 6b kkkkkkkkkkkkkkkk
  Object 0xe00000000fd4c338:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b=
 6b 6b kkkkkkkkkkkkkkkk
  Object 0xe00000000fd4c348:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b=
 6b 6b kkkkkkkkkkkkkkkk
  Object 0xe00000000fd4c358:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b=
 6b 6b kkkkkkkkkkkkkkkk
  Object 0xe00000000fd4c368:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b=
 6b 6b kkkkkkkkkkkkkkkk
  Object 0xe00000000fd4c378:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b=
 6b 6b kkkkkkkkkkkkkkkk
  Object 0xe00000000fd4c388:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b=
 6b 6b kkkkkkkkkkkkkkkk
  Object 0xe00000000fd4c398:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b=
 6b 6b kkkkkkkkkkkkkkkk
  Object 0xe00000000fd4c3a8:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b=
 6b 6b kkkkkkkkkkkkkkkk
  Object 0xe00000000fd4c3b8:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b=
 6b 6b kkkkkkkkkkkkkkkk
  Object 0xe00000000fd4c3c8:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b=
 6b 6b kkkkkkkkkkkkkkkk
  Object 0xe00000000fd4c3d8:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b=
 6b 6b kkkkkkkkkkkkkkkk
  Object 0xe00000000fd4c3e8:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b=
 6b 6b kkkkkkkkkkkkkkkk
  Object 0xe00000000fd4c3f8:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b=
 6b 6b kkkkkkkkkkkkkkkk
  Object 0xe00000000fd4c408:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b=
 6b 6b kkkkkkkkkkkkkkkk
  Object 0xe00000000fd4c418:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b=
 6b 6b kkkkkkkkkkkkkkkk
  Object 0xe00000000fd4c428:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b=
 6b 6b kkkkkkkkkkkkkkkk
  Object 0xe00000000fd4c438:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b=
 6b 6b kkkkkkkkkkkkkkkk
  Object 0xe00000000fd4c448:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b=
 6b 6b kkkkkkkkkkkkkkkk
  Object 0xe00000000fd4c458:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b=
 6b 6b kkkkkkkkkkkkkkkk
  Object 0xe00000000fd4c468:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b=
 6b 6b kkkkkkkkkkkkkkkk
  Object 0xe00000000fd4c478:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b=
 6b 6b kkkkkkkkkkkkkkkk
  Object 0xe00000000fd4c488:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b=
 6b 6b kkkkkkkkkkkkkkkk
  Object 0xe00000000fd4c498:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b=
 6b 6b kkkkkkkkkkkkkkkk
  Object 0xe00000000fd4c4a8:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b=
 6b 6b kkkkkkkkkkkkkkkk
  Object 0xe00000000fd4c4b8:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b=
 6b 6b kkkkkkkkkkkkkkkk
  Object 0xe00000000fd4c4c8:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b=
 6b 6b kkkkkkkkkkkkkkkk
  Object 0xe00000000fd4c4d8:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b=
 6b 6b kkkkkkkkkkkkkkkk
  Object 0xe00000000fd4c4e8:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b=
 6b 6b kkkkkkkkkkkkkkkk
  Object 0xe00000000fd4c4f8:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b=
 6b 6b kkkkkkkkkkkkkkkk
  Object 0xe00000000fd4c508:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b=
 6b 6b kkkkkkkkkkkkkkkk
  Object 0xe00000000fd4c518:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b=
 6b 6b kkkkkkkkkkkkkkkk
  Object 0xe00000000fd4c528:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b=
 6b 6b kkkkkkkkkkkkkkkk
  Object 0xe00000000fd4c538:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b=
 6b 6b kkkkkkkkkkkkkkkk
  Object 0xe00000000fd4c548:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b=
 6b 6b kkkkkkkkkkkkkkkk
  Object 0xe00000000fd4c558:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b=
 6b 6b kkkkkkkkkkkkkkkk
  Object 0xe00000000fd4c568:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b=
 6b 6b kkkkkkkkkkkkkkkk
  Object 0xe00000000fd4c578:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b=
 6b 6b kkkkkkkkkkkkkkkk
  Object 0xe00000000fd4c588:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b=
 6b 6b kkkkkkkkkkkkkkkk
  Object 0xe00000000fd4c598:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b=
 6b 6b kkkkkkkkkkkkkkkk
  Object 0xe00000000fd4c5a8:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b=
 6b 6b kkkkkkkkkkkkkkkk
  Object 0xe00000000fd4c5b8:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b=
 6b 6b kkkkkkkkkkkkkkkk
  Object 0xe00000000fd4c5c8:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b=
 6b 6b kkkkkkkkkkkkkkkk
  Object 0xe00000000fd4c5d8:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b=
 6b 6b kkkkkkkkkkkkkkkk
  Object 0xe00000000fd4c5e8:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b=
 6b 6b kkkkkkkkkkkkkkkk
  Object 0xe00000000fd4c5f8:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b=
 6b 6b kkkkkkkkkkkkkkkk
  Object 0xe00000000fd4c608:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b=
 6b 6b kkkkkkkkkkkkkkkk
  Object 0xe00000000fd4c618:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b=
 6b 6b kkkkkkkkkkkkkkkk
  Object 0xe00000000fd4c628:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b=
 6b 6b kkkkkkkkkkkkkkkk
  Object 0xe00000000fd4c638:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b=
 6b 6b kkkkkkkkkkkkkkkk
  Object 0xe00000000fd4c648:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b=
 6b 6b kkkkkkkkkkkkkkkk
  Object 0xe00000000fd4c658:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b=
 6b 6b kkkkkkkkkkkkkkkk
  Object 0xe00000000fd4c668:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b=
 6b a5 kkkkkkkkkkkkkkk=A5
 Redzone 0xe00000000fd4c678:  bb bb bb bb bb bb bb bb                  =
       =BB=BB=BB=BB=BB=BB=BB=BB   =20
 Padding 0xe00000000fd4c6b8:  5a 5a 5a 5a 5a 5a 5a 5a                  =
       ZZZZZZZZ   =20

Call Trace:
 [<a000000100019be0>] show_stack+0x80/0xa0
                                sp=3Da000000100cff9d0 bsp=3Da000000100c=
f1700
 [<a000000100019c30>] dump_stack+0x30/0x60
                                sp=3Da000000100cffba0 bsp=3Da000000100c=
f16e8
 [<a00000010022d7a0>] print_trailer+0x2a0/0x2c0
                                sp=3Da000000100cffba0 bsp=3Da000000100c=
f16a8
 [<a00000010022e450>] check_bytes_and_report+0x150/0x1e0
                                sp=3Da000000100cffba0 bsp=3Da000000100c=
f1640
 [<a00000010022e7d0>] check_object+0x2f0/0x540
                                sp=3Da000000100cffba0 bsp=3Da000000100c=
f15e8
 [<a000000100236370>] __slab_alloc+0xc30/0xea0
                                sp=3Da000000100cffba0 bsp=3Da000000100c=
f1570
 [<a0000001002387d0>] __kmalloc_node_track_caller+0x510/0x760
                                sp=3Da000000100cffbb0 bsp=3Da000000100c=
f1510
 [<a00000010075bfd0>] __alloc_skb+0xb0/0x2c0
                                sp=3Da000000100cffbb0 bsp=3Da000000100c=
f14c8
 [<a00000010075ca50>] __netdev_alloc_skb+0x50/0xc0
                                sp=3Da000000100cffbb0 bsp=3Da000000100c=
f1498
 [<a00000010063d040>] e100_rx_alloc_skb+0x40/0x440
                                sp=3Da000000100cffbb0 bsp=3Da000000100c=
f1440
 [<a000000100641c70>] e100_poll+0x4d0/0xe20
                                sp=3Da000000100cffbb0 bsp=3Da000000100c=
f1350
 [<a00000010077ca30>] net_rx_action+0x410/0x8a0
                                sp=3Da000000100cffbb0 bsp=3Da000000100c=
f12b8
 [<a0000001000fde10>] __do_softirq+0x3b0/0x8c0
                                sp=3Da000000100cffbb0 bsp=3Da000000100c=
f11d8
 [<a0000001000fe480>] do_softirq+0x160/0x1e0
                                sp=3Da000000100cffbb0 bsp=3Da000000100c=
f1178
 [<a0000001000fe6a0>] irq_exit+0x1a0/0x1c0
                                sp=3Da000000100cffbb0 bsp=3Da000000100c=
f1160
 [<a000000100015660>] ia64_handle_irq+0x420/0x900
                                sp=3Da000000100cffbb0 bsp=3Da000000100c=
f10f8
 [<a00000010008dea0>] paravirt_leave_kernel+0x0/0x40
                                sp=3Da000000100cffbb0 bsp=3Da000000100c=
f10f8
 [<a00000010001b160>] default_idle+0x380/0x3c0
                                sp=3Da000000100cffd80 bsp=3Da000000100c=
f1090
 [<a000000100019700>] cpu_idle+0x2e0/0x600
                                sp=3Da000000100cffe20 bsp=3Da000000100c=
f1030
 [<a00000010088c360>] rest_init+0x140/0x160
                                sp=3Da000000100cffe20 bsp=3Da000000100c=
f1018
 [<a000000100b01ab0>] start_kernel+0x8f0/0xa00
                                sp=3Da000000100cffe20 bsp=3Da000000100c=
f0f98
 [<a0000001008dc110>] _start+0x7d0/0x7f0
                                sp=3Da000000100cffe30 bsp=3Da000000100c=
f0f00
=46IX kmalloc-2048: Restoring 0xe00000000fd4be9a-0xe00000000fd4bf33=3D0=
x6b

=46IX kmalloc-2048: Marking all objects used


