From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2] sctp: sctp_sendmsg: Don't initialize default_sinfo
Date: Thu, 12 May 2011 17:06:03 -0400 (EDT)
Message-ID: <20110512.170603.549349521517995900.davem@davemloft.net>
References: <cover.1305227620.git.joe@perches.com>
	<a4e846ed62d7f9222dc9b09ca00b5356a1eb9b73.1305227620.git.joe@perches.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: vladislav.yasevich@hp.com, sri@us.ibm.com,
	linux-sctp@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: joe@perches.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <a4e846ed62d7f9222dc9b09ca00b5356a1eb9b73.1305227620.git.joe@perches.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Joe Perches <joe@perches.com>
Date: Thu, 12 May 2011 12:19:09 -0700

> This variable only needs initialization when cmsgs.info
> is NULL.
> 
> Don't use memset, just initialize every struct member.
> 
> Signed-off-by: Joe Perches <joe@perches.com>

I don't think you do this, this structure has padding holes on pretty
much every architecture.

It starts with 3 u16's, then there is a u32, so there is a 2-byte
piece of padding after the 3rd u16.

Can you prove that these uninitialized portions never make it to
userspace?  If you can, that proof belongs in the commit message.

I think it's too risky.
