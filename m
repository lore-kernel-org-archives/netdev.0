From: David Miller <davem@davemloft.net>
Subject: Re: [PATCHv2] bpf: fix selftest/bpf/test_pkt_md_access on s390x
Date: Mon, 07 Aug 2017 10:06:53 -0700 (PDT)
Message-ID: <20170807.100653.1873109526074431671.davem@davemloft.net>
References: <20170807081636.65099-1-tmricht@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ast@kernel.org, daniel@iogearbox.net, netdev@vger.kernel.org,
        heiko.carstens@de.ibm.com, schwidefsky@de.ibm.com,
        brueckner@linux.vnet.ibm.com
To: tmricht@linux.vnet.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:60346 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751743AbdHGRG4 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 7 Aug 2017 13:06:56 -0400
In-Reply-To: <20170807081636.65099-1-tmricht@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Thomas Richter <tmricht@linux.vnet.ibm.com>
Date: Mon,  7 Aug 2017 10:16:36 +0200

> Commit 18f3d6be6be1 ("selftests/bpf: Add test cases to test narrower ctx field loads")
> introduced new eBPF test cases. One of them (test_pkt_md_access.c)
> fails on s390x. The BPF verifier error message is:
> 
> [root@s8360046 bpf]# ./test_progs
> test_pkt_access:PASS:ipv4 349 nsec
> test_pkt_access:PASS:ipv6 212 nsec
> [....]
> libbpf: load bpf program failed: Permission denied
> libbpf: -- BEGIN DUMP LOG ---
> libbpf:
> 0: (71) r2 = *(u8 *)(r1 +0)
> invalid bpf_context access off=0 size=1
> 
> libbpf: -- END LOG --
> libbpf: failed to load program 'test1'
> libbpf: failed to load object './test_pkt_md_access.o'
> Summary: 29 PASSED, 1 FAILED
> [root@s8360046 bpf]#
> 
> This is caused by a byte endianness issue. S390x is a big endian
> architecture.  Pointer access to the lowest byte or halfword of a
> four byte value need to add an offset.
> On little endian architectures this offset is not needed.
> 
> Fix this and use the same approach as the originator used for other files
> (for example test_verifier.c) in his original commit.
> 
> With this fix the test program test_progs succeeds on s390x:
 ...
> Signed-off-by: Thomas Richter <tmricht@linux.vnet.ibm.com>
> Acked-by: Daniel Borkmann <daniel@iogearbox.net>

Applied, thanks.
