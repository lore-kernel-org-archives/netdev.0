From: Richard Weinberger <richard@nod.at>
Subject: Re: [PATCH] lib: test_bpf: purge CPP register redefinitions
Date: Mon, 22 Jun 2015 08:52:55 +0200
Message-ID: <5587B0C7.8090507@nod.at>
References: <87twu0df3k.fsf@gmail.com> <20150622060523.GA16156@Alexeis-MacBook-Pro.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, daniel@iogearbox.net
To: Alexei Starovoitov <alexei.starovoitov@gmail.com>,
	Nicolai Stange <nicstange@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.ns.miles-group.at ([95.130.255.143]:65276 "EHLO radon.swed.at"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751178AbbFVGw7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 22 Jun 2015 02:52:59 -0400
In-Reply-To: <20150622060523.GA16156@Alexeis-MacBook-Pro.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Am 22.06.2015 um 08:05 schrieb Alexei Starovoitov:
> to get rid of warning you proposing to do 1k line renames?!
> Just add:
> +#undef R8
> +#undef R9
> +#undef R10
>  #define R0             BPF_REG_0

This would be also just another hack.

> Though I think the better fix woud be to clean up:
> arch/x86/include/uapi/asm/ptrace-abi.h
> What's the point of:
> #define R8 72
> from 'uapi' point of view?

To query cpu registers using ptrace(2).

> Look like kernel details that shouldn't be exposed in uapi.

These are not kernel details.

Actually the problem is the other way around.
UML is Linux ported to it's own userspace ABI.
Hence, the arch/um and arch/x86/um use uapi header files.

Maybe we can rework UML's header files such that
no uapi header pollutes the kernel namespace.

That said, lib/test_bpf.c should still not use
defines like R8 as such symbols are very generic.

Thanks,
//richard
