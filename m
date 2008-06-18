From: Wang Chen <wangchen@cn.fujitsu.com>
Subject: Re: [PATCH 3/3] netdevice: order of synchronization of IFF_PROMISC
 and IFF_ALLMULTI
Date: Wed, 18 Jun 2008 11:22:31 +0800
Message-ID: <48587F77.1030705@cn.fujitsu.com>
References: <48562F9A.5030509@cn.fujitsu.com> <485631FF.7040509@trash.net> <485634D1.2010603@cn.fujitsu.com> <48563A7F.50309@trash.net> <485716A1.8030401@cn.fujitsu.com> <4857B6DC.5020805@trash.net> <48587295.40705@cn.fujitsu.com> <48587854.8050400@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: Patrick McHardy <kaber@trash.net>,
	Alan Cox <alan@lxorguk.ukuu.org.uk>,
	"David S. Miller" <davem@davemloft.net>,
	NETDEV <netdev@vger.kernel.org>
To: Jeff Garzik <jgarzik@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:58264 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1757603AbYFRD0Z (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 17 Jun 2008 23:26:25 -0400
In-Reply-To: <48587854.8050400@pobox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jeff Garzik said the following on 2008-6-18 10:52:
> Wang Chen wrote:
>> Jeff,
>> Any suggestion about this?
>> netdevice uses promiscuity as refcnt, and if driver set IFF_PROMISC
>> but don't change promiscuity will break the refcnt.
> 
> Drivers should not be setting IFF_* flags in set_multicast_list().
> 
> The normal logic is that a driver interprets the request implied in
> set_multicast_list ("promisc, all-multi, or select multi?"), and then
> programs the hardware based on that.
> 
> On some hardware, IFF_ALLMULTI requires that the hardware receive all
> packets (promisc).  Even for that case, the driver should -not- be
> setting the IFF_PROMISC flag.  It should be aware of its own hardware
> programming state through some other method.
> 

OK. Roger that.
If Alan does not oppose it, I will send patches to these drivers later.
Thank you :-)

