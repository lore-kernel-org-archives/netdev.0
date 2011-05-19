From: Andy Gospodarek <andy@greyhouse.net>
Subject: Re: [V2 Patch net-next-2.6] netpoll: disable netpoll when enslave
	a device
Date: Thu, 19 May 2011 07:31:27 -0400
Message-ID: <20110519113127.GE21309@gospo.rdu.redhat.com>
References: <20110518105558.GA3203@hmsreliant.think-freely.org> <1305794393-20775-1-git-send-email-amwang@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, akpm@linux-foundation.org,
	Neil Horman <nhorman@redhat.com>,
	Jay Vosburgh <fubar@us.ibm.com>,
	"David S. Miller" <davem@davemloft.net>,
	Ian Campbell <ian.campbell@citrix.com>,
	"Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
	Josh Triplett <josh@joshtriplett.org>, netdev@vger.kernel.org
To: Amerigo Wang <amwang@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1305794393-20775-1-git-send-email-amwang@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, May 19, 2011 at 04:39:53PM +0800, Amerigo Wang wrote:
[...]
> diff --git a/include/linux/notifier.h b/include/linux/notifier.h
> index 621dfa1..3d82867 100644
> --- a/include/linux/notifier.h
> +++ b/include/linux/notifier.h
> @@ -211,6 +211,7 @@ static inline int notifier_to_errno(int ret)
>  #define NETDEV_UNREGISTER_BATCH 0x0011
>  #define NETDEV_BONDING_DESLAVE  0x0012
>  #define NETDEV_NOTIFY_PEERS	0x0013
> +#define NETDEV_ENSLAVE		0x0014
>  
>  #define SYS_DOWN	0x0001	/* Notify of system down */
>  #define SYS_RESTART	SYS_DOWN

Neil just noted the same concern I had -- the asymmetry between
NETDEV_ENSLAVE and NETDEV_BONDING_DESLAVE bothers me a bit.  I also
don't really like the followup patch that uses 'ENSLAVE' in the bridging
code when we typically use that language for bonding only.

What about changing NETDEV_BONDING_DESLAVE to NETDEV_RELEASE and create
NETDEV_JOIN instead of NETDEV_ENSLAVE?  I would prefer that or something
else that might use more generic language that could be applied to all
for stacked interfaces.
