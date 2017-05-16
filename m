From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] selftests/bpf: fix broken build due to types.h
Date: Tue, 16 May 2017 15:18:32 -0400 (EDT)
Message-ID: <20170516.151832.1830591267264185393.davem@davemloft.net>
References: <20170516184634.2803675-1-yhs@fb.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: daniel@iogearbox.net, netdev@vger.kernel.org, kernel-team@fb.com
To: yhs@fb.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:52702 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750784AbdEPTSe (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 16 May 2017 15:18:34 -0400
In-Reply-To: <20170516184634.2803675-1-yhs@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Please correct the address of the netdev list (it is just plain
'netdev' not 'linux-netdev').

Secondly, __always_inline should not be defined by types.h

That has to come from linux/compiler.h which we have no reason
to define a private version of for eBPF clang compilation.

The problem is that via several layers of indirection, linux/types.h
eventually includes linux/compiler.h and that is probably the more
appropriate thing for you to do.
