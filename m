From: Alex Badea <abadea@ixiacom.com>
Subject: Re: [xfrm_user] BUG: sleeping function called from invalid context
Date: Thu, 12 Aug 2010 16:13:12 +0300
Message-ID: <4C63F368.9050806@ixiacom.com>
References: <20100812125027.GA12982@nb-core2.darkstar.lan>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Luca Tettamanti <kronos.it@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20100812125027.GA12982@nb-core2.darkstar.lan>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

On 08/12/2010 03:50 PM, Luca Tettamanti wrote:
>  [<ffffffff8124d175>] udp_setsockopt+0x24/0x26
>  [<ffffffff811fd5c5>] sock_common_setsockopt+0xf/0x11
>  [<ffffffff811fb0a8>] sys_setsockopt+0x81/0xa2
>  [<ffffffff8100296b>] system_call_fastpath+0x16/0x1b
> 
> 
> xfrm_user_policy takes read_lock(&xfrm_km_lock) before calling
> xfrm_compile_policy (via km->compile_policy), which in turn calls
> xfrm_policy_alloc with GFP_KERNEL.

Since it's a setsockopt(), I suspect it was setting up per-socket bypass
policies.

Regards,
Alex
