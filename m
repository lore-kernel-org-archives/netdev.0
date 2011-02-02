From: =?UTF-8?B?Tmljb2xhcyBkZSBQZXNsb8O8YW4=?=
	<nicolas.2p.debian@gmail.com>
Subject: Re: Bonding on bond
Date: Wed, 02 Feb 2011 11:19:45 +0100
Message-ID: <4D492FC1.2030203@gmail.com>
References: <4D374A8F.2020303@gmail.com> <20110120153110.GA3931@midget.suse.cz> <4D385F0B.1010000@gmail.com> <4202.1295553193@death> <4D3B60D2.30309@gmail.com> <15526.1296261528@death>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "bonding-devel@lists.sourceforge.net"
	<bonding-devel@lists.sourceforge.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Jay Vosburgh <fubar@us.ibm.com>, Jiri Bohac <jbohac@suse.cz>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:36575 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751677Ab1BBKTs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Feb 2011 05:19:48 -0500
Received: by fxm20 with SMTP id 20so7838884fxm.19
        for <netdev@vger.kernel.org>; Wed, 02 Feb 2011 02:19:47 -0800 (PST)
In-Reply-To: <15526.1296261528@death>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 29/01/2011 01:38, Jay Vosburgh a =C3=A9crit :
> Nicolas de Peslo=C3=BCan<nicolas.2p.debian@gmail.com>  wrote:

[snip]

>> However, the ingress path doesn't work at all. bond0 is unable to re=
ceive any packets (ARP or IP).
>
> 	In light of this, I don't see a problem with disallowing nesting
> of bonds.  It should be documented in bonding.txt.

Ok, I will do that.

Jiri, any trouble with me stealing your patch (code) and adding the doc=
umentation update part? Or do=20
you prefer to do it yourself?

[snip]

>> That being said, we still miss a way to achieve a simple configurati=
on
>> with several links doing load balancing to a switch and one or sever=
al
>> links doing fail over to another switch, both switches *not* being 8=
02.3ad
>> capable.
>
> 	This is a harder problem, but it's something that doesn't work
> today (and I suspect hasn't for a long time, so if somebody was using
> this, I think there would have been some discussion).

In the mean time, I will state in the documentation that:

- nesting is not allowed.
- only the above particular setup would possibly require nesting.
- this can be achieve using 802.3ad mode, connected to 802.3ad capable =
switches.

>> Should we arrange for bonding to be allowed to nest, for this purpos=
e, or
>> should we find a way to setup this configuration with a single level=
 of
>> bonding ? I would prefer the second, but...
>
> 	I'm not sure that either is necessary; 802.3ad will do this
> today, and few current production switches lack 802.3ad support.
>
> 	Adding support for etherchannel (i.e., not 802.3ad) gang
> failover is nontrivial, because the multiple etherchannel port groups
> will have to be managed separately, and most likely assigned manually=
=2E
> Sure, it'd be nice to have, but I'm not sure if it's a benefit worth =
the
> effort.

I'm far from a 802.3ad (802.1AX) specialist, but... wouldn't it be poss=
ible to force the aggregator=20
by hand, for every slaves, to achieve the same effect as receiving LACP=
DU, when connected to non=20
802.3ad capable switches?

echo 802.3ad > /sys/class/net/bond0/bonding/mode
echo +eth0 > /sys/class/net/bond0/bonding/slaves
echo +eth1 > /sys/class/net/bond0/bonding/slaves
echo +eth2 > /sys/class/net/bond0/bonding/slaves
echo 1 > /sys/class/net/bond0/bonding/ad_aggregator_eth0 # those sysfs =
entries to be created...
echo 1 > /sys/class/net/bond0/bonding/ad_aggregator_eth1
echo 2 > /sys/class/net/bond0/bonding/ad_aggregator_eth2

> 	Either way, for now, since I recall you mentioned in another
> email that you'd crashed the system from nesting bonds, I don't see a
> problem with disallowing nesting and updating the documentation with =
a
> bit of this discussion (e.g., "nesting doesn't work, you're probably
> trying to do gang failover, which 802.3ad already does for you").

Thanks.

	Nicolas.
