From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
Subject: Re: [PATCH net-next] bonding: 3ad: apply ad_actor settings changes
 immediately
Date: Wed, 3 Feb 2016 20:55:52 +0100
Message-ID: <56B25B48.2050703@cumulusnetworks.com>
References: <1454501821-22175-1-git-send-email-razor@blackwall.org>
 <7907.1454526331@famine> <56B25215.10204@cumulusnetworks.com>
 <8564.1454528934@famine>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: Nikolay Aleksandrov <razor@blackwall.org>, netdev@vger.kernel.org,
	davem@davemloft.net, Veaceslav Falico <vfalico@gmail.com>,
	Andy Gospodarek <gospo@cumulusnetworks.com>
To: Jay Vosburgh <jay.vosburgh@canonical.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f52.google.com ([74.125.82.52]:35539 "EHLO
	mail-wm0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750977AbcBCTzz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Feb 2016 14:55:55 -0500
Received: by mail-wm0-f52.google.com with SMTP id r129so181526810wmr.0
        for <netdev@vger.kernel.org>; Wed, 03 Feb 2016 11:55:54 -0800 (PST)
In-Reply-To: <8564.1454528934@famine>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 02/03/2016 08:48 PM, Jay Vosburgh wrote:
> Nikolay Aleksandrov <nikolay@cumulusnetworks.com> wrote:
> 
>> On 02/03/2016 08:05 PM, Jay Vosburgh wrote:
>>> Nikolay Aleksandrov <razor@blackwall.org> wrote:
>>>
>>>> From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
>>>>
>>>> Currently the bonding allows to set ad_actor_system and prio while the
>>>> bond device is down, but these are actually applied only if there aren't
>>>> any slaves yet (applied to bond device when first slave shows up, and to
>>>> slaves at 3ad bind time). After this patch changes are applied immediately
>>>> and the new values can be used/seen after the bond's upped so it's not
>>>> necessary anymore to release all and enslave again to see the changes.
>>>>
>>>> CC: Jay Vosburgh <j.vosburgh@gmail.com>
>>>> CC: Veaceslav Falico <vfalico@gmail.com>
>>>> CC: Andy Gospodarek <gospo@cumulusnetworks.com>
>>>> Signed-off-by: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
>>>
>>> 	Looks good to me.
>>>
>>> Signed-off-by: Jay Vosburgh <jay.vosburgh@canonical.com>
>>>
>>> 	-J
>>>
>>
>> Thanks Jay. Do you think it makes sense to allow setting these while the
>> bond is up ? I don't see any serious problems.
> 
> 	Actually, I was thinking about that when I read the patch.
> 
> 	Changing these while live will trigger reselection of the
> aggregator(s), since selection information in the LACPDUs will change.
> It should just work itself out when the parter system sees the change.
> 
Yes, that was my thinking as well.

> 	E.g., if bonding received a LACPDU with a changed _prio or
> _system, __update_selected will clear AD_PORT_SELECTED if it doesn't
> match, and that will cascade through the state machine (in
> ad_mux_machine, COLLECTING_DISTRIBUTING state will revert to
> MUX_ATTACHED, which will clear COLL_DIST and go from there).
> 
> 	I think it may converge more quickly if bonding set ->ntt on the
> ports after the change to immediately send new LACPDUs (rather than
> waiting for the LACP timeout), but that's an optimization.  If the _prio
> or _system are set to the same values they had previously, this is
> harmless as the partner system shouldn't reselect if nothing in the
> LACPDU changed.
> 
Good point, will look into it.

> 	There's a similar optimization in bond_3ad_unbind_slave to send
> a LACPDU with AGGREGATION cleared to speed up the LACP processing on the
> partner system.
> 
> 	-J
> 
> ---
> 	-Jay Vosburgh, jay.vosburgh@canonical.com
> 

Okay then, I'll give it a try and will post a patch.

Thank you,
 Nik
