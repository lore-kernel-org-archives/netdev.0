From: Haiyang Zhang <haiyangz@microsoft.com>
Subject: RE: [PATCH net-next,v2] Add support for netvsc build without
 CONFIG_SYSFS flag
Date: Thu, 8 May 2014 20:50:06 +0000
Message-ID: <b641d25465f44cae8c7c9a680a31594d@DFM-DB3MBX15-06.exchange.corp.microsoft.com>
References: <1399581693-25050-1-git-send-email-haiyangz@microsoft.com>
 <20140508.164458.157597820665207475.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "olaf@aepfle.de" <olaf@aepfle.de>,
 "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
 "jasowang@redhat.com" <jasowang@redhat.com>,
 "driverdev-devel@linuxdriverproject.org"
 <driverdev-devel@linuxdriverproject.org>,
 "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <driverdev-devel-bounces@linuxdriverproject.org>
In-Reply-To: <20140508.164458.157597820665207475.davem@davemloft.net>
Content-Language: en-US
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



> -----Original Message-----
> From: David Miller [mailto:davem@davemloft.net]
> Sent: Thursday, May 8, 2014 4:45 PM
> To: Haiyang Zhang
> Cc: netdev@vger.kernel.org; KY Srinivasan; olaf@aepfle.de;
> jasowang@redhat.com; linux-kernel@vger.kernel.org; driverdev-
> devel@linuxdriverproject.org
> Subject: Re: [PATCH net-next,v2] Add support for netvsc build without
> CONFIG_SYSFS flag
> 
> From: Haiyang Zhang <haiyangz@microsoft.com>
> Date: Thu,  8 May 2014 13:41:33 -0700
> 
> > +static inline void netvsc_record_rx_queue(struct sk_buff *skb,
> > +					  struct hv_netvsc_packet *packet,
> > +					  struct net_device *ndev)
> > +{
> > +#ifdef CONFIG_SYSFS
> > +	skb_record_rx_queue(skb, packet->channel->
> > +			    offermsg.offer.sub_channel_index %
> > +			    ndev->real_num_rx_queues);
> > +#endif
> > +}
> 
> This is still fantastically gross, what is so unique about your driver that it needs
> hacks like this?  No other driver to my knowledge does.
> 
> Figure out what it is that makes your driver so unique, and try to make it
> conform to how other drivers handle these features without SYSFS ifdef'ery
> instead.
> 

I looked around the other drivers, and the netif_set_real_num_rx_queues() function. 
It's already switched to no-op without CONFIG_SYSFS flag. So I will rely on this, and 
don't have to handle the flag in my code. 

Thanks,
- Haiyang
