From: Randy Dunlap <randy.dunlap@oracle.com>
Subject: Re: [PATCH NEXT] netxen: fix CONFIG_INET=n build
Date: Tue, 28 Jul 2009 12:23:52 -0700
Message-ID: <20090728122352.6d4a2b05.randy.dunlap@oracle.com>
References: <1248808203-9578-1-git-send-email-dhananjay@netxen.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, linux-next@vger.kernel.org
To: Dhananjay Phadke <dhananjay@netxen.com>
Return-path: <linux-next-owner@vger.kernel.org>
In-Reply-To: <1248808203-9578-1-git-send-email-dhananjay@netxen.com>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 28 Jul 2009 12:10:03 -0700 Dhananjay Phadke wrote:

> Wrap dest IP hashing code with #ifdef CONFIG_INET,
> this feature makes no sense without INET, but other
> driver can still work.
> 
> Signed-off-by: Dhananjay Phadke <dhananjay@netxen.com>

Acked-by: Randy Dunlap <randy.dunlap@oracle.com>

Thanks.

> ---
>  drivers/net/netxen/netxen_nic_main.c |    7 +++++++
>  1 files changed, 7 insertions(+), 0 deletions(-)
> 
> diff --git a/drivers/net/netxen/netxen_nic_main.c b/drivers/net/netxen/netxen_nic_main.c
> index 2bbefa6..40549a0 100644
> --- a/drivers/net/netxen/netxen_nic_main.c
> +++ b/drivers/net/netxen/netxen_nic_main.c
> @@ -1875,6 +1875,8 @@ static void netxen_nic_poll_controller(struct net_device *netdev)
>  }
>  #endif
>  
> +#ifdef CONFIG_INET
> +
>  #define is_netxen_netdev(dev) (dev->netdev_ops == &netxen_netdev_ops)
>  
>  static int
> @@ -1993,6 +1995,7 @@ static struct notifier_block	netxen_netdev_cb = {
>  static struct notifier_block netxen_inetaddr_cb = {
>  	.notifier_call = netxen_inetaddr_event,
>  };
> +#endif
>  
>  static struct pci_driver netxen_driver = {
>  	.name = netxen_nic_driver_name,
> @@ -2012,8 +2015,10 @@ static int __init netxen_init_module(void)
>  	if ((netxen_workq = create_singlethread_workqueue("netxen")) == NULL)
>  		return -ENOMEM;
>  
> +#ifdef CONFIG_INET
>  	register_netdevice_notifier(&netxen_netdev_cb);
>  	register_inetaddr_notifier(&netxen_inetaddr_cb);
> +#endif
>  
>  	return pci_register_driver(&netxen_driver);
>  }
> @@ -2024,8 +2029,10 @@ static void __exit netxen_exit_module(void)
>  {
>  	pci_unregister_driver(&netxen_driver);
>  
> +#ifdef CONFIG_INET
>  	unregister_inetaddr_notifier(&netxen_inetaddr_cb);
>  	unregister_netdevice_notifier(&netxen_netdev_cb);
> +#endif
>  	destroy_workqueue(netxen_workq);
>  }
>  
> -- 
> 1.6.0.2
> 


---
~Randy
LPC 2009, Sept. 23-25, Portland, Oregon
http://linuxplumbersconf.org/2009/
