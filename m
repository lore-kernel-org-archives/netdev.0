From: Andi Kleen <ak@suse.de>
Subject: Re: [PATCH]: was Re: LLTX and netif_stop_queue
Date: Thu, 20 Jan 2005 04:14:23 +0100
Message-ID: <20050120031423.GC30088@wotan.suse.de>
References: <1104764660.1048.578.camel@jzny.localdomain> <52brc68q05.fsf@topspin.com> <5cac192f05010308414a25b548@mail.gmail.com> <527jmu8nbw.fsf@topspin.com> <5cac192f0501030907c755135@mail.gmail.com> <20050103171227.GD7370@esmail.cup.hp.com> <1104812294.1085.53.camel@jzny.localdomain> <20050119144711.3fdd3d93.davem@davemloft.net> <20050119151853.259de49a@dxpl.pdx.osdl.net> <20050119164640.6c67bdfa.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Stephen Hemminger <shemminger@osdl.org>, hadi@cyberus.ca, iod00d@hp.com,
        eric.lemoine@gmail.com, roland@topspin.com, netdev@oss.sgi.com,
        ak@suse.de, openib-general@openib.org, kaber@trash.net
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
Content-Disposition: inline
In-Reply-To: <20050119164640.6c67bdfa.davem@davemloft.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, Jan 19, 2005 at 04:46:40PM -0800, David S. Miller wrote:
> Ok, here is what something like this might look like.
> 
> In summary:
> 
> 1) dev->xmit_lock is now IRQ disabling instead of BH disabling
> 2) Drivers can use dev->xmit_lock in place of their private
>    driver_priv->tx_lock and this is effectively the same gain
>    LLTX gave drivers sans the race condition which started this
>    thread.
> 3) NETDEV_TX_LOCKED is gone
> 4) LLTX stays, but this means that the driver's TX routine is
>    %100 lockless.  It is only to be used by loopback and other
>    queueless software devices such as tunnels.

Looks good to me and much cleaner than what I initially did.
Thanks.

-Andi
