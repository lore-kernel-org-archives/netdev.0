From: John Ronciak <john.ronciak@gmail.com>
Subject: Re: [PATCH 3/8] netpoll: e1000 netpoll tweak
Date: Fri, 12 Aug 2005 12:02:03 -0700
Message-ID: <56a8daef0508121202172bcd17__24464.596695225$1123873502$gmane$org@mail.gmail.com>
References: <3.502409567@selenic.com> <4.502409567@selenic.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 8bit
Cc: Andrew Morton <akpm@osdl.com>, "David S. Miller" <davem@davemloft.net>,
        ak@suse.de, Jeff Moyer <jmoyer@redhat.com>, netdev@oss.sgi.com,
        linux-kernel@vger.kernel.org, mingo@elte.hu, john.ronciak@intel.com,
        rostedt@goodmis.org
Return-path: <netdev-bounce@oss.sgi.com>
To: Matt Mackall <mpm@selenic.com>
In-Reply-To: <4.502409567@selenic.com>
Content-Disposition: inline
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Sorry this reply was to go to the whole list but only made it to Matt.

The e1000_intr() routine already calls e1000_clean_tx_irq().  So
what's the point of this patch?  Am I missing something?

On 8/11/05, Matt Mackall <mpm@selenic.com> wrote:
> Suggested by Steven Rostedt, matches his patch included in e100.
> 
> Signed-off-by: Matt Mackall <mpm@selenic.com>
> 
> Index: l/drivers/net/e1000/e1000_main.c
> ===================================================================
> --- l.orig/drivers/net/e1000/e1000_main.c       2005-08-06 17:36:32.000000000 -0500
> +++ l/drivers/net/e1000/e1000_main.c    2005-08-06 17:55:01.000000000 -0500
> @@ -3789,6 +3789,7 @@ e1000_netpoll(struct net_device *netdev)
>         struct e1000_adapter *adapter = netdev_priv(netdev);
>         disable_irq(adapter->pdev->irq);
>         e1000_intr(adapter->pdev->irq, netdev, NULL);
> +       e1000_clean_tx_irq(adapter);
>         enable_irq(adapter->pdev->irq);
>  }
>  #endif
> 
> 


-- 
Cheers,
John
