From: Jesse Gross <jesse@nicira.com>
Subject: Re: [patch net-next-2.6] forcedeth: fix vlans
Date: Tue, 26 Jul 2011 10:49:43 -0700
Message-ID: <CAEP_g=9xVomtnViW=rWYmXqGO_45=N8YhWMHsObBXnWAf9Gh5A@mail.gmail.com>
References: <1311698510-2599-1-git-send-email-jpirko@redhat.com> <CAHXqBF+Yr8Bw0LZHPpPuFY9iDyxxCCKw7S7FZkuGseiCK-es3g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Jiri Pirko <jpirko@redhat.com>, netdev@vger.kernel.org,
	davem@davemloft.net, johnstul@us.ibm.com, w41ter@gmail.com
To: =?UTF-8?B?TWljaGHFgiBNaXJvc8WCYXc=?= <mirqus@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vx0-f174.google.com ([209.85.220.174]:39623 "EHLO
	mail-vx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751202Ab1GZRuE convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Jul 2011 13:50:04 -0400
Received: by vxh35 with SMTP id 35so497761vxh.19
        for <netdev@vger.kernel.org>; Tue, 26 Jul 2011 10:50:03 -0700 (PDT)
In-Reply-To: <CAHXqBF+Yr8Bw0LZHPpPuFY9iDyxxCCKw7S7FZkuGseiCK-es3g@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2011/7/26 Micha=C5=82 Miros=C5=82aw <mirqus@gmail.com>:
> 2011/7/26 Jiri Pirko <jpirko@redhat.com>:
>> For some reason, when rxaccel is disabled, NV_RX3_VLAN_TAG_PRESENT i=
s
>> still set and some pseudorandom vids appear. So check for
>> NETIF_F_HW_VLAN_RX as well. Also set correctly hw_features and set v=
lan
>> mode on probe.
>>
>> Signed-off-by: Jiri Pirko <jpirko@redhat.com>
>> ---
>> =C2=A0drivers/net/forcedeth.c | =C2=A0 =C2=A08 ++++++--
>> =C2=A01 files changed, 6 insertions(+), 2 deletions(-)
>>
>> diff --git a/drivers/net/forcedeth.c b/drivers/net/forcedeth.c
>> index e64cd9c..256a272 100644
>> --- a/drivers/net/forcedeth.c
>> +++ b/drivers/net/forcedeth.c
>> @@ -2764,7 +2764,8 @@ static int nv_rx_process_optimized(struct net_=
device *dev, int limit)
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0prefetch(skb->data);
>>
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0vlanflags =3D le32_to_cpu(np->get_rx.ex->buflow);
>> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 if (vlanflags & NV_RX3_VLAN_TAG_PRESENT) {
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 if (dev->features & NETIF_F_HW_VLAN_RX &&
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 vlanflags & NV_RX3_VLAN_TAG_PRESENT) {
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0u16 vid =3D vlanflags & NV_RX=
3_VLAN_TAG_MASK;
>
> Please add comment that resembles this patch's description. This is a
> bad idea to do in the general case as this will cause VLAN tagged
> packets that were in the queue before feature change to be
> misinterpreted.

It may be a bad idea but it's not that uncommon - frequently those
vlan status fields come from the parser and merely indicate the
presence of a tag in the original packet, not whether it was stripped.
