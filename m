From: "Dmitry V. Levin" <ldv@altlinux.org>
Subject: Re: [RFC PATCH] uapi: fix linux/packet_diag.h userspace compilation error
Date: Tue, 7 Mar 2017 23:28:02 +0300
Message-ID: <20170307202802.GA19323@altlinux.org>
References: <20170228013930.GA28056@altlinux.org> <20170307.121649.968411437349940435.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Pavel Emelyanov <xemul@virtuozzo.com>, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20170307.121649.968411437349940435.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Mar 07, 2017 at 12:16:49PM -0800, David Miller wrote:
> From: "Dmitry V. Levin" <ldv@altlinux.org>
> Date: Tue, 28 Feb 2017 04:39:30 +0300
> 
> > Replace MAX_ADDR_LEN with its numeric value to fix the following
> > linux/packet_diag.h userspace compilation error:
> > 
> > /usr/include/linux/packet_diag.h:67:17: error: 'MAX_ADDR_LEN' undeclared here (not in a function)
> >   __u8 pdmc_addr[MAX_ADDR_LEN];
> > 
> > This is not the first case in the UAPI where the numeric value
> > of MAX_ADDR_LEN is used, uapi/linux/if_link.h already does the same,
> > and there are no UAPI headers besides these two that use MAX_ADDR_LEN.
> > 
> > The alternative fix would be to include <linux/netdevice.h> which
> > pulls in other headers and a lot of definitions with them.
> > 
> > Signed-off-by: Dmitry V. Levin <ldv@altlinux.org>
> 
> If if_link.h includes netdevice.h properly, let's try to do the same here as well.

Sorry if my words weren't clear enough: no, if_link.h doesn't include
netdevice.h, it uses the _numeric_ value instead:

$ grep MAX_ADDR_LEN include/uapi/linux/if_link.h 
	__u8 mac[32]; /* MAX_ADDR_LEN */


-- 
ldv
