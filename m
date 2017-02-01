From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 13/17] net: stmmac: Implement NAPI for TX
Date: Tue, 31 Jan 2017 23:12:25 -0500 (EST)
Message-ID: <20170131.231225.59679013563845652.davem@davemloft.net>
References: <20170131091152.13842-1-clabbe.montjoie@gmail.com>
        <20170131091152.13842-14-clabbe.montjoie@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: peppe.cavallaro@st.com, alexandre.torgue@st.com,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: clabbe.montjoie@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170131091152.13842-14-clabbe.montjoie@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Corentin Labbe <clabbe.montjoie@gmail.com>
Date: Tue, 31 Jan 2017 10:11:48 +0100

> The stmmac driver run TX completion under NAPI but without checking
> the work done by the TX completion function.

The current behavior is correct and completely intentional.

A driver should _never_ account TX work to the NAPI poll budget.

This is because TX liberation is orders of magnitude cheaper than
receiving a packet, and such SKB freeing makes more SKBs available
for RX processing.

Therefore, TX work should never count against the NAPI budget.

Please do not fix something which is not broken.
