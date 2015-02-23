From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH RESEND] net: compat: Ignore MSG_CMSG_COMPAT in
 compat_sys_{send,recv}msg
Date: Mon, 23 Feb 2015 17:22:32 -0500 (EST)
Message-ID: <20150223.172232.1309715810003183775.davem@davemloft.net>
References: <1424715176-22369-1-git-send-email-catalin.marinas@arm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	will.deacon@arm.com, luto@amacapital.net
To: catalin.marinas@arm.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1424715176-22369-1-git-send-email-catalin.marinas@arm.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Catalin Marinas <catalin.marinas@arm.com>
Date: Mon, 23 Feb 2015 18:12:56 +0000

> With commit a7526eb5d06b (net: Unbreak compat_sys_{send,recv}msg), the
> MSG_CMSG_COMPAT flag is blocked at the compat syscall entry points,
> changing the kernel compat behaviour from the one before the commit it
> was trying to fix (1be374a0518a, net: Block MSG_CMSG_COMPAT in
> send(m)msg and recv(m)msg).
> 
> On 32-bit kernels (!CONFIG_COMPAT), MSG_CMSG_COMPAT is 0 and the native
> 32-bit sys_sendmsg() allows flag 0x80000000 to be set (it is ignored by
> the kernel). However, on a 64-bit kernel, the compat ABI is different
> with commit a7526eb5d06b.
> 
> This patch changes the compat_sys_{send,recv}msg behaviour to the one
> prior to commit 1be374a0518a.
> 
> The problem was found running 32-bit LTP (sendmsg01) binary on an arm64
> kernel. Arguably, LTP should not pass 0xffffffff as flags to sendmsg()
> but the general rule is not to break user ABI (even when the user
> behaviour is not entirely sane).
> 
> Fixes: a7526eb5d06b (net: Unbreak compat_sys_{send,recv}msg)
> Signed-off-by: Catalin Marinas <catalin.marinas@arm.com>

Applied and queued up for -stable, thanks.
