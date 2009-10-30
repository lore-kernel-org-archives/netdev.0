From: Adayadil Thomas <adayadil.thomas@gmail.com>
Subject: Re: Connection tracking and vlan
Date: Fri, 30 Oct 2009 15:20:21 -0400
Message-ID: <fb7befa20910301220y53e43608u3b37de17661feb4e@mail.gmail.com>
References: <20091030152054.GA7936@gondor.apana.org.au>
	 <4AEB06E6.6020206@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Herbert Xu <herbert@gondor.apana.org.au>, netdev@vger.kernel.org,
	Patrick McHardy <kaber@trash.net>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vw0-f192.google.com ([209.85.212.192]:54619 "EHLO
	mail-vw0-f192.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757349AbZJ3TUR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 Oct 2009 15:20:17 -0400
Received: by vws30 with SMTP id 30so721861vws.33
        for <netdev@vger.kernel.org>; Fri, 30 Oct 2009 12:20:22 -0700 (PDT)
In-Reply-To: <4AEB06E6.6020206@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Oct 30, 2009 at 11:31 AM, Eric Dumazet <eric.dumazet@gmail.com> wrote:

> Very strange, this question about vlan looks like discussion we had
> yesterday (or the day before...) about interfaces (versus packet defragmentation)
>
> "IP conntracking" is about IP, and [V]LAN doesnt matter at all at this protocol level.
>
> Same thing if you have two interfaces, eth0 & eth1 : IP conntrack tuples dont
> include interface name/index

I am concerned about the following situation -

The linux device is configured as a bridge and is deployed between the
trunk ports
of 2 switches. In this situation the linux device will be seeing 802.1q packets
with vlan headers specifying the vlanids.

It is valid to have an environment where private IP addresses are duplicated
on different virtual LANs. i.e. it is valid to have machine A (
10.10.10.1) talking to
machine B (10.10.10.2) on vlan 1,
and
at the same time machine C ( 10.10.10.1) talking to machine D
(10.10.10.2) on vlan 2.

Since they are on different LANs (VLANs), there should not be any issues.

Now when VLANs are shared across switches, the trunk port will sent
802.1q tagged
packets between the switches. Imagine these packets when going through
the linux bridge.
The 802.1q header should identify the separate vlans by the vlan id.

If ip_conntrack does not consider vlans, it is possible that all 5
tuple are the same
and thus affect the connection tracking.

I hope I have described the scenario well. If not I can explain in a
more detailed fashion.

Thanks
