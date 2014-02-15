From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: fe80::/64 route missing on GRE tunnels
Date: Sat, 15 Feb 2014 08:45:59 +0100
Message-ID: <20140215074559.GA8634@order.stressinduktion.org>
References: <20140211215510.GA6994@sesse.net> <20140211215928.GA7862@sesse.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
To: netdev@vger.kernel.org, itk-intern@samfundet.no
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:56669 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751753AbaBOHqB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 15 Feb 2014 02:46:01 -0500
Content-Disposition: inline
In-Reply-To: <20140211215928.GA7862@sesse.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Feb 11, 2014 at 10:59:28PM +0100, Steinar H. Gunderson wrote:
> On Tue, Feb 11, 2014 at 10:55:11PM +0100, Steinar H. Gunderson wrote:
> > but on 3.13.1, no such route shows up. I can add it manually, though.
> 
> Correction; I can add it manually, but only to one GRE device at a time:
> 
>   root@altersex:~$ ip -6 route add fe80::/64 dev k_molvenfinnoy
>   root@altersex:~$ ip -6 route add fe80::/64 dev k_sessesveits
>   RTNETLINK answers: File exists
>   root@altersex:~$ ip -6 route del fe80::/64 dev k_molvenfinnoy
>   root@altersex:~$ ip -6 route add fe80::/64 dev k_sessesveits
>   root@altersex:~$

Sorry for the long delay, I was busy with other stuff...

So basically a workaround you can do for the time being is to add the tunnel
with a local address:

ip tunnel add foo mode gre local 4.3.2.1 remote 1.2.3.4 ttl 64

The reason is that link local address generation fails in ipv6/addrconf as
long as dev->dev_addr is zero.

I have not yet found the change which causes this change in behaviour, but
will do so soon.

Bye,

  Hannes
