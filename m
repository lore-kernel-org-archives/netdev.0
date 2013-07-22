From: Thomas-Mich Richter <tmricht@linux.vnet.ibm.com>
Subject: Re: [PATCH 2/2 V2] macvlan fdb replace support
Date: Mon, 22 Jul 2013 15:16:14 +0200
Message-ID: <51ED309E.80201@linux.vnet.ibm.com>
References: <1374247208-8226-1-git-send-email-tmricht@linux.vnet.ibm.com> <1374247208-8226-2-git-send-email-tmricht@linux.vnet.ibm.com> <20130719091855.6c763231@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, davem@davemloft.net
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e06smtp11.uk.ibm.com ([195.75.94.107]:48889 "EHLO
	e06smtp11.uk.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754768Ab3GVNQa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Jul 2013 09:16:30 -0400
Received: from /spool/local
	by e06smtp11.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <tmricht@linux.vnet.ibm.com>;
	Mon, 22 Jul 2013 14:10:20 +0100
Received: from b06cxnps3074.portsmouth.uk.ibm.com (d06relay09.portsmouth.uk.ibm.com [9.149.109.194])
	by d06dlp03.portsmouth.uk.ibm.com (Postfix) with ESMTP id 328F71B08072
	for <netdev@vger.kernel.org>; Mon, 22 Jul 2013 14:16:16 +0100 (BST)
Received: from d06av04.portsmouth.uk.ibm.com (d06av04.portsmouth.uk.ibm.com [9.149.37.216])
	by b06cxnps3074.portsmouth.uk.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r6MDG4hG59113642
	for <netdev@vger.kernel.org>; Mon, 22 Jul 2013 13:16:04 GMT
Received: from d06av04.portsmouth.uk.ibm.com (localhost [127.0.0.1])
	by d06av04.portsmouth.uk.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id r6MDGEww007863
	for <netdev@vger.kernel.org>; Mon, 22 Jul 2013 07:16:15 -0600
In-Reply-To: <20130719091855.6c763231@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 07/19/2013 06:18 PM, Stephen Hemminger wrote:
> On Fri, 19 Jul 2013 17:20:08 +0200
> Thomas Richter <tmricht@linux.vnet.ibm.com> wrote:
>=20
>> Add support for iproute2 command 'bridge fdb replace ...'.
>> The rtnletlink call back function ndo_fdb_add will be called
>> with the NLM_F_REPLACE flag set.
>> Simply return -EOPNOTSUP.
>>
>> Resubmitted because net-next was closed last week.
>>
>> Signed-off-by: Thomas Richter <tmricht@linux.vnet.ibm.com>
>> ---
>>  drivers/net/macvlan.c | 3 +++
>>  1 file changed, 3 insertions(+)
>>
>> diff --git a/drivers/net/macvlan.c b/drivers/net/macvlan.c
>> index 18373b6..74907f5 100644
>> --- a/drivers/net/macvlan.c
>> +++ b/drivers/net/macvlan.c
>> @@ -597,6 +597,9 @@ static int macvlan_fdb_add(struct ndmsg *ndm, st=
ruct nlattr *tb[],
>>  	if (!vlan->port->passthru)
>>  		return -EOPNOTSUPP;
>> =20
>> +	if (flags & NLM_F_REPLACE)
>> +		return -EOPNOTSUPP;
>> +
>>  	if (is_unicast_ether_addr(addr))
>>  		err =3D dev_uc_add_excl(dev, addr);
>>  	else if (is_multicast_ether_addr(addr))
>=20
> What about bridge that also uses netlink FDB interface?
>=20
The bridge function br_fdb_add() calls fdb_add_entry().
There is no need to check flag NLM_F_REPLACE.
The code already changes an entry if it is found
in the fdb. If the entry is missing in the
fdb, it is added when flag NLM_F_CREATE is set.


--=20
Thomas Richter, Dept 3250, IBM LTC Boeblingen, Data Center Networking
--
Vorsitzende des Aufsichtsrats: Martina Koederitz=20
Gesch=E4ftsf=FChrung: Dirk Wittkopp
Sitz der Gesellschaft: B=F6blingen / Registergericht: Amtsgericht Stutt=
gart, HRB 243294
