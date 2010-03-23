From: David Miller <davem@davemloft.net>
Subject: Re: forcedeth: cat /sys/class/net/eth0/carrier = Invalid argument
Date: Mon, 22 Mar 2010 20:51:44 -0700 (PDT)
Message-ID: <20100322.205144.256859987.davem@davemloft.net>
References: <4BA7AA92.5040400@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: justinmattock@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <4BA7AA92.5040400@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Justin P. mattock" <justinmattock@gmail.com>
Date: Mon, 22 Mar 2010 10:36:18 -0700

> I've pushed my kernel from the latest HEAD to 2.6.31
> and am still seeing:
> cat /sys/class/net/eth0/carrier
> cat: carrier: Invalid argument
> 
> with my other machine using sky2
> the same results is:
> cat /sys/class/net/eth0/carrier
> 0
> 
> is there anything on this? before I start
> a bisect.(looking through bugzilla, I couldn't
> see anything related).

A device is not able to indicate carrier accurately when
the device is not currently running.

So you will get an -EINVAL until the device is brought up.

The reason is that most drivers don't even probe the link
or negotiate link speed and flow control until the device
is brought up.  Many don't even power up the PHY when the
device is down, in order to save power.

So the behavior you observe is completely expected.
