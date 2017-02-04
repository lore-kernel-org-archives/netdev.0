From: Shannon Nelson <shannon.nelson@oracle.com>
Subject: Re: [PATCH net-next 5/9] sunvnet: add memory barrier before check for
 tx enable
Date: Sat, 4 Feb 2017 14:39:53 -0800
Message-ID: <884c76d5-4881-05b4-582e-bc97a0538586@oracle.com>
References: <1486143755-192532-1-git-send-email-shannon.nelson@oracle.com>
 <1486143755-192532-6-git-send-email-shannon.nelson@oracle.com>
 <1486144585.21871.92.camel@edumazet-glaptop3.roam.corp.google.com>
 <d9d5ba0c-35dc-d10b-6eef-4d056732b8cf@oracle.com>
 <1486159919.21871.104.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net,
        sparclinux@vger.kernel.org, linux-kernel@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <sparclinux-owner@vger.kernel.org>
In-Reply-To: <1486159919.21871.104.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: sparclinux-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 2/3/2017 2:11 PM, Eric Dumazet wrote:
>
> Transmit completion might happen on another cpu, regardless of ldom.
>
> Therefore you need smp_rmb() here ( like mellanox/mlx4/en_tx.c) , or
> even smp_mb() as bnx2x does.
>
> dma_rmb() is never used in this context.
>

In that case, it looks like there are a couple other similar issues in 
this code that need attention, that cropped up when the new dma_*mb() 
interface was added.  I'll see what I can do with those as well.

The comments and code a few lines above, some of DaveM's original driver 
code, seem to dissuade us from the SMP version and originally used the 
bare wmb().  Perhaps the bare rmb() should be used here?  Again, I 
suppose it doesn't matter much as it looks like they all boil down to 
the same bit of asm, at least on sparc, which is all that matters for 
this driver.

Thanks,
sln

