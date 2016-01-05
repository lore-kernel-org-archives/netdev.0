From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH] net: filter: make JITs zero A for SKF_AD_ALU_XOR_X
Date: Tue, 05 Jan 2016 17:36:47 +0100
Message-ID: <568BF11F.1060507@iogearbox.net>
References: <1452007387-626-1-git-send-email-rabin@rab.in>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ast@kernel.org,
	linux-arm-kernel@lists.infradead.org, linux-mips@linux-mips.org,
	linuxppc-dev@lists.ozlabs.org, sparclinux@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Rabin Vincent <rabin@rab.in>, davem@davemloft.net
Return-path: <sparclinux-owner@vger.kernel.org>
In-Reply-To: <1452007387-626-1-git-send-email-rabin@rab.in>
Sender: sparclinux-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 01/05/2016 04:23 PM, Rabin Vincent wrote:
> The SKF_AD_ALU_XOR_X ancillary is not like the other ancillary data
> instructions since it XORs A with X while all the others replace A with
> some loaded value.  All the BPF JITs fail to clear A if this is used as
> the first instruction in a filter.  This was found using american fuzzy
> lop.
>
> Add a helper to determine if A needs to be cleared given the first
> instruction in a filter, and use this in the JITs.  Except for ARM, the
> rest have only been compile-tested.
>
> Fixes: 3480593131e0 ("net: filter: get rid of BPF_S_* enum")
> Signed-off-by: Rabin Vincent <rabin@rab.in>

Excellent catch, thanks a lot! The fix looks good to me and should
go to -net tree.

Acked-by: Daniel Borkmann <daniel@iogearbox.net>

If you're interested, feel free to add a small test case for the
SKF_AD_ALU_XOR_X issue to lib/test_bpf.c for -net-next tree. Thanks!
