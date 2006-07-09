From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH 2/3] [VLAN]: Update iif when receiving via VLAN device
Date: Sun, 9 Jul 2006 17:54:05 +0200
Message-ID: <20060709155405.GO14627@postel.suug.ch>
References: <20060701112833.GS14627@postel.suug.ch> <1151760901.5093.141.camel@jzny2> <20060708105451.GG14627@postel.suug.ch> <1152368076.5272.39.camel@jzny2> <20060708234602.GH14627@postel.suug.ch> <1152449536.5124.31.camel@jzny2> <20060709133327.GK14627@postel.suug.ch> <1152453796.5124.70.camel@jzny2> <20060709141933.GM14627@postel.suug.ch> <1152457232.5124.127.camel@jzny2>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: kaber@trash.net, netdev@vger.kernel.org,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from postel.suug.ch ([194.88.212.233]:51427 "EHLO postel.suug.ch")
	by vger.kernel.org with ESMTP id S932491AbWGIPxo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 9 Jul 2006 11:53:44 -0400
To: Jamal Hadi Salim <hadi@cyberus.ca>
Content-Disposition: inline
In-Reply-To: <1152457232.5124.127.camel@jzny2>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

* Jamal Hadi Salim <hadi@cyberus.ca> 2006-07-09 11:00
> If you mean that the device will also try to grab the qlock there, then
> that is fine still for the serialization. It all starts at
> dev_queue_xmit.

Look at where dev->queue_lock is taken, whenever a qdisc or
filter is added, modified or deleted the lock is taken. Using
your approach packets get dropped while such an operation is
taking place. Your approach is wrong.
