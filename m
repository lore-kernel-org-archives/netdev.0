From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: why are IPv6 addresses removed on link down
Date: Mon, 12 Jan 2015 23:10:21 -0800
Message-ID: <20150112231021.316648e3@urahara>
References: <54B4A7E4.7030301@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: David Ahern <dsahern@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f175.google.com ([209.85.192.175]:50122 "EHLO
	mail-pd0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750989AbbAMHKc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Jan 2015 02:10:32 -0500
Received: by mail-pd0-f175.google.com with SMTP id g10so1835034pdj.6
        for <netdev@vger.kernel.org>; Mon, 12 Jan 2015 23:10:32 -0800 (PST)
In-Reply-To: <54B4A7E4.7030301@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 12 Jan 2015 22:06:44 -0700
David Ahern <dsahern@gmail.com> wrote:

> We noticed that IPv6 addresses are removed on a link down. e.g.,
>    ip link set dev eth1
> 
> 
> Looking at the code it appears to be this code path in addrconf.c:
> 
>          case NETDEV_DOWN:
>          case NETDEV_UNREGISTER:
>                  /*
>                   *      Remove all addresses from this interface.
>                   */
>                  addrconf_ifdown(dev, event != NETDEV_DOWN);
>                  break;
> 
> IPv4 addresses are NOT removed on a link down. Is there a particular 
> reason IPv6 addresses are?
> 
> Thanks,
> David

See RFC's which describes how IPv6 does Duplicate Address Detection.
Address is not valid when link is down, since DAD is not possible.
