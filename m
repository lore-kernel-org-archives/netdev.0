From: David Miller <davem@davemloft.net>
Subject: more bpf samples build breakage...
Date: Mon, 01 May 2017 15:30:05 -0400 (EDT)
Message-ID: <20170501.153005.983887567095122966.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: daniel@iogearbox.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:36522 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751770AbdEATaG (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 1 May 2017 15:30:06 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Inlcuding bpf_util.h into test_pkt_access.c et al. broke the build even
more so than it already is on sparc.

The problem is we end up including all the stdio.h bits and eventually
hit things like:

In file included from /usr/include/stdio.h:933:
/usr/include/bits/stdio-ldbl.h:28:20: error: cannot apply asm label to function after its first use
__LDBL_REDIR_DECL (vfprintf)
~~~~~~~~~~~~~~~~~~~^~~~~~~~~
/usr/include/sys/cdefs.h:373:26: note: expanded from macro '__LDBL_REDIR_DECL'
  extern __typeof (name) name __asm (__ASMNAME ("__nldbl_" #name));

So please let's put CLANG compiled helpers into header files
specifically meant to be included by CLANG compiled BPF programs
rather than the host build environment.
