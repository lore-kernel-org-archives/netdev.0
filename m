From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: stmmac: Meet alignment requirements for DMA
Date: Tue, 26 Sep 2017 21:53:21 -0700 (PDT)
Message-ID: <20170926.215321.424825014223425519.davem@davemloft.net>
References: <1752163.uYYNevmZpH@np-p-burton>
        <20170926.195244.506518182147628099.davem@davemloft.net>
        <2520219.WSsBr6LeCR@np-p-burton>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: matt.redfearn@imgtec.com, netdev@vger.kernel.org,
        alexandre.torgue@st.com, peppe.cavallaro@st.com,
        linux-kernel@vger.kernel.org, linux-mips@linux-mips.org,
        james.hogan@imgtec.com
To: paul.burton@imgtec.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <2520219.WSsBr6LeCR@np-p-burton>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Paul Burton <paul.burton@imgtec.com>
Date: Tue, 26 Sep 2017 21:30:56 -0700

> Nobody said that you are required to do anything, I suggested that
> it would be beneficial if you were to suggest a change to the
> documented DMA API such that it allows your usage where it currently
> does not.

Documentation is often wrong and it is here.  What 200+ drivers
actually do and depend upon trumps a simple text document.

The requirement is that the memory remains quiescent on the cpu side
while the device messes with it.  And that this quiescence requirement
may or may not be on a cache line basis.

There is absolutely no requirement that the buffers themselves are
cache line aligned.

In fact, receive buffers for networking are intentionally 2-byte
aligned in order for the ipv4 headers to be naturally 32-bit aligned.

Cache line aligning receive buffers will actually make some
architectures trap because of the bad alignment.

So see, this cache line alignment requirement is pure madness from
just about any perspective whatsoever.
