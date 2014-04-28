From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH V1 net-next 1/1] hyperv: Properly handle checksum offload
Date: Mon, 28 Apr 2014 13:23:47 -0400 (EDT)
Message-ID: <20140428.132347.778081265367223580.davem@davemloft.net>
References: <1398484523-27596-1-git-send-email-kys@microsoft.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: olaf@aepfle.de, netdev@vger.kernel.org, jasowang@redhat.com,
 linux-kernel@vger.kernel.org, apw@canonical.com, devel@linuxdriverproject.org,
 stable@kernel.org
To: kys@microsoft.com
Return-path: <driverdev-devel-bounces@linuxdriverproject.org>
In-Reply-To: <1398484523-27596-1-git-send-email-kys@microsoft.com>
List-Unsubscribe: <http://driverdev.linuxdriverproject.org/mailman/options/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=unsubscribe>
List-Archive: <http://driverdev.linuxdriverproject.org/pipermail/driverdev-devel>
List-Post: <mailto:driverdev-devel@linuxdriverproject.org>
List-Help: <mailto:driverdev-devel-request@linuxdriverproject.org?subject=help>
List-Subscribe: <http://driverdev.linuxdriverproject.org/mailman/listinfo/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=subscribe>
Errors-To: driverdev-devel-bounces@linuxdriverproject.org
Sender: driverdev-devel-bounces@linuxdriverproject.org
List-Id: netdev.vger.kernel.org

From: "K. Y. Srinivasan" <kys@microsoft.com>
Date: Fri, 25 Apr 2014 20:55:23 -0700

> @@ -467,6 +467,9 @@ static int netvsc_start_xmit(struct sk_buff *skb, struct net_device *net)
>  	if (skb_is_gso(skb))
>  		goto do_lso;
>  
> +	if (skb->ip_summed != CHECKSUM_PARTIAL)
> +		goto do_send;
> +

There are many possible values of ip_summed, why would you go to do_send if
for example it was set to CHECKSUM_COMPLETE?

I think you are just rushing this change, take your time and implement the
fix properly.

For example, if you only expect two possible values here (CHECKSUM_PARTIAL
and something else), design your test so that it only allows those two
values and therefore you'll be documenting this invariant.
