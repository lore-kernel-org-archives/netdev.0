From: Jay Vosburgh <fubar@us.ibm.com>
Subject: Re: [PATCH] bonding: document two undocumented options.
Date: Wed, 03 Aug 2011 13:59:53 -0700
Message-ID: <3571.1312405193@death>
References: <1312315615-5739-1-git-send-email-nicolas.2p.debian@free.fr> <20110803.034425.1421983987148421662.davem@davemloft.net> <4E39A907.5040408@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	Stephen Hemminger <shemminger@vyatta.com>,
	nicolas.2p.debian@free.fr, andy@greyhouse.net,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: =?us-ascii?Q?=3D=3FISO-8859-1=3FQ=3FNicolas=5Fde=5FPeslo=3DFCan=3F=3D?=
	<nicolas.2p.debian@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e32.co.us.ibm.com ([32.97.110.150]:49553 "EHLO
	e32.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754516Ab1HCVAA convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Aug 2011 17:00:00 -0400
Received: from d03relay03.boulder.ibm.com (d03relay03.boulder.ibm.com [9.17.195.228])
	by e32.co.us.ibm.com (8.14.4/8.13.1) with ESMTP id p73Jnvi5031674
	for <netdev@vger.kernel.org>; Wed, 3 Aug 2011 13:49:57 -0600
Received: from d03av04.boulder.ibm.com (d03av04.boulder.ibm.com [9.17.195.170])
	by d03relay03.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p73KxwiC157084
	for <netdev@vger.kernel.org>; Wed, 3 Aug 2011 14:59:58 -0600
Received: from d03av04.boulder.ibm.com (loopback [127.0.0.1])
	by d03av04.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p73Ext9f021270
	for <netdev@vger.kernel.org>; Wed, 3 Aug 2011 08:59:56 -0600
In-reply-to: <4E39A907.5040408@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Nicolas de Peslo=C3=BCan <nicolas.2p.debian@gmail.com> wrote:

>Le 03/08/2011 12:44, David Miller a =C3=A9crit :
>> From: Nicolas de Peslo=C3=BCan<nicolas.2p.debian@free.fr>
>> Date: Tue,  2 Aug 2011 22:06:55 +0200
>>
>>> Commit 655f8919d549ad1872e24d826b6ce42530516d2e
>>>      bonding: add min links parameter to 802.3ad
>>>
>>> and commit ebd8e4977a87cb81d93c62a9bff0102a9713722f
>>>      bonding: add all_slaves_active parameter
>>>
>>> introduced new options to bonding, but didn't provide the documenta=
tion
>>> for those options.
>>>
>>> Signed-off-by: Nicolas de Peslo=C3=BCan<nicolas.2p.debian@free.fr>
>>
>> Please explicitly mention in each new entry what the default
>> setting is.
>
>Unfortunately, I failed to find a place in the bonding code where the
>max_links option is initialized with a default value. So I must assume
>default value is zero which should cause carrier to always be asserted=
, or
>undefined, which should cause interesting side effects...
>
>The obvious default value should be 1, but I cannot confirm it is.

	Looking at it now, I see no initialization, and it's a static,
so I believe it will end up being zero.  From the code, zero seems like
the proper default, since it will make this test never pass:

                /* are enough slaves available to consider link up? */
                if (active->num_of_ports < bond->params.min_links) {
                        if (netif_carrier_ok(bond->dev)) {
                                netif_carrier_off(bond->dev);
                                return 1;
                        }

	This will cause carrier to be asserted (for 802.3ad mode)
whenever there is an active aggregator, regardless of the number of
available links in that aggregator.

>Stephen, as the author of this feature, can you please clarify what th=
e default value for min_links is?
>
>V2 will follow, giving the real default value for all_slaves_active an=
d
>what I consider the sensible default value for max_links, even if the
>technical real default value is currently unclear.

	I think the actual and sensible default are both zero, although
the documentation should probably mention that a value of zero is magic
and won't ever set the bond down due to too few ports (links) active.

	Or, perhaps describe it how it actually works: if there are
fewer than "min_links" ports in the active aggregator, the bond is set
carrier down.  The default min_links value of zero means that the bond
will never be set down due to having too few ports active.

	-J

---
	-Jay Vosburgh, IBM Linux Technology Center, fubar@us.ibm.com
