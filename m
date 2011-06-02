From: =?ISO-8859-1?Q?Nicolas_de_Peslo=FCan?=
	<nicolas.2p.debian@gmail.com>
Subject: Re: [PATCH] bonding: reset queue mapping prior to transmission to
 physical device
Date: Thu, 02 Jun 2011 22:22:09 +0200
Message-ID: <4DE7F0F1.3010800@gmail.com>
References: <1307037799-32315-1-git-send-email-nhorman@tuxdriver.com> <20110602.130710.1904222486883754792.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: nhorman@tuxdriver.com, netdev@vger.kernel.org, fubar@us.ibm.com,
	andy@greyhouse.net
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:42352 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751902Ab1FBUWN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Jun 2011 16:22:13 -0400
Received: by wya21 with SMTP id 21so921376wya.19
        for <netdev@vger.kernel.org>; Thu, 02 Jun 2011 13:22:12 -0700 (PDT)
In-Reply-To: <20110602.130710.1904222486883754792.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 02/06/2011 22:07, David Miller a =E9crit :
> From: Neil Horman<nhorman@tuxdriver.com>
> Date: Thu,  2 Jun 2011 14:03:19 -0400
>
>> The bonding driver is multiqueue enabled, in which each queue repres=
ents a slave
>> to enable optional steering of output frames to given slaves against=
 the default
>> output policy.  However, it needs to reset the skb->queue_mapping pr=
ior to
>> queuing to the physical device or the physical slave (if it is multi=
queue) could
>> wind up transmitting on an unintended tx queue (one that was reserve=
d for
>> specific traffic classes for instance)
>>
>> Signed-off-by: Neil Horman<nhorman@tuxdriver.com>
>
> Since, as I mentioned, the idea when we are forwarding and bridging i=
s that
> we use the input receive classification to influence the spread on tr=
ansmit,
> I think things like this bonding case should remember the rxhash sett=
ing
> before they override it and then restore that value right before invo=
king
> dev_queue_xmit().

Ok, now I understand. Maybe, using queue mapping for special slave sele=
ction wasn't such a good idea=20
at the very beginning, because it pollutes the RX mapping that is expec=
ted to be propagated up to=20
TX. Restoring the original value before invoking dev_queue_xmit() would=
 fix this, but I'm not sure=20
it is the cleanest way to do it.

	Nicolas.
