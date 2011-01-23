From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [RFC] ipv6: don't flush routes when setting loopback
	down
Date: Sun, 23 Jan 2011 11:21:29 -0800
Message-ID: <m1k4hv5sue.fsf@fess.ebiederm.org>
References: <20110122.145438.193725532.davem@davemloft.net>
	<901400353.32377.1295757672292.JavaMail.root@tahiti.vyatta.com>
	<20110122.214254.226765382.davem@davemloft.net>
	<20110123192416.73cd7521@s6510> <20110123192624.5cfe33d0@s6510>
	<20110123091531.GQ12837@1wt.eu> <20110123213444.70d0b0f1@s6510>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: jbohac@suse.cz, David Miller <davem@davemloft.net>,
        yoshfuji@linux-ipv6.org, netdev@vger.kernel.org, stable@kernel.org,
        stephen.hemminger@vyatta.com, maheshkelkar@gmail.com,
        brian.haley@hp.com, Willy Tarreau <w@1wt.eu>, lorenzo@google.com
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <stable-bounces@linux.kernel.org>
In-Reply-To: <20110123213444.70d0b0f1@s6510> (Stephen Hemminger's message of
	"Sun, 23 Jan 2011 21:34:44 +1100")
List-Unsubscribe: <http://linux.kernel.org/mailman/options/stable>,
	<mailto:stable-request@linux.kernel.org?subject=unsubscribe>
List-Archive: <http://linux.kernel.org/mailman/private/stable/>
List-Post: <mailto:stable@linux.kernel.org>
List-Help: <mailto:stable-request@linux.kernel.org?subject=help>
List-Subscribe: <http://linux.kernel.org/mailman/listinfo/stable>,
	<mailto:stable-request@linux.kernel.org?subject=subscribe>
Sender: stable-bounces@linux.kernel.org
Errors-To: stable-bounces@linux.kernel.org
List-Id: netdev.vger.kernel.org

Stephen Hemminger <shemminger@vyatta.com> writes:

> I think this fixes the issue with disable_ipv6

Somehow I doubt deleting the ipv6 state, and removing the per device
disable_ipv6 flag is going to be backwards compatible.

echo 0 > /proc/sys/net/ipv6/conf/disable_ipv6

Won't work.

What ever other good properties calling NETDEV_UNREGISTER for ipv6
devices may have.

Eric

> --- a/net/ipv6/addrconf.c	2011-01-23 20:30:25.897243002 +1100
> +++ b/net/ipv6/addrconf.c	2011-01-23 20:30:41.161243002 +1100
> @@ -4197,7 +4197,7 @@ static void dev_disable_change(struct in
>  		return;
>  
>  	if (idev->cnf.disable_ipv6)
> -		addrconf_notify(NULL, NETDEV_DOWN, idev->dev);
> +		addrconf_notify(NULL, NETDEV_UNREGISTER, idev->dev);
>  	else
>  		addrconf_notify(NULL, NETDEV_UP, idev->dev);
>  }
