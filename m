From: "Brad House" <brad_mssw@gentoo.org>
Subject: forcedeth 0.17 bug + test results
Date: Mon, 17 Nov 2003 00:47:29 -0500 (EST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <48012.68.105.173.45.1069048049.squirrel@mail.mainstreetsoftworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: 8bit
Return-path: <netdev-bounce@oss.sgi.com>
To: <netdev@oss.sgi.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

The 0.17 patch had an improper length indicator so the last
2 lines of forcedeth.c were not included, which would cause a
big nothing to happen when trying to modprobe the driver.
The 2 lines lost were, even though they were in the patch,
the length indicator prevented them from being copied into
forcedeth.c:
+module_init(init_nic);
+module_exit(exit_nic);

Anyhow, an updated patch that includes those 2 lines against
2.6.0-test9-bk21 is here:
http://dev.gentoo.org/~brad_mssw/kernel_patches/2.6.0/genpatches-0.4/300_NVIDIA_forcedeth_v17_gentoo.patch

No black magic though, the only thing changed is the length indicator
in reality.

As for test results, we have a success report on amd64/x86_64 on
an nForce3 board in 64bit mode. Transfers on a 100Mbit network using
scp are around 5MBytes/s, which is quite impressive (40Mbits/s), even though
there are 'proclaimed irq problems'. (150 MB file)

Thanks for the great work!

Please CC me on any replies as I am not subscribed to this list.

-Brad House
brad_mssw@gentoo.org
