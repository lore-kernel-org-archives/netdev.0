From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [openib-general] Re: LLTX and netif_stop_queue
Date: Thu, 20 Jan 2005 01:47:53 +0100
Message-ID: <20050120004753.GB2330@electric-eye.fr.zoreil.com>
References: <1104764660.1048.578.camel@jzny.localdomain> <52brc68q05.fsf@topspin.com> <5cac192f05010308414a25b548@mail.gmail.com> <527jmu8nbw.fsf@topspin.com> <5cac192f0501030907c755135@mail.gmail.com> <20050103171227.GD7370@esmail.cup.hp.com> <1104812294.1085.53.camel@jzny.localdomain> <20050119144711.3fdd3d93.davem@davemloft.net> <20050119151853.259de49a@dxpl.pdx.osdl.net> <20050119154132.68f0bb4f.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Stephen Hemminger <shemminger@osdl.org>, hadi@cyberus.ca, iod00d@hp.com,
        eric.lemoine@gmail.com, roland@topspin.com, netdev@oss.sgi.com,
        ak@suse.de, openib-general@openib.org, kaber@trash.net
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
Content-Disposition: inline
In-Reply-To: <20050119154132.68f0bb4f.davem@davemloft.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

David S. Miller <davem@davemloft.net> :
[...]
> Originally, dev->xmit_lock was added so that drivers that were SMP dumb
> could stay that way.  Thus preserving the guarentee that there would be
> only one active call into the dev->hard_start_xmit method across the
> entire system.  I don't think any of that is relevant any longer.  All
> of our network drivers are pretty clean in this regard.

(nit)

Almost all. I used the fact that dev->hard_start_xmit was issued in
a bh disabled context to exchange spinlock_irqsave for ordered ops
on ring indexes so as to sync hard_start_xmit and the irq handler in
the r8169 driver. It is a bit sick but Jon Mason reported it made a
noticeable difference to avoid the irqsave on its 4 way ppc64 and 
nobody complained about it.

--
Ueimor
