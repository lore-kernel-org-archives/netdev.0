From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: stmmac: Meet alignment requirements for DMA
Date: Fri, 22 Sep 2017 18:26:39 -0700 (PDT)
Message-ID: <20170922.182639.272534775457081015.davem@davemloft.net>
References: <1506078833-14002-1-git-send-email-matt.redfearn@imgtec.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, alexandre.torgue@st.com,
        peppe.cavallaro@st.com, linux-kernel@vger.kernel.org
To: matt.redfearn@imgtec.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1506078833-14002-1-git-send-email-matt.redfearn@imgtec.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Matt Redfearn <matt.redfearn@imgtec.com>
Date: Fri, 22 Sep 2017 12:13:53 +0100

> According to Documentation/DMA-API.txt:
>  Warnings:  Memory coherency operates at a granularity called the cache
>  line width.  In order for memory mapped by this API to operate
>  correctly, the mapped region must begin exactly on a cache line
>  boundary and end exactly on one (to prevent two separately mapped
>  regions from sharing a single cache line).  Since the cache line size
>  may not be known at compile time, the API will not enforce this
>  requirement.  Therefore, it is recommended that driver writers who
>  don't take special care to determine the cache line size at run time
>  only map virtual regions that begin and end on page boundaries (which
>  are guaranteed also to be cache line boundaries).

This is rediculious.  You're misreading what this document is trying
to explain.

As long as you use the dma_{map,unamp}_single() and sync to/from
deivce interfaces properly, the cacheline issues will be handled properly
and the cpu and the device will see proper uptodate memory contents.

It is completely rediculious to require every driver to stash away two
sets of pointer for every packet, and to DMA map the headroom of the SKB
which is wasteful.

I'm not applying this, fix this problem properly, thanks.
