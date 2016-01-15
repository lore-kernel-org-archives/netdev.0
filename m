From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [PATCH 2/2] arm64: bpf: add extra pass to handle faulty codegen
Date: Thu, 14 Jan 2016 21:09:38 -0800
Message-ID: <20160115050937.GB52169@ast-mbp.thefacebook.com>
References: <1452756802-16511-1-git-send-email-zlim.lnx@gmail.com>
 <1452756802-16511-2-git-send-email-zlim.lnx@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Alexei Starovoitov <ast@kernel.org>,
	Will Deacon <will.deacon@arm.com>,
	"David S. Miller" <davem@davemloft.net>,
	Catalin Marinas <catalin.marinas@arm.com>,
	Rabin Vincent <rabin@rab.in>, netdev@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org
To: Zi Shen Lim <zlim.lnx@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f44.google.com ([209.85.220.44]:33695 "EHLO
	mail-pa0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751236AbcAOFJQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 Jan 2016 00:09:16 -0500
Received: by mail-pa0-f44.google.com with SMTP id cy9so388854935pac.0
        for <netdev@vger.kernel.org>; Thu, 14 Jan 2016 21:09:15 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <1452756802-16511-2-git-send-email-zlim.lnx@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jan 13, 2016 at 11:33:22PM -0800, Zi Shen Lim wrote:
> Code generation functions in arch/arm64/kernel/insn.c previously
> BUG_ON invalid parameters. Following change of that behavior, now we
> need to handle the error case where AARCH64_BREAK_FAULT is returned.
> 
> Instead of error-handling on every emit() in JIT, we add a new
> validation pass at the end of JIT compilation. There's no point in
> running JITed code at run-time only to trap due to AARCH64_BREAK_FAULT.
> Instead, we drop this failed JIT compilation and allow the system to
> gracefully fallback on the BPF interpreter.
> 
> Signed-off-by: Zi Shen Lim <zlim.lnx@gmail.com>
> Suggested-by: Alexei Starovoitov <ast@kernel.org>

Looks good to me.
Acked-by: Alexei Starovoitov <ast@kernel.org>
technically it's a bug fix, though the shift problem is already mitigated.
Will, any comments?
