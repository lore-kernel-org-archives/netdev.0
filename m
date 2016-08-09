From: =?iso-8859-1?Q?J=F6rn?= Engel <joern@purestorage.com>
Subject: Re: [PATCH] bonding: Allow tun-interfaces as slaves
Date: Mon, 8 Aug 2016 20:09:56 -0700
Message-ID: <20160809030956.GL22974@cork>
References: <20160808211530.GH22974@cork>
 <20160808212112.GI22974@cork>
 <20160808214812.GJ22974@cork>
 <57A93D81.4030808@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: 8bit
Cc: Jay Vosburgh <fubar@us.ibm.com>,
	"David S. Miller" <davem@davemloft.net>,
	Andy Gospodarek <andy@greyhouse.net>, netdev@vger.kernel.org
To: Ding Tianhong <dingtianhong@huawei.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f51.google.com ([209.85.220.51]:35912 "EHLO
	mail-pa0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752143AbcHIDKE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Aug 2016 23:10:04 -0400
Received: by mail-pa0-f51.google.com with SMTP id pp5so719871pac.3
        for <netdev@vger.kernel.org>; Mon, 08 Aug 2016 20:10:04 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <57A93D81.4030808@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello Tianhong!

On Tue, Aug 09, 2016 at 10:18:41AM +0800, Ding Tianhong wrote:
> 
> I don't understand your problem clearly, can you explain more about how the 00503b6f702e break tun-interfaces
> and we will try to fix it.

Here is a trivial testcase:
openvpn --mktun --dev tun0
echo +tun0 > /sys/class/net/bond0/bonding/slaves

Worked fine before your patch, no longer works after your patch.  Works
again after my patch.

> and more, dev_set_mac_address will change the salver's mac address, some nic don't support to change the mac address and
> could not work as bond slave, so we need to check the return value, I don't think this patch has any effective improvement.

Using bonding in balance-rr mode, there doesn't seem to be a need to
change the mac address.  I suppose you might care in other modes, but I
don't.

Jörn
