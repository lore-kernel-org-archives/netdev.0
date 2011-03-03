From: Chris Wright <chrisw@sous-sol.org>
Subject: Re: [PATCH 2/2] netlink: kill eff_cap from struct netlink_skb_parms
Date: Thu, 3 Mar 2011 09:32:30 -0800
Message-ID: <20110303173230.GP4988@sequoia.sous-sol.org>
References: <4D6F6180.5030903@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: NetDev <netdev@vger.kernel.org>, dm-devel@redhat.com,
	"David S. Miller" <davem@davemloft.net>,
	Chris Wright <chrisw@sous-sol.org>,
	"linux-security-module@vger.kernel.org"
	<linux-security-module@vger.kernel.org>, drbd-dev@lists.linbit.com
To: Patrick McHardy <kaber@trash.net>
Return-path: <linux-security-module-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <4D6F6180.5030903@trash.net>
Sender: linux-security-module-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

* Patrick McHardy (kaber@trash.net) wrote:

> commit 8ff259625f0ab295fa085b0718eed13093813fbc
> Author: Patrick McHardy <kaber@trash.net>
> Date:   Thu Mar 3 10:17:31 2011 +0100
> 
>     netlink: kill eff_cap from struct netlink_skb_parms
>     
>     Netlink message processing in the kernel is synchronous these days,
>     capabilities can be checked directly in security_netlink_recv() from
>     the current process.
>     
>     Signed-off-by: Patrick McHardy <kaber@trash.net>

Thanks for doing that Patrick.  I looked at this earlier and thought
there was still an async path, but I guess that's just to another
userspace process.

BTW, I think you missed a couple connector based callers:

drivers/staging/pohmelfs/config.c:      if (!cap_raised(nsp->eff_cap, CAP_SYS_AD
drivers/video/uvesafb.c:        if (!cap_raised(nsp->eff_cap, CAP_SYS_ADMIN))

Fix those and:

Acked-by: Chris Wright <chrisw@sous-sol.org>

Ideally, we'd consolidate those into a variant of security_netlink_recv().
However the issue is with types.  Inside connector callback we only have
netlink_skb_params (seems inapproriate to cast back out to skb).

We could change the lsm hook to only pass nsp, but SELinux actually
cares about the netlink type.  Any ideas?
