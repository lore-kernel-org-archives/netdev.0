From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH iproute2 v1] iproute2: show counter of carrier on<->off
 transitions
Date: Tue, 22 Apr 2014 15:46:16 -0700
Message-ID: <20140422154616.4e4eb445@nehalam.linuxnetplumber.net>
References: <cover.1396455409.git.decot@googlers.com>
	<6c78808eaf4b31f98c9de9bef6f29397c67cf09e.1396455409.git.decot@googlers.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Decotigny <decot@googlers.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f182.google.com ([209.85.192.182]:43914 "EHLO
	mail-pd0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751528AbaDVWqT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Apr 2014 18:46:19 -0400
Received: by mail-pd0-f182.google.com with SMTP id y10so98279pdj.27
        for <netdev@vger.kernel.org>; Tue, 22 Apr 2014 15:46:19 -0700 (PDT)
In-Reply-To: <6c78808eaf4b31f98c9de9bef6f29397c67cf09e.1396455409.git.decot@googlers.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed,  2 Apr 2014 09:19:00 -0700
David Decotigny <decot@googlers.com> wrote:

> This patch allows to display the current counter of carrier on<->off
> transitions (IFLA_CARRIER_CHANGES, see kernel commit "expose number of
> carrier on/off changes"):
> 
>   ip -s -s link show dev eth0
>   ...
>   2: eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 etc.
>     link/ether ............ brd ff:ff:ff:ff:ff:ff
>     RX: bytes  packets  errors  dropped overrun mcast
>     134705     758      0       0       0       0
>     RX errors: length  crc     frame   fifo    missed
>                0        0       0       0       0
>     TX: bytes  packets  errors  dropped carrier collsns
>     77374      731      0       0       0       0
>     TX errors: aborted fifo    window  heartbeat
>                0        0       0       0
>     link: carrier_changes 4
> 

I wonder if putting it under TX errors would make sense.
This is where Juniper classifies the error, and it would also
fit on same line, avoiding adding more clutter.


   2: eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 etc.
     link/ether ............ brd ff:ff:ff:ff:ff:ff
     RX: bytes  packets  errors  dropped overrun mcast
     134705     758      0       0       0       0
     RX errors: length  crc     frame   fifo    missed
                0        0       0       0       0
     TX: bytes  packets  errors  dropped carrier collsns
     77374      731      0       0       0       0
     TX errors: aborted fifo    window  heartbeat transition
                0        0       0       0        4

The risk is break some screen scraping script, but that doesn't
seem to be that big an issue for adding one column.

The columns also need some re-aligning here but that is different
correctness issue.
