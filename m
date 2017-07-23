From: David Oberhollenzer <david.oberhollenzer@sigma-star.at>
Subject: Kernel TLS in 4.13-rc1
Date: Sun, 23 Jul 2017 21:39:26 +0200
Message-ID: <1777546b-3ce0-7714-1388-fb2e6db9320f@sigma-star.at>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Cc: davejwatson@fb.com, Richard Weinberger <richard@nod.at>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.sigma-star.at ([95.130.255.111]:45996 "EHLO
        mail.sigma-star.at" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751423AbdGWTmL (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 23 Jul 2017 15:42:11 -0400
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi!

I recently wanted to take a look at the kernel TLS support that
made it into 4.13-rc1, but ran into some issues.

After fixing the benchmark/test tool that the patch description
linked to (https://github.com/Mellanox/tls-af_ktls_tool) to make
sure that the server and client actually *agree* on AES-128-GCM,
I simply ran the client program with the --verify-sendpage option.

The handshake and setting up of the sockets appears to work but
the program complains that the sent and received page contents
do not match (sent is 0x12 repeated all over and received looks
pretty random).

I compiled the 4.13-rc1 tarball from kernel.org with
defconfig/kvmconfig for x86_64 and ran it on qemu using a
freshly debootstraped Debian sid rootfs.

I previously also tried it on a physical machine (localmodconfig,
also x86_64), running CentOS 7 and a custom build of recent gnutls
and its dependencies, with the same results.

Surely somebody must have tested this before it was merged? What
am I missing? Am I using a broken version of the benchmark tool
or am I holding it wrong?


Thanks,

David
