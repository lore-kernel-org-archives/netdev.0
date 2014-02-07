From: David Miller <davem@davemloft.net>
Subject: Re: Suspected Copy Paste error in rtnl_bridge_notify
Date: Thu, 06 Feb 2014 19:45:03 -0800 (PST)
Message-ID: <20140206.194503.1975815381717889886.davem@davemloft.net>
References: <CAG6enPwAfm8YDrGmEEitv_fHeF5rVVN2nXujh=u4kVy0sKx4ag@mail.gmail.com>
	<CAG6enPyV9bvYSwDrMp6X1LY6PXrmrP5MtjNk0N+7qs1LDY5pRg@mail.gmail.com>
	<20140131114712.GB26148@htj.dyndns.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: yogeshgaur.83@gmail.com, akpm@linux-foundation.org,
	torvalds@linux-foundation.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: tj@kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20140131114712.GB26148@htj.dyndns.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Tejun Heo <tj@kernel.org>
Date: Fri, 31 Jan 2014 06:47:12 -0500

>> In above code isn't code line:
>> err = br_dev->netdev_ops->ndo_bridge_getlink(skb, 0, 0, dev, 0);
>> should be
>> err = br_dev->netdev_ops->ndo_bridge_getlink(skb, 0, 0, br_dev, 0);
>> 
>> If this needs to be changed then please review attached patch adding this
>> change.

It's not a typo, we want the actual underlying physical device.

Look at the implementations such as drivers/net/ethernet/emulex/be_main.c:
be_ndo_bridge_netlink().  It's doing things like:

	struct be_adapter *adapter = netdev_priv(dev);
