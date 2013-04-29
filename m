From: Nicolas Schichan <nschichan@freebox.fr>
Subject: Re: [RFC PATCH net-next 0/6] seccomp filter JIT
Date: Mon, 29 Apr 2013 14:18:13 +0200
Message-ID: <517E6505.6030005@freebox.fr>
References: <1366962706-24204-1-git-send-email-xi.wang@gmail.com> <20130426112539.GA3736@osiris> <517A6915.2020208@redhat.com> <CAKU6vybdnpoM-szTrJRDVM2sqNPvAe3Tszg+tCuziKSOEXjJ1w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Daniel Borkmann <dborkman@redhat.com>,
	Heiko Carstens <heiko.carstens@de.ibm.com>,
	"David S. Miller" <davem@davemloft.net>,
	Russell King <linux@arm.linux.org.uk>,
	Eric Dumazet <edumazet@google.com>,
	Will Drewry <wad@chromium.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Mircea Gherzan <mgherzan@gmail.com>
To: Xi Wang <xi.wang@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAKU6vybdnpoM-szTrJRDVM2sqNPvAe3Tszg+tCuziKSOEXjJ1w@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 04/26/2013 02:31 PM, Xi Wang wrote:
> Thanks for the pointer.
>
> For the ARM part, looks like Nicolas's patch requires to implement two
> wrappers for each arch:
>
>    void seccomp_jit_compile(struct seccomp_filter *fp);
>    void seccomp_jit_free(struct seccomp_filter *fp);
>
> The implementation of these wrappers is almost identical to:
>
>    void bpf_jit_compile(struct sk_filter *fp);
>    void bpf_jit_free(struct sk_filter *fp);
>
> While this patch uses a unified interface for both packet & seccomp filters.
>
>    bpf_func_t bpf_jit_compile(struct sock_filter *filter, unsigned int flen);
>    void bpf_jit_free(bpf_func_t bpf_func);
>
> Shouldn't be hard to merge though.

Hi,

I went for the solution I submitted because I wanted to avoid changes to the 
current bpf_jit_compile prototypes for all currently supported architectures 
(for most of which, I can only compile-test).

My solution also allows the seccomp jit code to be disabled while still 
allowing jit on socket filters (via a Kconfig option). This might be useful to 
some people.

Regards,

-- 
Nicolas Schichan
Freebox SAS
