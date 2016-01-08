From: Will Deacon <will.deacon@arm.com>
Subject: Re: [PATCH] arm64: net: bpf: don't BUG() on large shifts
Date: Fri, 8 Jan 2016 15:44:23 +0000
Message-ID: <20160108154423.GC11228@arm.com>
References: <1452015543-6790-1-git-send-email-rabin@rab.in>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org, zlim.lnx@gmail.com,
	yang.shi@linaro.org, catalin.marinas@arm.com,
	linux-arm-kernel@lists.infradead.org
To: Rabin Vincent <rabin@rab.in>
Return-path: <netdev-owner@vger.kernel.org>
Received: from foss.arm.com ([217.140.101.70]:46133 "EHLO foss.arm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750860AbcAHPoZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 8 Jan 2016 10:44:25 -0500
Content-Disposition: inline
In-Reply-To: <1452015543-6790-1-git-send-email-rabin@rab.in>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jan 05, 2016 at 06:39:03PM +0100, Rabin Vincent wrote:
> Attempting to generate UBFM/SBFM instructions with shifts that can't be
> encoded in the immediate fields of the opcodes leads to a trigger of a
> BUG() in the instruction generation code.  As the ARMv8 ARM says: "The
> shift amounts must be in the range 0 to one less than the register width
> of the instruction, inclusive."  Make the JIT reject unencodable shifts
> instead of crashing.

I moaned about those BUG_ONs when they were introduced:

  https://lkml.org/lkml/2014/7/17/438

The response then was that the verifier would catch these issues so
there was nothing to worry about. Has something changed so that is no
longer the case? Do we need to consider a different way of rejecting
invalid instructions at the encoding stage rather than bringing down the
kernel?

Will
