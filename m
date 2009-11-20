From: Stephen Hemminger <shemminger-ZtmgI6mnKB3QT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH] RDMA/addr: Use appropriate locking with
 for_each_netdev()
Date: Thu, 19 Nov 2009 21:40:47 -0800
Message-ID: <20091119214047.1a966c79@nehalam>
References: <4AF8EBA4.2070102@gmail.com>
	<D5E1FB213939498DBFFEB5A3B83C08AD@amr.corp.intel.com>
	<adaocn8x6j7.fsf@roland-alpha.cisco.com>
	<8C10E584257A46DB9A0AD193520CF4A7@amr.corp.intel.com>
	<4B0628E0.6000404@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Sean Hefty <sean.hefty-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
	"'Roland Dreier'" <rdreier-FYB4Gu1CFyUAvxtiuMwx3w@public.gmane.org>,
	"David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	Linux Netdev List <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Roland Dreier <rolandd-FYB4Gu1CFyUAvxtiuMwx3w@public.gmane.org>,
	Hal Rosenstock <hal.rosenstock-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	linux-rdma <linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Eric Dumazet <eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <4B0628E0.6000404-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Fri, 20 Nov 2009 06:28:00 +0100
Eric Dumazet <eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> wrote:

> +		read_lock(&dev_base_lock);
>  		for_each_netdev(&init_net, dev) {
>  			if (ipv6_chk_addr(&init_net,
>  					  &((struct sockaddr_in6 *) addr)->sin6_addr,
> @@ -139,6 +140,7 @@ int rdma_translate_ip(struct sockaddr *addr, struct rdma_dev_addr *dev_addr)
>  				break;
>  			}
>  		}
> +		read_unlock(&dev_base_lock);

what about for_each_netdev_rcu() here instead...



-- 
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
