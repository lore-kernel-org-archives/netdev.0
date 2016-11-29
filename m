From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [iproute2] iproute2: fix the link group name getting error
Date: Tue, 29 Nov 2016 12:49:17 -0800
Message-ID: <20161129124917.498ceecc@samsung9>
References: <1479431573-2910-1-git-send-email-zhangshengju@cmss.chinamobile.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Zhang Shengju <zhangshengju@cmss.chinamobile.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f180.google.com ([209.85.192.180]:36532 "EHLO
        mail-pf0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755402AbcK2UtU (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 29 Nov 2016 15:49:20 -0500
Received: by mail-pf0-f180.google.com with SMTP id 189so33911567pfz.3
        for <netdev@vger.kernel.org>; Tue, 29 Nov 2016 12:49:20 -0800 (PST)
In-Reply-To: <1479431573-2910-1-git-send-email-zhangshengju@cmss.chinamobile.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 18 Nov 2016 09:12:53 +0800
Zhang Shengju <zhangshengju@cmss.chinamobile.com> wrote:

> In the situation where more than one entry live in the same hash bucket,
> loop to get the correct one.
> 
> Before:
> $ cat /etc/iproute2/group
> 0	default
> 256     test
> 
> $ sudo ip link set group test dummy1
> 
> $ ip link show type dummy
> 11: dummy0: <BROADCAST,NOARP> mtu 1500 qdisc noop state DOWN mode DEFAULT group 0 qlen 1000
>     link/ether 4e:3b:d3:6c:f0:e6 brd ff:ff:ff:ff:ff:ff
> 12: dummy1: <BROADCAST,NOARP> mtu 1500 qdisc noop state DOWN mode DEFAULT group test qlen 1000
>     link/ether d6:9c:a4:1f:e7:e5 brd ff:ff:ff:ff:ff:ff
> 
> After:
> $ ip link show type dummy
> 11: dummy0: <BROADCAST,NOARP> mtu 1500 qdisc noop state DOWN mode DEFAULT group default qlen 1000
>     link/ether 4e:3b:d3:6c:f0:e6 brd ff:ff:ff:ff:ff:ff
> 12: dummy1: <BROADCAST,NOARP> mtu 1500 qdisc noop state DOWN mode DEFAULT group test qlen 1000
>     link/ether d6:9c:a4:1f:e7:e5 brd ff:ff:ff:ff:ff:ff
> 
> Signed-off-by: Zhang Shengju <zhangshengju@cmss.chinamobile.com>

Applied, and queued for next push.
