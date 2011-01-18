From: Jesse Gross <jesse@nicira.com>
Subject: Re: [PATCH] net offloading: Do not mask out NETIF_F_HW_VLAN_TX for vlan.
Date: Tue, 18 Jan 2011 02:12:26 -0500
Message-ID: <AANLkTikmadouBTgkf4OZy30=Zg6uZ+qSng=rWhTjjm8e@mail.gmail.com>
References: <1295333160-1667-1-git-send-email-jesse@nicira.com>
	<1295333714.3362.561.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	Michael Chan <mchan@broadcom.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gx0-f174.google.com ([209.85.161.174]:57581 "EHLO
	mail-gx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751433Ab1ARHM1 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 Jan 2011 02:12:27 -0500
Received: by gxk9 with SMTP id 9so2198992gxk.19
        for <netdev@vger.kernel.org>; Mon, 17 Jan 2011 23:12:26 -0800 (PST)
In-Reply-To: <1295333714.3362.561.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jan 18, 2011 at 1:55 AM, Eric Dumazet <eric.dumazet@gmail.com> =
wrote:
> Le lundi 17 janvier 2011 =E0 22:46 -0800, Jesse Gross a =E9crit :
>> In netif_skb_features() we return only the features that are valid f=
or vlans
>> if we have a vlan packet. =A0However, we should not mask out NETIF_F=
_HW_VLAN_TX
>> since it enables transmission of vlan tags and is obviously valid.
>>
>> Reported-by: Eric Dumazet <eric.dumazet@gmail.com>
>> Signed-off-by: Jesse Gross <jesse@nicira.com>
>
> Thanks Jesse
>
> Acked-by: Eric Dumazet <eric.dumazet@gmail.com>
>
> Now back to the "ethtool -K eth0 txvlan off" problem on bnx2
>
> Is it a driver/software problem or hardware/firmware one ?

CC'ing Michael Chan

It looks like bnx2 is storing the offsets of various headers so the
hardware can find them for TSO.  The parsing logic doesn't do anything
for vlan tags, so the hardware gets confused if one is present in the
packet itself.

Quick fix is to simply disallow disabling TX vlan offload or disable
TSO at the same time or some other Ethtool game.  However, if the
hardware supports it then it would be nicer to fix up the TSO setup
logic.  Maybe we can just add the size of the vlan tag to the offset
but I am not certain.  Michael, do you know if this is possible?
