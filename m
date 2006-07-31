From: Andy Gospodarek <andy@greyhouse.net>
Subject: Re: eth2.100: received packet with  own address as source address
Date: Mon, 31 Jul 2006 11:46:46 -0400
Message-ID: <20060731154646.GA24625@gospo.rdu.redhat.com>
References: <44CD86A7.4010103@davidcoulson.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: bridge@lists.osdl.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:25820 "EHLO mx1.redhat.com")
	by vger.kernel.org with ESMTP id S1030193AbWGaPqz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 31 Jul 2006 11:46:55 -0400
To: David Coulson <david@davidcoulson.net>
Content-Disposition: inline
In-Reply-To: <44CD86A7.4010103@davidcoulson.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Jul 31, 2006 at 12:27:19AM -0400, David Coulson wrote:
> -----BEGIN PGP SIGNED MESSAGE-----
> Hash: SHA1
> 
> I have a machine running 2.6.18-rc3 with a bridge config that looks like
> this:
> 
> cr1:~# brctl show
> bridge name     bridge id               STP enabled     interfaces
> vlan100         36b0.0007e90f40c1       yes             eth0.100
>                                                         eth2.100
> vlan101         5dc0.0007e90f40c1       yes             eth0.101
>                                                         eth2.101
> vlan102         5dc0.00e08163c33f       yes             eth3
> vlan200         5dc0.0007e90f40c1       yes             eth0.200
>                                                         eth2.200
> vlan201         5dc0.0007e90f40c1       yes             eth0.201
>                                                         eth2.201
> vlan300         5dc0.0007e90f40c1       yes             eth0.300
>                                                         eth2.300
> vlan301         5dc0.0007e90f40c1       yes             eth0.301
>                                                         eth2.301
> vlan302         5dc0.0007e90f40c1       yes             eth0.302
>                                                         eth2.302
> vlan303         5dc0.0007e90f40c1       yes             eth0.303
>                                                         eth2.303
> 
> All bridges, except for vlan102, are running STP and appear to have
> elected themselves the root bridge.
> 
> I see this on the console:
> 
> printk: 18 messages suppressed.
> eth2.100: received packet with  own address as source address
> printk: 20 messages suppressed.
> eth2.200: received packet with  own address as source address
> 

This usually means that you have a loop somewhere, I can't say
specifically that this is the case with your current setup, but it would
be interesting to capture traffic on that interface and determine what
it looks like in more detail.


> This repeats continuously, only indicating an issue on the two specific
> ports mentioned above. This confuses me:
> 
> 1) All VLANs (except for 102) are in an identical configuration
> 2) No other VLANs exhibit the same kernel message
> 3) I have another machine, running 2.6.18-rc2 with the same config and
> no kernel message
> 
> Is this message specifically related to BPDU frames, or is it pertaining
> to any Ethernet frame on the port?
> 
> Here is the STP config for one of the bridges. What's the next step to
> troubleshoot this?

Capture some of the suspicious traffic.

> 
> vlan200
>  bridge id              5dc0.0007e90f40c1
>  designated root        5dc0.0007e90f40c1
>  root port                 0                    path cost                  0
>  max age                  20.00                 bridge max age
>   20.00
>  hello time                2.00                 bridge hello time
>    2.00
>  forward delay             5.00                 bridge forward delay
>    5.00
>  ageing time             300.01
>  hello timer               1.67                 tcn timer
>    0.00
>  topology change timer     0.00                 gc timer
>    0.03
>  flags
> 
> 
> eth0.200 (1)
>  port id                8001                    state
> forwarding
>  designated root        5dc0.0007e90f40c1       path cost                 19
>  designated bridge      5dc0.0007e90f40c1       message age timer
>    0.00
>  designated port        8001                    forward delay timer
>    0.00
>  designated cost           0                    hold timer
>    0.67
>  flags
> 
> eth2.200 (2)
>  port id                8002                    state
> blocking
>  designated root        5dc0.0007e90f40c1       path cost                  4
>  designated bridge      5dc0.0007e90f40c1       message age timer
>   19.67
>  designated port        8001                    forward delay timer
>    0.00
>  designated cost           0                    hold timer
>    0.00
>  flags
> 
> 
> David
> 
> - --
> David J. Coulson
> email: david@davidcoulson.net
> web: http://www.davidcoulson.net/
> -----BEGIN PGP SIGNATURE-----
> Version: GnuPG v1.4.3 (GNU/Linux)
> Comment: Using GnuPG with Mozilla - http://enigmail.mozdev.org
> 
> iD8DBQFEzYanTIgPQWnLowkRApT1AJ9yXl/O+rzacF+mpM7hhNtsEh/ufACfQCHk
> mBGBxl5Iscj7vbFlM0IzY/Y=
> =ZIs7
> -----END PGP SIGNATURE-----
> -
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
