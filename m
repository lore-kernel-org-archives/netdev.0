From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH] net: sh_eth: avoid NULL pointer dereference in ring setup
Date: Wed, 2 Mar 2016 19:47:05 +0300
Message-ID: <56D71909.2020503@cogentembedded.com>
References: <1456932370-4143-1-git-send-email-wsa@the-dreams.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Simon Horman <horms@verge.net.au>,
	linux-renesas-soc@vger.kernel.org
To: Wolfram Sang <wsa@the-dreams.de>, netdev@vger.kernel.org
Return-path: <linux-renesas-soc-owner@vger.kernel.org>
In-Reply-To: <1456932370-4143-1-git-send-email-wsa@the-dreams.de>
Sender: linux-renesas-soc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello.

On 03/02/2016 06:26 PM, Wolfram Sang wrote:

> From: Wolfram Sang <wsa+renesas@sang-engineering.com>
>
> When allocating an skb fails, rxdesc is still NULL (or the previous ring
> index on further iterations of the loop). However, this pointer is
> dereferenced after the loop.

    This is intended. What we seem to actually need is a NULL check before 
that dereference.

> So, make sure rxdesc is updated immediately
> at the beginning of the loop.

    No, this seems wrong. We don't want an unfilled descriptor to be marked as 
last, we still need the previous one marked as last. Actually, 'rxdesc' 
shouldn't be "advanced" even before the second *break* as it is now.

> Reported-by: coverity (CID 1056464)
> Signed-off-by: Wolfram Sang <wsa+renesas@sang-engineering.com>

    Will you respin or should I?

MBR, Sergei
