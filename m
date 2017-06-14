From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH 4/4] samples/bpf: Fix tracex5 to work with MIPS syscalls.
Date: Wed, 14 Jun 2017 02:21:36 +0200
Message-ID: <59408190.6030206@iogearbox.net>
References: <20170613234938.4823-1-david.daney@cavium.com> <20170613234938.4823-5-david.daney@cavium.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-mips@linux-mips.org, ralf@linux-mips.org
To: David Daney <david.daney@cavium.com>,
        Alexei Starovoitov <ast@kernel.org>,
        "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170613234938.4823-5-david.daney@cavium.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 06/14/2017 01:49 AM, David Daney wrote:
> There are two problems:
>
> 1) In MIPS the __NR_* macros expand to an expression, this causes the
>     sections of the object file to be named like:
>
>    .
>    .
>    .
>    [ 5] kprobe/(5000 + 1) PROGBITS        0000000000000000 000160 ...
>    [ 6] kprobe/(5000 + 0) PROGBITS        0000000000000000 000258 ...
>    [ 7] kprobe/(5000 + 9) PROGBITS        0000000000000000 000348 ...
>    .
>    .
>    .
>
> The fix here is to use the "asm_offsets" trick to evaluate the macros
> in the C compiler and generate a header file with a usable form of the
> macros.
>
> 2) MIPS syscall numbers start at 5000, so we need a bigger map to hold
> the sub-programs.
>
> Signed-off-by: David Daney <david.daney@cavium.com>

Acked-by: Daniel Borkmann <daniel@iogearbox.net>
