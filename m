From: David Miller <davem@davemloft.net>
Subject: tools/testing/selftests/bpf/Makefile
Date: Sat, 22 Apr 2017 15:45:01 -0400 (EDT)
Message-ID: <20170422.154501.1876167225428231606.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: daniel@iogearbox.net, netdev@vger.kernel.org
To: alexei.starovoitov@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:54152 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1044100AbdDVTpD (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 22 Apr 2017 15:45:03 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Alexei, that unconditional -D__x86_64__ isn't going to work.  It in
fact makes the build break on sparc because the types.h asm headers
explicitly check for things like __sparc__ && __arch64__ etc.

There are other places that want stuff like this, so let's do it
right.

In every

	arch/${ARCH}/Makefile

extract out the "-DXXX" stuff from CHECKFLAGS into a new Makefile
variable, expand that into CHECKFLAGS and use the new variable in
places like

	tools/testing/selftests/bpf/Makefile

and

	tools/testing/selftests/ipc/Makefile

Thanks.
