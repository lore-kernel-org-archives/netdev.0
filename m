From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: force inlining of netif_tx_start/stop_queue,
 sock_hold, __sock_put
Date: Wed, 13 Apr 2016 22:43:04 -0400 (EDT)
Message-ID: <20160413.224304.1473128420144564230.davem@davemloft.net>
References: <1460130714-7779-1-git-send-email-dvlasenk@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	netfilter-devel@vger.kernel.org
To: dvlasenk@redhat.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1460130714-7779-1-git-send-email-dvlasenk@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Denys Vlasenko <dvlasenk@redhat.com>
Date: Fri,  8 Apr 2016 17:51:54 +0200

> Sometimes gcc mysteriously doesn't inline
> very small functions we expect to be inlined. See
>     https://gcc.gnu.org/bugzilla/show_bug.cgi?id=66122
> Arguably, gcc should do better, but gcc people aren't willing
> to invest time into it, asking to use __always_inline instead.
> 
> With this .config:
> http://busybox.net/~vda/kernel_config_OPTIMIZE_INLINING_and_Os,
> the following functions get deinlined many times.
  ...
> This patch fixes this via s/inline/__always_inline/.
> 
> Code size decrease after the patch is ~2.5k:
> 
>     text      data      bss       dec     hex filename
> 56719876  56364551 36196352 149280779 8e5d80b vmlinux_before
> 56717440  56364551 36196352 149278343 8e5ce87 vmlinux
> 
> Signed-off-by: Denys Vlasenko <dvlasenk@redhat.com>

Applied to net-next, thanks.
