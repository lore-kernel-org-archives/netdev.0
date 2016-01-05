From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [PATCH] ARM: net: bpf: fix zero right shift
Date: Tue, 5 Jan 2016 09:50:39 -0800
Message-ID: <20160105175038.GB83548@ast-mbp.thefacebook.com>
References: <1452015244-1230-1-git-send-email-rabin@rab.in>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	linux@arm.linux.org.uk, linux-arm-kernel@lists.infradead.org
To: Rabin Vincent <rabin@rab.in>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f52.google.com ([209.85.220.52]:32962 "EHLO
	mail-pa0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751859AbcAERum (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Jan 2016 12:50:42 -0500
Received: by mail-pa0-f52.google.com with SMTP id cy9so218525355pac.0
        for <netdev@vger.kernel.org>; Tue, 05 Jan 2016 09:50:41 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <1452015244-1230-1-git-send-email-rabin@rab.in>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jan 05, 2016 at 06:34:04PM +0100, Rabin Vincent wrote:
> The LSR instruction cannot be used to perform a zero right shift since a
> 0 as the immediate value (imm5) in the LSR instruction encoding means
> that a shift of 32 is perfomed.  See DecodeIMMShift() in the ARM ARM.
> 
> Make the JIT skip generation of the LSR if a zero-shift is requested.
> 
> This was found using american fuzzy lop.
> 
> Signed-off-by: Rabin Vincent <rabin@rab.in>

Looks good as a fix for classic jit. For eBPF we would want to check
this in verifier.

Acked-by: Alexei Starovoitov <ast@kernel.org>
