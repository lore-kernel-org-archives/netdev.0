From: jjs <jjs@tmsusa.com>
Subject: Re: [PATCH 2.5.70] Tun device encapsulation
Date: Wed, 04 Jun 2003 15:46:44 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <3EDE76D4.8070001@tmsusa.com>
References: <20030604115236.309a173d.akpm@digeo.com>	<20030604212528.GA24515@conectiva.com.br> <20030604154022.0ef344ff.shemminger@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Arnaldo Carvalho de Melo <acme@conectiva.com.br>,
   "David S. Miller" <davem@redhat.com>, Jeff Garzik <jgarzik@pobox.com>,
   akpm@digeo.com, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Stephen Hemminger <shemminger@osdl.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

I'll be happy to test it out later -

Thanks,

Joe

Stephen Hemminger wrote:

>Tun device was encapsulating the net_device in a private structure then doing:
>	unregister_netdev(&tun->dev);
>	kfree(tun);
>	rtnl_unlock();
>
>This breaks with the delayed cleanup now in the network core.
>Moving the kfree outside of the rtnl_unlock will fix it.
>
>Builds, but not sure how to use TUN to test it.
>
>As part of later refcounting changes, I do have a more complex change
>that uses the same encapsulation as ethernet and other
>devices.  Will save it for later.
>
>diff -Nru a/drivers/net/tun.c b/drivers/net/tun.c
>--- a/drivers/net/tun.c	Wed Jun  4 15:38:44 2003
>+++ b/drivers/net/tun.c	Wed Jun  4 15:38:44 2003
>@@ -551,10 +551,12 @@
> 	if (!(tun->flags & TUN_PERSIST)) {
> 		dev_close(&tun->dev);
> 		unregister_netdevice(&tun->dev);
>-		kfree(tun);
> 	}
> 
> 	rtnl_unlock();
>+
>+	if (!(tun->flags & TUN_PERSIST)) 
>+		kfree(tun);
> 	return 0;
> }
> 
>
>  
>
