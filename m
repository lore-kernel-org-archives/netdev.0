From: Jesse Brandeburg <jesse.brandeburg@gmail.com>
Subject: Re: dropped packets with bonding and 8021q
Date: Thu, 27 Aug 2009 15:22:55 -0700
Message-ID: <4807377b0908271522r43d7c25lcfbecbe0e6f0a467@mail.gmail.com>
References: <9e8b01b1556687e0b78ca63dfb5ca8dc.squirrel@ssl.serverraum.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-kernel@vger.kernel.org
To: Michael Walle <michael@walle.cc>,
	NetDEV list <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f184.google.com ([209.85.211.184]:55327 "EHLO
	mail-yw0-f184.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752650AbZH0WWy convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Aug 2009 18:22:54 -0400
In-Reply-To: <9e8b01b1556687e0b78ca63dfb5ca8dc.squirrel@ssl.serverraum.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46orwarding to the networking mailing list

On Wed, Aug 19, 2009 at 3:29 AM, Michael Walle<michael@walle.cc> wrote:
>
> Hi,
>
> i have some strange bonding and vlan configuration. The bonding inter=
face
> is in active-standby mode and i want to send and receive raw ethernet
> frames on _both_ enslaved interfaces. Additionally the frames are tag=
ged
> with a vlan id. So one config could be:
>
> # modprobe bonding mode=3D1
> # modprobe 8021q
> # ifenslave bond0 eth1
> # ifenslave bond0 eth2
> # vconfig add eth1 10
> # vconfig add eth2 20
> # vconfig add bond0 1000
>
> # [activate bonding active slave etc..]
>
> I use raw/dgram sockets (AF_PACKET) with eth1.10 and eth2.20 (or dump=
 the
> frames with tcpdump).
>
> As long as i don't use the bonding module everything works as expecte=
d.
> But if the physical interfaces are enslaved, frames received on the
> standby device will be dropped.
>
> The network driver is e1000. So the hardware acceleration for tagged =
VLAN
> frames gets used and the frame gets through __vlan_hwaccel_rx() in th=
e
> receiving path. And there it seems to get dropped by
> skb_bond_should_drop().
>
> On the "normal" receive path there was a patch by Joe Eykholt that al=
lows
> to receive frames on the physical interface even if it is enslaved an=
d not
> active (git commit 0d7a3681232f545).
>
> Shouldn't __vlan_hwaccel_rx() (in net/8021q/vlan_core.c) be patched i=
n the
> same way to allow reception on inactive enslaved interfaces?
>
> Thanks,
> =A0Michael
>
> PS. could you please cc me, as i'm not subscribed to the ml.
>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kerne=
l" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at =A0http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at =A0http://www.tux.org/lkml/
>
