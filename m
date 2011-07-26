From: =?ISO-8859-2?Q?Micha=B3_Miros=B3aw?= <mirqus@gmail.com>
Subject: Re: [patch net-next-2.6] forcedeth: fix vlans
Date: Tue, 26 Jul 2011 19:55:06 +0200
Message-ID: <CAHXqBF+qjCzfQmDLdKvanpBuQo1X-zFAr_26SCwVuwbSVwpyPA@mail.gmail.com>
References: <1311698510-2599-1-git-send-email-jpirko@redhat.com>
 <CAHXqBF+Yr8Bw0LZHPpPuFY9iDyxxCCKw7S7FZkuGseiCK-es3g@mail.gmail.com> <CAEP_g=9xVomtnViW=rWYmXqGO_45=N8YhWMHsObBXnWAf9Gh5A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-2
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Jiri Pirko <jpirko@redhat.com>, netdev@vger.kernel.org,
	davem@davemloft.net, johnstul@us.ibm.com, w41ter@gmail.com
To: Jesse Gross <jesse@nicira.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qy0-f181.google.com ([209.85.216.181]:56472 "EHLO
	mail-qy0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751426Ab1GZRz1 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Jul 2011 13:55:27 -0400
Received: by qyk9 with SMTP id 9so400416qyk.19
        for <netdev@vger.kernel.org>; Tue, 26 Jul 2011 10:55:26 -0700 (PDT)
In-Reply-To: <CAEP_g=9xVomtnViW=rWYmXqGO_45=N8YhWMHsObBXnWAf9Gh5A@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

W dniu 26 lipca 2011 19:49 u=BFytkownik Jesse Gross <jesse@nicira.com> =
napisa=B3:
> 2011/7/26 Micha=B3 Miros=B3aw <mirqus@gmail.com>:
>> 2011/7/26 Jiri Pirko <jpirko@redhat.com>:
>>> For some reason, when rxaccel is disabled, NV_RX3_VLAN_TAG_PRESENT =
is
>>> still set and some pseudorandom vids appear. So check for
>>> NETIF_F_HW_VLAN_RX as well. Also set correctly hw_features and set =
vlan
>>> mode on probe.
>>>
>>> Signed-off-by: Jiri Pirko <jpirko@redhat.com>
>>> ---
>>> =A0drivers/net/forcedeth.c | =A0 =A08 ++++++--
>>> =A01 files changed, 6 insertions(+), 2 deletions(-)
>>>
>>> diff --git a/drivers/net/forcedeth.c b/drivers/net/forcedeth.c
>>> index e64cd9c..256a272 100644
>>> --- a/drivers/net/forcedeth.c
>>> +++ b/drivers/net/forcedeth.c
>>> @@ -2764,7 +2764,8 @@ static int nv_rx_process_optimized(struct net=
_device *dev, int limit)
>>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0prefetch(skb->data);
>>>
>>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0vlanflags =3D le32_t=
o_cpu(np->get_rx.ex->buflow);
>>> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (vlanflags & NV_RX=
3_VLAN_TAG_PRESENT) {
>>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (dev->features & N=
ETIF_F_HW_VLAN_RX &&
>>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 vlanflags & N=
V_RX3_VLAN_TAG_PRESENT) {
>>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0u16 =
vid =3D vlanflags & NV_RX3_VLAN_TAG_MASK;
>> Please add comment that resembles this patch's description. This is =
a
>> bad idea to do in the general case as this will cause VLAN tagged
>> packets that were in the queue before feature change to be
>> misinterpreted.
> It may be a bad idea but it's not that uncommon - frequently those
> vlan status fields come from the parser and merely indicate the
> presence of a tag in the original packet, not whether it was stripped=
=2E

That doesn't make this code applicable for general use. If it's not
commented properly people will copy it without thinking if they really
need the workaround or not.

Best Regards,
Micha=B3 Miros=B3aw
