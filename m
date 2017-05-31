From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] isdn: Fix a sleep-in-atomic bug
Date: Wed, 31 May 2017 14:38:46 -0400 (EDT)
Message-ID: <20170531.143846.1683078095046995517.davem@davemloft.net>
References: <1496194811-32297-1-git-send-email-baijiaju1990@163.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: isdn@linux-pingi.de, geliangtang@gmail.com, keescook@chromium.org,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: baijiaju1990@163.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1496194811-32297-1-git-send-email-baijiaju1990@163.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Jia-Ju Bai <baijiaju1990@163.com>
Date: Wed, 31 May 2017 09:40:11 +0800

> The driver may sleep under a spin lock, the function call path is:
> isdn_ppp_mp_receive (acquire the lock)
>   isdn_ppp_mp_reassembly
>     isdn_ppp_push_higher
>       isdn_ppp_decompress
>         isdn_ppp_ccp_reset_trans
>           isdn_ppp_ccp_reset_alloc_state
>             kzalloc(GFP_KERNEL) --> may sleep
> 
> To fixed it, the "GFP_KERNEL" is replaced with "GFP_ATOMIC".
> 
> Signed-off-by: Jia-Ju Bai <baijiaju1990@163.com>

Applied.
