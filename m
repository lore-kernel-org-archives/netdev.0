From: itkes@fat.imec.msu.ru
Subject: A bug in the Kernel?
Date: Sun, 27 Feb 2005 19:00:29 +0300 (MSK)
Message-ID: <1125.80.249.146.137.1109520029.squirrel@mx.imec.msu.ru>
Mime-Version: 1.0
Content-Type: multipart/mixed;boundary="----=_20050227190029_84044"
To: netdev@oss.sgi.com
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

------=_20050227190029_84044
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit

Hello.

I think I have found a bug in the Linux Kernel.

Although Netlink is not a reliable protocol, the kernel must do everything
to transmit the correct information about networking subsystem state. For
example, if an application reuqests the routing table dump, the kernel
must send at least all the routes that had not been modified, added or
deleted during the dump operation.

Let us suppose the application to request the routing tabled dump. I heve
found that in some conditions, this application may not receive some
unchanged routes, if some other routes was deleted.

I have fixed the bug of routing tables dump, but same errors may occure in
process of net interfaces dump, routing rules dump etc. The patch to
kernel 2.6.11-rc5 is attached. I ask you to include it to the next kernel
release.

If you will add my code to the kernel, could I try to correct other bugs
of this type? I have almost finished correcting the routing rules dump.

Alex Itkes (Moscow State University).

P.S. After I have finished the patch, I found another bug in the Routing
Tables Dump. In function fn_hash_dump_bucket in fib_hash.c there is a
construction:
if (i<s_i)
	continue;
...
i++;
If the first "if" is true in first moment, "i" will never be increased and
some routes will be lost. My patch fixes this bug, too.

------=_20050227190029_84044
Content-Type: application/x-gzip-compressed; name="patch-2.6.11-rc5-nl01.gz"
Content-Transfer-Encoding: base64
Content-Disposition: attachment; filename="patch-2.6.11-rc5-nl01.gz"

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
------=_20050227190029_84044--
