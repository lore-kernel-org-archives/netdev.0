From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [PATCH v2] bpf: silence warnings when building kernel/bpf/core.c
 with W=1
Date: Sun, 31 Jul 2016 21:42:22 -0700
Message-ID: <20160801044220.GA97382@ast-mbp.thefacebook.com>
References: <23710.1470026010@turing-police.cc.vt.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Alexei Starovoitov <ast@kernel.org>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	Peter Zijlstra <peterz@infradead.org>,
	Ingo Molnar <mingo@kernel.org>
To: Valdis Kletnieks <Valdis.Kletnieks@vt.edu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f68.google.com ([209.85.220.68]:36120 "EHLO
	mail-pa0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750897AbcHAEm1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Aug 2016 00:42:27 -0400
Content-Disposition: inline
In-Reply-To: <23710.1470026010@turing-police.cc.vt.edu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Aug 01, 2016 at 12:33:30AM -0400, Valdis Kletnieks wrote:
> Building with W=1 generates some 350 lines of warnings of the form:
> 
> kernel/bpf/core.c: In function '__bpf_prog_run':
> kernel/bpf/core.c:476:33: warning: initialized field overwritten [-Woverride-init]
>    [BPF_ALU | BPF_ADD | BPF_X] = &&ALU_ADD_X,
>                                  ^~
> kernel/bpf/core.c:476:33: note: (near initialization for 'jumptable[12]')
> 
> Since they come from the way we intentionally build the table, silence
> that one specific warning.
> 
> Signed-off-by: Valdis Kletnieks <valdis.kletnieks@vt.edu>
> 
> Version 2: Add bpf: subsystem tag to subject line
> 
> diff --git a/kernel/bpf/Makefile b/kernel/bpf/Makefile
> index eed911d091da..bb915f9d9f92 100644
> --- a/kernel/bpf/Makefile
> +++ b/kernel/bpf/Makefile
> @@ -1,3 +1,4 @@
> +CFLAGS_core.o += -Wno-override-init

and at least 2 other such patches for other files...
Is there a single warning where -Woverride-init was useful?
May be worth disabling this warning for the whole build?
