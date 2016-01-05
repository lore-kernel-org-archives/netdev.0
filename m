From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] net: filter: make JITs zero A for SKF_AD_ALU_XOR_X
Date: Tue, 05 Jan 2016 08:00:45 -0800
Message-ID: <1452009645.8255.96.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1452007387-626-1-git-send-email-rabin@rab.in>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org, daniel@iogearbox.net,
	ast@kernel.org, linux-arm-kernel@lists.infradead.org,
	linux-mips@linux-mips.org, linuxppc-dev@lists.ozlabs.org,
	sparclinux@vger.kernel.org, linux-kernel@vger.kernel.org
To: Rabin Vincent <rabin@rab.in>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1452007387-626-1-git-send-email-rabin@rab.in>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2016-01-05 at 16:23 +0100, Rabin Vincent wrote:
> The SKF_AD_ALU_XOR_X ancillary is not like the other ancillary data
> instructions since it XORs A with X while all the others replace A with
> some loaded value.  All the BPF JITs fail to clear A if this is used as
> the first instruction in a filter.

Is x86_64 part of this 'All' subset ? ;)

>   This was found using american fuzzy
> lop.
> 
> Add a helper to determine if A needs to be cleared given the first
> instruction in a filter, and use this in the JITs.  Except for ARM, the
> rest have only been compile-tested.
> 
> Fixes: 3480593131e0 ("net: filter: get rid of BPF_S_* enum")
> Signed-off-by: Rabin Vincent <rabin@rab.in>
> ---
