From: Ben Greear <greearb@candelatech.com>
Subject: Re: af_packet.c bug?
Date: Mon, 28 Mar 2005 12:08:14 -0800
Message-ID: <4248642E.40304@candelatech.com>
References: <424858D4.8060604@candelatech.com> <20050328195557.GF3086@postel.suug.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "'netdev@oss.sgi.com'" <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Thomas Graf <tgraf@suug.ch>
In-Reply-To: <20050328195557.GF3086@postel.suug.ch>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Thomas Graf wrote:
> * Ben Greear <424858D4.8060604@candelatech.com> 2005-03-28 11:19
> 
>>What is the '13' doing here?  Maybe it should be IFNAMSIZ?
>>
>>	/*
>>	 *	Find the device first to size check it
>>	 */
>>
>>	saddr->spkt_device[13] = 0;
>>	dev = dev_get_by_name(saddr->spkt_device);
>>	err = -ENODEV;
>>	if (dev == NULL)
>>		goto out_unlock;
> 
> 
> Seems so, please adopt the size of spkt_device in struct sockaddr_pkt

you mean adapt maybe?

> as well if you change it, it's currently hardcoded as 14.

I was also wondering why we couldn't hold a reference to the net-device
instead of just it's ifindex when dealing with a bound raw socket.

That would save the device lookup for each packet sent.

I figure that we would need to listen for NETDEV_UNREGISTER
events and do a dev_put whenever the device wants to go away.

Does that sound workable?

Ben

-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com
