From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [PATCH] bpf: make bpf_stackmap_copy conditionally called
Date: Wed, 9 Mar 2016 19:38:47 -0800
Message-ID: <20160310033845.GA62491@ast-mbp.thefacebook.com>
References: <1457574245-2998842-1-git-send-email-arnd@arndb.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Alexei Starovoitov <ast@kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	Daniel Borkmann <daniel@iogearbox.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Arnd Bergmann <arnd@arndb.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1457574245-2998842-1-git-send-email-arnd@arndb.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Mar 10, 2016 at 02:43:42AM +0100, Arnd Bergmann wrote:
> Changing the bpf syscall to use the new bpf_stackmap_copy() helper for
> BPF_MAP_TYPE_STACK_TRACE causes a link error when CONFIG_PERF_EVENTS
> is disabled:
> 
> kernel/built-in.o: In function `map_lookup_elem':
> :(.text+0x7fca4): undefined reference to `bpf_stackmap_copy'
> 
> This patch simply avoids handling that case, which may or may not
> be the correct answer here.
> 
> Signed-off-by: Arnd Bergmann <arnd@arndb.de>
> Fixes: 557c0c6e7df8 ("bpf: convert stackmap to pre-allocation")
...
> -	} else if (map->map_type == BPF_MAP_TYPE_STACK_TRACE) {
> +	} else if (map->map_type == BPF_MAP_TYPE_STACK_TRACE &&
> +		   IS_ENABLED(CONFIG_PERF_EVENTS)) {
>  		err = bpf_stackmap_copy(map, key, value);
>  	} else {

yes. this is also ok-ish fix.
I've sent different version already:
http://patchwork.ozlabs.org/patch/595617/

I considered the option like yours but it's relying on gcc doing
dead code elimination of 'if (false) {}' branch and though kernel
is never compiled with -O0. I didn't want to take the risk.
I'm fine with either approach though.
