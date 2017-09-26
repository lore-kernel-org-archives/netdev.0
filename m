From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: stmmac: Meet alignment requirements for DMA
Date: Tue, 26 Sep 2017 13:33:09 -0700 (PDT)
Message-ID: <20170926.133309.1916643567158187651.davem@davemloft.net>
References: <587dc9a8-b974-e222-95b4-93c2a8f2aba2@imgtec.com>
        <20170926.103400.1009342814128022820.davem@davemloft.net>
        <71740323.RRBhnhefTi@np-p-burton>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: matt.redfearn@imgtec.com, netdev@vger.kernel.org,
        alexandre.torgue@st.com, peppe.cavallaro@st.com,
        linux-kernel@vger.kernel.org, linux-mips@linux-mips.org,
        james.hogan@imgtec.com
To: paul.burton@imgtec.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <71740323.RRBhnhefTi@np-p-burton>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Paul Burton <paul.burton@imgtec.com>
Date: Tue, 26 Sep 2017 11:48:19 -0700

>> The device writes into only the bytes it was given access to, which
>> starts at the DMA address.
> 
> OK - still fine but *only* if we don't write to anything that happens to be 
> part of the cache lines that are only partially covered by the DMA mapping & 
> make them dirty. If we do then any writeback of those lines will clobber data 
> the device wrote, and any invalidation of them will discard data the CPU 
> wrote.
> 
> How would you have us ensure that such writes don't occur?
> 
> This really does not feel to me like something to leave up to drivers without 
> any means of checking or enforcing correctness. The requirement to align DMA 
> mappings at cache-line boundaries, as outlined in Documentation/DMA-API.txt, 
> allows this to be enforced. If you want to ignore this requirement then there 
> is no clear way to verify that we aren't writing to cache lines involved in a 
> DMA transfer whilst the transfer is occurring, and no sane way to handle those 
> cache lines if we do.

The memory immediately before skb->data and immediately after
skb->data+skb->len will not be accessed.  This is guaranteed.

I will request something exactly one more time to give you the benfit
of the doubt that you want to show me why this is _really_ a problem
and not a problem only in theory.

Please show me an exact sequence, with current code, in a current driver
that uses the DMA API properly, where corruption really can occur.

The new restriction is absolutely not reasonable for this use case.
It it furthermore impractical to require the 200+ drivers the use this
technique to allocate and map networking buffers to abide by this new
rule.  Many platforms with even worse cache problems that MIPS handle
this just fine.

Thank you.
