From: Matt Mackall <mpm@selenic.com>
Subject: Re: [PATCH 3/8] netpoll: e1000 netpoll tweak
Date: Fri, 12 Aug 2005 12:17:52 -0700
Message-ID: <20050812191752.GI12284__13481.6319136464$1123874494$gmane$org@waste.org>
References: <3.502409567@selenic.com> <4.502409567@selenic.com> <56a8daef0508121202172bcd17@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andrew Morton <akpm@osdl.org>, "David S. Miller" <davem@davemloft.net>,
        ak@suse.de, Jeff Moyer <jmoyer@redhat.com>, netdev@oss.sgi.com,
        linux-kernel@vger.kernel.org, mingo@elte.hu, john.ronciak@intel.com,
        rostedt@goodmis.org
Return-path: <netdev-bounce@oss.sgi.com>
To: John Ronciak <john.ronciak@gmail.com>
Content-Disposition: inline
In-Reply-To: <56a8daef0508121202172bcd17@mail.gmail.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

[corrected akpm's address]

On Fri, Aug 12, 2005 at 12:02:03PM -0700, John Ronciak wrote:
> Sorry this reply was to go to the whole list but only made it to Matt.
> 
> The e1000_intr() routine already calls e1000_clean_tx_irq().  So
> what's the point of this patch?  Am I missing something?

Here is Steven's original analysis:

http://lkml.org/lkml/2005/8/5/116

It looked plausible, but I didn't dig much deeper.

> > Index: l/drivers/net/e1000/e1000_main.c
> > ===================================================================
> > --- l.orig/drivers/net/e1000/e1000_main.c       2005-08-06 17:36:32.000000000 -0500
> > +++ l/drivers/net/e1000/e1000_main.c    2005-08-06 17:55:01.000000000 -0500
> > @@ -3789,6 +3789,7 @@ e1000_netpoll(struct net_device *netdev)
> >         struct e1000_adapter *adapter = netdev_priv(netdev);
> >         disable_irq(adapter->pdev->irq);
> >         e1000_intr(adapter->pdev->irq, netdev, NULL);
> > +       e1000_clean_tx_irq(adapter);
> >         enable_irq(adapter->pdev->irq);
> >  }
> >  #endif

-- 
Mathematics is the supreme nostalgia of our time.
