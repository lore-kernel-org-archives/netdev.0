From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: tools/testing/selftests/bpf/Makefile
Date: Sun, 23 Apr 2017 09:13:05 -0700
Message-ID: <20170423161303.GA9335@ast-mbp.thefacebook.com>
References: <20170422.154501.1876167225428231606.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: daniel@iogearbox.net, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f170.google.com ([209.85.223.170]:35272 "EHLO
        mail-io0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1045890AbdDWQNK (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 23 Apr 2017 12:13:10 -0400
Received: by mail-io0-f170.google.com with SMTP id r16so153997410ioi.2
        for <netdev@vger.kernel.org>; Sun, 23 Apr 2017 09:13:09 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20170422.154501.1876167225428231606.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Apr 22, 2017 at 03:45:01PM -0400, David Miller wrote:
> 
> Alexei, that unconditional -D__x86_64__ isn't going to work.  It in
> fact makes the build break on sparc because the types.h asm headers
> explicitly check for things like __sparc__ && __arch64__ etc.

yeah. it was a quick workaround for the following error:
In file included from net-next/tools/testing/selftests/bpf/test_xdp.c:8:
In file included from /usr/include/string.h:25:
In file included from /usr/include/features.h:399:
/usr/include/gnu/stubs.h:7:11: fatal error: 'gnu/stubs-32.h' file not found

the bpf progs don't do any x86 specific things.

> In every
> 	arch/${ARCH}/Makefile
> extract out the "-DXXX" stuff from CHECKFLAGS into a new Makefile

that should work. Probably there is even simpler way.
