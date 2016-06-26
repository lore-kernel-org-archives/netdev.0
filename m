From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH RESEND] ipconfig : Fix null reference to the freed
 dev_addr
Date: Sun, 26 Jun 2016 15:43:46 -0400 (EDT)
Message-ID: <20160626.154346.1759874035992627168.davem@davemloft.net>
References: <1466590093-1515-1-git-send-email-chanho.min@lge.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kuznet@ms2.inr.ac.ru, jmorris@namei.org,
	fabf@skynet.be, gunho.lee@lge.com, linux-kernel@vger.kernel.org,
	neidhard.kim@lge.com
To: chanho.min@lge.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1466590093-1515-1-git-send-email-chanho.min@lge.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Chanho Min <chanho.min@lge.com>
Date: Wed, 22 Jun 2016 19:08:13 +0900

> To fix this, I suggested patch that checks if device is available
> before the DHCP packet is sended.

The bug is more fundamental than this.

The code is not taking a reference to the netdevice, and that's
the only reason it is able to disappear like this.

It is illegal to reference a netdevice after dropping the rtnl
mutex unless you take a proper reference to it.
