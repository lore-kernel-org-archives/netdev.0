From: Arthur Marsh <arthur.marsh@internode.on.net>
Subject: Re: eth0: set_features() failed (-1); wanted 0x0000000000004000, left
 0x0000000000004800
Date: Sat, 14 Nov 2015 14:24:25 +1030
Message-ID: <5646B071.6020100@internode.on.net>
References: <5646A7A4.2070808@internode.on.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>,
	Jay Vosburgh <j.vosburgh@gmail.com>,
	Veaceslav Falico <vfalico@gmail.com>,
	Andy Gospodarek <gospo@cumulusnetworks.com>,
	Jiri Pirko <jiri@resnulli.us>,
	Nikolay Aleksandrov <razor@blackwall.org>,
	Michal Kubecek <mkubecek@suse.cz>,
	Alexander Duyck <alexander.duyck@gmail.com>,
	Linux Networking Developer Mailing List
	<netdev@vger.kernel.org>
To: Jarod Wilson <jarod@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ipmail04.adl6.internode.on.net ([150.101.137.141]:43598 "EHLO
	ipmail04.adl6.internode.on.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751085AbbKNDyo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Nov 2015 22:54:44 -0500
In-Reply-To: <5646A7A4.2070808@internode.on.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



Arthur Marsh wrote on 14/11/15 13:46:
> Hi, I'm not sure if this is an actual error or just an informational
> message but on this pc (with a single-core AMD Athlon(tm) 64 Processor
> 3200+) I've been getting the following:
>
>
> Nov 13 18:16:12 localhost kernel: [    0.938025] via-rhine 0000:00:12.0
> eth0: set_features() failed (-1); wanted 0x0000000000004000, left
> 0x0000000000004800
> Nov 13 18:16:12 localhost kernel: [    0.938574] via-rhine 0000:00:12.0
> eth0: VIA Rhine II at 0x1e000, 00:13:d4:cc:9b:57, IRQ 23
> Nov 13 18:16:12 localhost kernel: [    0.939418] via-rhine 0000:00:12.0
> eth0: MII PHY found at address 1, status 0x786d advertising 01e1 Link 45e1
>
> The Ethernet card still works nonetheless.
>
> git-bisect showed that the:
>
> eth0: set_features() failed (-1); wanted 0x0000000000004000, left
> 0x0000000000004800
>
> messages started with the following commit:
>
>   git bisect good
> e7868a85e1b26bcb2e71088841eec1d310a97ac9 is the first bad commit
> commit e7868a85e1b26bcb2e71088841eec1d310a97ac9
> Author: Jarod Wilson <jarod@redhat.com>
> Date:   Tue Nov 3 23:09:32 2015 -0500
>
>      net/core: ensure features get disabled on new lower devs
>
>      With moving netdev_sync_lower_features() after the .ndo_set_features
>      calls, I neglected to verify that devices added *after* a flag had
> been
>      disabled on an upper device were properly added with that flag
> disabled as
>      well. This currently happens, because we exit
> __netdev_update_features()
>      when we see dev->features == features for the upper dev. We can
> retain the
>      optimization of leaving without calling .ndo_set_features with a
> bit of
>      tweaking and a goto here.

Nikolay Aleksandrov's patch:

http://patchwork.ozlabs.org/patch/544307/

fixed the issue for me thanks.

Arthur.
