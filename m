From: Randy Dunlap <randy.dunlap@oracle.com>
Subject: Re: [PATCH -next] bridge: fix build for CONFIG_SYSFS disabled
Date: Mon, 17 May 2010 11:01:12 -0700
Message-ID: <4BF18468.5010005@oracle.com>
References: <20100517163521.649526d0.sfr@canb.auug.org.au> <20100517091756.e232bdc2.randy.dunlap@oracle.com> <20100517105654.2451e61f@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Stephen Rothwell <sfr@canb.auug.org.au>,
	linux-next@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>,
	netdev@vger.kernel.org, davem@davemloft.net
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <linux-next-owner@vger.kernel.org>
In-Reply-To: <20100517105654.2451e61f@nehalam>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 05/17/10 10:56, Stephen Hemminger wrote:
> On Mon, 17 May 2010 09:17:56 -0700
> Randy Dunlap <randy.dunlap@oracle.com> wrote:
> 
>> From: Randy Dunlap <randy.dunlap@oracle.com>
>>
>> Fix build when CONFIG_SYSFS is not enabled:
>>
>> net/bridge/br_if.c:136: error: 'struct net_bridge_port' has no member named 'sysfs_name'
>>
>> Signed-off-by: Randy Dunlap <randy.dunlap@oracle.com>
>> ---
>>  net/bridge/br_if.c |    2 ++
>>  1 file changed, 2 insertions(+)
>>
>> --- linux-next-20100517.orig/net/bridge/br_if.c
>> +++ linux-next-20100517/net/bridge/br_if.c
>> @@ -133,7 +133,9 @@ static void del_nbp(struct net_bridge_po
>>  	struct net_bridge *br = p->br;
>>  	struct net_device *dev = p->dev;
>>  
>> +#ifdef CONFIG_SYSFS
>>  	sysfs_remove_link(br->ifobj, p->sysfs_name);
>> +#endif
>>  
>>  	dev_set_promiscuity(dev, -1);
>>  
> 
> I don't like peppering code with #ifdef like this.

Thanks.  I didn't like it either.

> Turns out that in this place sysfs_name is always the same
> as the device name so instead:
> 
> 
> --- a/net/bridge/br_if.c	2010-05-17 10:40:49.808031840 -0700
> +++ b/net/bridge/br_if.c	2010-05-17 10:49:47.767669246 -0700
> @@ -133,7 +133,7 @@ static void del_nbp(struct net_bridge_po
>  	struct net_bridge *br = p->br;
>  	struct net_device *dev = p->dev;
>  
> -	sysfs_remove_link(br->ifobj, p->sysfs_name);
> +	sysfs_remove_link(br->ifobj, p->dev->name);
>  
>  	dev_set_promiscuity(dev, -1);
>  
> 
> 


-- 
~Randy
*** Remember to use Documentation/SubmitChecklist when testing your code ***
