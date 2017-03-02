From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v4] net: don't call strlen() on the user buffer in
 packet_bind_spkt()
Date: Wed, 01 Mar 2017 20:57:52 -0800 (PST)
Message-ID: <20170301.205752.2006881054868352173.davem@davemloft.net>
References: <20170301115720.99985-1-glider@google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dvyukov@google.com, kcc@google.com, edumazet@google.com,
        linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: glider@google.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170301115720.99985-1-glider@google.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Alexander Potapenko <glider@google.com>
Date: Wed,  1 Mar 2017 12:57:20 +0100

> KMSAN (KernelMemorySanitizer, a new error detection tool) reports use of
> uninitialized memory in packet_bind_spkt():
 ...
> This happens because addr.sa_data copied from the userspace is not
> zero-terminated, and copying it with strlcpy() in packet_bind_spkt()
> results in calling strlen() on the kernel copy of that non-terminated
> buffer.
> 
> Signed-off-by: Alexander Potapenko <glider@google.com>
> ---
> Changes since v3:
>  - addressed comments by Eric Dumazet (avoid using constants,
>    use memcpy() instead of strncpy())

Applied and queued up for -stable.
