From: Andrei Warkentin <andreiw@motorola.com>
Subject: Re: [PATCHv3] Bridge: Always send NETDEV_CHANGEADDR up on br MAC change.
Date: Fri, 5 Aug 2011 01:13:14 -0500
Message-ID: <CALfQTu7MVjfO7vHB-mAC=RwokBRsi7vR6_XVfQX0+vU2ZCVHOw@mail.gmail.com>
References: <1312509349-23363-1-git-send-email-andreiw@motorola.com>
	<1312510625-26596-2-git-send-email-andreiw@motorola.com>
	<20110804213605.31be6131@nehalam.ftrdhcpuser.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exprod5og108.obsmtp.com ([64.18.0.186]:48559 "EHLO
	exprod5og108.obsmtp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750976Ab1HERL1 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 5 Aug 2011 13:11:27 -0400
Received: from il93mgrg01.am.mot-mobility.com ([10.22.94.168])
	by il93mgrg01.am.mot-mobility.com (8.14.3/8.14.3) with ESMTP id p7569ntt000552
	for <netdev@vger.kernel.org>; Fri, 5 Aug 2011 02:09:49 -0400 (EDT)
Received: from mail-ww0-f46.google.com (mail-ww0-f46.google.com [74.125.82.46])
	by il93mgrg01.am.mot-mobility.com (8.14.3/8.14.3) with ESMTP id p7568vA8000351
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=OK)
	for <netdev@vger.kernel.org>; Fri, 5 Aug 2011 02:09:49 -0400 (EDT)
Received: by mail-ww0-f46.google.com with SMTP id 25so2500436wwf.3
        for <netdev@vger.kernel.org>; Thu, 04 Aug 2011 23:13:14 -0700 (PDT)
In-Reply-To: <20110804213605.31be6131@nehalam.ftrdhcpuser.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Stephen,

On Thu, Aug 4, 2011 at 11:36 PM, Stephen Hemminger
<shemminger@vyatta.com> wrote:
> On Thu, =A04 Aug 2011 21:17:05 -0500
> Andrei Warkentin <andreiw@motorola.com> wrote:
>
> Half ok, half not.
>
>> diff --git a/net/bridge/br_device.c b/net/bridge/br_device.c
>> index cf09fe5..ef18070 100644
>> --- a/net/bridge/br_device.c
>> +++ b/net/bridge/br_device.c
>> @@ -162,6 +162,7 @@ static int br_set_mac_address(struct net_device =
*dev, void *p)
>> =A0 =A0 =A0 br->flags |=3D BR_SET_MAC_ADDR;
>> =A0 =A0 =A0 spin_unlock_bh(&br->lock);
>>
>> + =A0 =A0 call_netdevice_notifiers(NETDEV_CHANGEADDR, dev);
>> =A0 =A0 =A0 return 0;
>> =A0}
>
> This is unnecessary since already done by dev_set_mac_address.
>
>> diff --git a/net/bridge/br_stp_if.c b/net/bridge/br_stp_if.c
>> index c0990ba..4528e9a 100644
>> --- a/net/bridge/br_stp_if.c
>> +++ b/net/bridge/br_stp_if.c
>> @@ -213,7 +213,7 @@ bool br_stp_recalculate_bridge_id(struct net_bri=
dge *br)
>>
>> =A0 =A0 =A0 /* user has chosen a value so keep it */
>> =A0 =A0 =A0 if (br->flags & BR_SET_MAC_ADDR)
>> - =A0 =A0 =A0 =A0 =A0 =A0 return;
>> + =A0 =A0 =A0 =A0 =A0 =A0 return false;
>>
>> =A0 =A0 =A0 list_for_each_entry(p, &br->port_list, list) {
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (addr =3D=3D br_mac_zero ||
>
> This is already in net-next.
>

Thank you for your feedback. I will clean this up and resubmit tomorrow=
=2E

A
