From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] bridge: Allow set bridge ageing time when
 switchdev disabled
Date: Wed, 30 Mar 2016 15:40:43 -0400 (EDT)
Message-ID: <20160330.154043.649305811904515416.davem@davemloft.net>
References: <1459248488-25621-1-git-send-email-yanhaishuang@cmss.chinamobile.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, bridge@lists.linux-foundation.org,
	linux-kernel@vger.kernel.org
To: yanhaishuang@cmss.chinamobile.com
Return-path: <bridge-bounces@lists.linux-foundation.org>
In-Reply-To: <1459248488-25621-1-git-send-email-yanhaishuang@cmss.chinamobile.com>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/bridge>,
	<mailto:bridge-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/bridge/>
List-Post: <mailto:bridge@lists.linux-foundation.org>
List-Help: <mailto:bridge-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/bridge>,
	<mailto:bridge-request@lists.linux-foundation.org?subject=subscribe>
Sender: bridge-bounces@lists.linux-foundation.org
Errors-To: bridge-bounces@lists.linux-foundation.org
List-Id: netdev.vger.kernel.org

From: Haishuang Yan <yanhaishuang@cmss.chinamobile.com>
Date: Tue, 29 Mar 2016 18:48:08 +0800

> When NET_SWITCHDEV=n, switchdev_port_attr_set will return -EOPNOTSUPP,
> we should ignore this error code and continue to set the ageing time.
> 
> Signed-off-by: Haishuang Yan <yanhaishuang@cmss.chinamobile.com>

Applied and queued up for -stable, thanks.

> @@ -582,7 +582,7 @@ int br_set_ageing_time(struct net_bridge *br, u32 ageing_time)
>  	int err;
>  
>  	err = switchdev_port_attr_set(br->dev, &attr);
> -	if (err)
> +	if (err && err != -EOPNOTSUPP)
>  		return err;
>  
>  	br->ageing_time = t;

This is at least the 5th time I've had to apply a bug fix exactly like
this one.

If this doesn't convince everyone that this whole -EOPNOTSUPP
mechanism is extremely error prone, I don't know what will.

There should be only one or two strictly controlled locations that
reinterpret the return value from all of these routines that have this
special way of signalling lack of switchdev support via -EOPNOTSUPP.

It can't be spread all over the place like this, it simply does NOT work.
