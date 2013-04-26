From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [RFC PATCH net-next 2/6] x86: bpf_jit_comp: support
 BPF_S_ANC_SECCOMP_LD_W instruction
Date: Fri, 26 Apr 2013 07:18:46 -0700
Message-ID: <1366985926.8964.190.camel@edumazet-glaptop>
References: <1366962706-24204-1-git-send-email-xi.wang@gmail.com>
	 <1366962706-24204-3-git-send-email-xi.wang@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Daniel Borkmann <dborkman@redhat.com>,
	"David S. Miller" <davem@davemloft.net>,
	Russell King <linux@arm.linux.org.uk>,
	Heiko Carstens <heiko.carstens@de.ibm.com>,
	Eric Dumazet <edumazet@google.com>,
	Will Drewry <wad@chromium.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Xi Wang <xi.wang@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1366962706-24204-3-git-send-email-xi.wang@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 2013-04-26 at 03:51 -0400, Xi Wang wrote:

> +#ifdef CONFIG_SECCOMP_FILTER
> +			case BPF_S_ANC_SECCOMP_LD_W:
> +				if (K == offsetof(struct seccomp_data, arch)) {
> +					int arch = syscall_get_arch(current, NULL);
> +
> +					EMIT1_off32(0xb8, arch); /* mov arch,%eax */
> +					break;
> +				}
> +				func = (u8 *)seccomp_bpf_load;
> +				t_offset = func - (image + addrs[i]);
> +				EMIT1_off32(0xbf, K); /* mov imm32,%edi */
> +				EMIT1_off32(0xe8, t_offset); /* call seccomp_bpf_load */
> +				break;
> +#endif

This seems seriously wrong to me.

This cannot have been tested at all.
