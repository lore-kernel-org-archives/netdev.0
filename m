From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH net-next 1/3] arm64: bpf: implement bpf_tail_call() helper
Date: Sun, 05 Jun 2016 09:53:05 +0200
Message-ID: <5753DA61.3000505@iogearbox.net>
References: <201606050700.BLJUHUk2%fengguang.wu@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: kbuild-all@01.org, "David S. Miller" <davem@davemloft.net>,
	Catalin Marinas <catalin.marinas@arm.com>,
	Will Deacon <will.deacon@arm.com>,
	Yang Shi <yang.shi@linaro.org>,
	Alexei Starovoitov <ast@kernel.org>, netdev@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org
To: kbuild test robot <lkp@intel.com>, Zi Shen Lim <zlim.lnx@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <201606050700.BLJUHUk2%fengguang.wu@intel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 06/05/2016 01:46 AM, kbuild test robot wrote:
> Hi,
>
> [auto build test ERROR on net-next/master]
>
> url:    https://github.com/0day-ci/linux/commits/Zi-Shen-Lim/arm64-bpf-implement-bpf_tail_call-helper/20160605-060435
> config: arm64-defconfig (attached as .config)
> compiler: aarch64-linux-gnu-gcc (Debian 5.3.1-8) 5.3.1 20160205
> reproduce:
>          wget https://git.kernel.org/cgit/linux/kernel/git/wfg/lkp-tests.git/plain/sbin/make.cross -O ~/bin/make.cross
>          chmod +x ~/bin/make.cross
>          # save the attached .config to linux build tree
>          make.cross ARCH=arm64
>
> All errors (new ones prefixed by >>):
>
>     In file included from arch/arm64/net/bpf_jit_comp.c:21:0:
>     include/linux/bpf.h: In function 'bpf_prog_get':
>>> include/linux/bpf.h:235:9: error: implicit declaration of function 'ERR_PTR' [-Werror=implicit-function-declaration]
>       return ERR_PTR(-EOPNOTSUPP);
>              ^
>     include/linux/bpf.h:235:9: warning: return makes pointer from integer without a cast [-Wint-conversion]
>     In file included from include/linux/rwsem.h:17:0,
>                      from include/linux/mm_types.h:10,
>                      from include/linux/sched.h:27,
>                      from arch/arm64/include/asm/compat.h:25,
>                      from arch/arm64/include/asm/stat.h:23,
>                      from include/linux/stat.h:5,
>                      from include/linux/compat.h:12,
>                      from include/linux/filter.h:10,
>                      from arch/arm64/net/bpf_jit_comp.c:22:
>     include/linux/err.h: At top level:
>>> include/linux/err.h:23:35: error: conflicting types for 'ERR_PTR'
>      static inline void * __must_check ERR_PTR(long error)
>                                        ^
>     In file included from arch/arm64/net/bpf_jit_comp.c:21:0:
>     include/linux/bpf.h:235:9: note: previous implicit declaration of 'ERR_PTR' was here
>       return ERR_PTR(-EOPNOTSUPP);
>              ^
>     cc1: some warnings being treated as errors

Looks like including linux/bpf.h at the very beginning causes issues when bpf
syscall is disabled. We should probably just include linux/err.h from bpf.h.
