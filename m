From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH 0/9 v2] use efficient this_cpu_* helper
Date: Fri, 2 Nov 2012 17:49:12 +0000
Message-ID: <0000013ac23daa38-76df0db5-322e-4df6-bcb8-0be356eb8846-000000@email.amazonses.com>
References: <5093EEC2.7000109@gmail.com>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="288502408-1248043375-1351878512=:7937"
Cc: David Miller <davem@davemloft.net>,
	NetDev <netdev@vger.kernel.org>,
	Kernel-Maillist <linux-kernel@vger.kernel.org>
To: Shan Wei <shanwei88@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <5093EEC2.7000109@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

--288502408-1248043375-1351878512=:7937
Content-Type: TEXT/PLAIN; charset=UTF-8
Content-Transfer-Encoding: 8BIT

On Sat, 3 Nov 2012, Shan Wei wrote:

> this_cpu_ptr is faster than per_cpu_ptr(p, smp_processor_id())
> and can reduce  memory accesses.
> The latter helper needs to find the offset for current cpu,
> and needs more assembler instructions which objdump shows in following.
>
> per_cpu_ptr(p, smp_processor_id())：
>   1e:   65 8b 04 25 00 00 00 00         mov    %gs:0x0,%eax
>   26:   48 98                           cltq
>   28:   31 f6                           xor    %esi,%esi
>   2a:   48 c7 c7 00 00 00 00            mov    $0x0,%rdi
>   31:   48 8b 04 c5 00 00 00 00         mov    0x0(,%rax,8),%rax
>   39:   c7 44 10 04 14 00 00 00         movl   $0x14,0x4(%rax,%rdx,1)
>
> this_cpu_ptr(p)
>   1e:   65 48 03 14 25 00 00 00 00      add    %gs:0x0,%rdx
>   27:   31 f6                           xor    %esi,%esi
>   29:   c7 42 04 14 00 00 00            movl   $0x14,0x4(%rdx)
>   30:   48 c7 c7 00 00 00 00            mov    $0x0,%rdi

this_cpu_read() etc even avoids the use of this_cpu_ptr()
reducing the 6 instructions earlier to 1.
--288502408-1248043375-1351878512=:7937--
