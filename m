From: Daniel Borkmann <dborkman@redhat.com>
Subject: Re: [PATCH net-next v2] net: bpf: make eBPF interpreter images read-only
Date: Tue, 02 Sep 2014 23:47:29 +0200
Message-ID: <54063AF1.4020907@redhat.com>
References: <aa5126f747594d768e0c518189a13e8674ad8ee5.1409690486.git.hannes@stressinduktion.org> <2bf2e54282097642db88e2b596b06a9ac3742883.1409690849.git.hannes@stressinduktion.org> <CAMEtUuyoWELJ0Yf+=5sDKxFEfgsiQ3kMCK+Wn_bdJgS8qaH2og@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Network Development <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>,
	Brad Spengler <spender@grsecurity.net>,
	Kees Cook <keescook@chromium.org>
To: Alexei Starovoitov <ast@plumgrid.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAMEtUuyoWELJ0Yf+=5sDKxFEfgsiQ3kMCK+Wn_bdJgS8qaH2og@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 09/02/2014 11:31 PM, Alexei Starovoitov wrote:
...
>> +#ifdef CONFIG_DEBUG_SET_MODULE_RONX
>> +static inline void bpf_prog_lock_ro(struct bpf_prog *fp)
>> +{
>> +       set_memory_ro((unsigned long)fp, fp->pages);
>
> since ronx are ifdef checked together,
> would probably make sense to set nx too?

In case of JITs, for example, we request pages that are
PAGE_KERNEL_EXEC via module_alloc(), but here we only need
PAGE_KERNEL. At least on x86_64, PAGE_NX is then set already.
