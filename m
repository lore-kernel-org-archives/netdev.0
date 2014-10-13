From: Daniel Borkmann <dborkman@redhat.com>
Subject: Re: [PATCH] ipv6: notify userspace when we added or changed an ipv6
 token
Date: Mon, 13 Oct 2014 11:46:02 +0200
Message-ID: <543B9F5A.8070909@redhat.com>
References: <1412950112-15593-1-git-send-email-lkundrak@v3.sk>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>
To: Lubomir Rintel <lkundrak@v3.sk>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1412950112-15593-1-git-send-email-lkundrak@v3.sk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 10/10/2014 04:08 PM, Lubomir Rintel wrote:
> NetworkManager might want to know that it changed when the router advertisement
> arrives.
>
> Signed-off-by: Lubomir Rintel <lkundrak@v3.sk>
> Cc: Hannes Frederic Sowa <hannes@stressinduktion.org>
> Cc: Daniel Borkmann <dborkman@redhat.com>
> ---
>   net/ipv6/addrconf.c | 1 +
>   1 file changed, 1 insertion(+)
>
> diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
> index 3e118df..3d11390 100644
> --- a/net/ipv6/addrconf.c
> +++ b/net/ipv6/addrconf.c
> @@ -4528,6 +4528,7 @@ static int inet6_set_iftoken(struct inet6_dev *idev, struct in6_addr *token)
>   	}
>
>   	write_unlock_bh(&idev->lock);
> +	netdev_state_change(dev);

I'm wondering why netdev_state_change()? You are probably
only after the netlink notification that is being invoked,
i.e. rtmsg_ifinfo(RTM_NEWLINK, ...), and don't strictly want
to call the device notifier chain.

Perhaps it might be better to define a new RTM_SETTOKEN, and
just call inet6_ifinfo_notify(RTM_SETTOKEN, idev) as this is
only idev specific anyway?

>   	addrconf_verify_rtnl();
>   	return 0;
>   }
>
