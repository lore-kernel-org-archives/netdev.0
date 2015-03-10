From: Alexander Duyck <alexander.h.duyck@redhat.com>
Subject: Re: ipv4 route dump broken with multiple subnets
Date: Tue, 10 Mar 2015 10:37:13 -0700
Message-ID: <54FF2BC9.8080202@redhat.com>
References: <20150310170746.GA1743@kria>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Sabrina Dubroca <sd@queasysnail.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:46191 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932121AbbCJRhT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 10 Mar 2015 13:37:19 -0400
In-Reply-To: <20150310170746.GA1743@kria>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 03/10/2015 10:07 AM, Sabrina Dubroca wrote:
> With this setup (no other address assigned):
>
> ip link add type dummy
> ip link set dummy0 up
> ip a a 10.0.0.1/24 dev dummy0
>
> route dump works:
>
> # ip r
> 10.0.0.0/24 dev dummy0 proto kernel scope link src 10.0.0.1
>
>
> If I add another address:
>
> ip a a 10.0.1.1/24 dev dummy0
>
> or a route:
>
> ip r a 10.0.1.0/24 via 10.0.0.2
>
> # ip r
> <empty>
>
> It's the same with /proc/net/route instead of ip route.
>
> But with a default route the table appears again.
>
>
> This patch seems to fix the problem, but I'm not sure it is correct.

It looks like I can reproduce it as well if I just add dummy, and then 
drop the default route.  I will look into it and should be able to tell 
you what is going on in the next hour or two.

- Alex
