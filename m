From: "David S. Miller" <davem@redhat.com>
Subject: hostap crypto bugs
Date: Wed, 2 Jun 2004 21:36:34 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040602213634.11ec61bf.davem@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, jgarzik@pobox.com
Return-path: <netdev-bounce@oss.sgi.com>
To: jkmaline@cc.hut.fi
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


You cannot invoke virt_to_page() on addresses on the kernel stack,
and that is what the various HostAP crypto modules are doing.

This happens to work on some platforms, but it is going to explode
on others.

Allocate these little header scratch area blobs in the per-crypto-instance
structs you kmalloc instead.
