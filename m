From: Thomas-Mich Richter <tmricht@linux.vnet.ibm.com>
Subject: Re: [PATCH 1/2] vxlan fdb replace an existing entry
Date: Fri, 12 Jul 2013 09:18:30 +0200
Message-ID: <51DFADC6.2050309@linux.vnet.ibm.com>
References: <1373538500-10629-1-git-send-email-tmricht@linux.vnet.ibm.com> <20130711085638.75690edf@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e06smtp10.uk.ibm.com ([195.75.94.106]:58608 "EHLO
	e06smtp10.uk.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757132Ab3GLHSf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Jul 2013 03:18:35 -0400
Received: from /spool/local
	by e06smtp10.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <tmricht@linux.vnet.ibm.com>;
	Fri, 12 Jul 2013 08:15:58 +0100
Received: from b06cxnps3074.portsmouth.uk.ibm.com (d06relay09.portsmouth.uk.ibm.com [9.149.109.194])
	by d06dlp01.portsmouth.uk.ibm.com (Postfix) with ESMTP id E374117D805C
	for <netdev@vger.kernel.org>; Fri, 12 Jul 2013 08:20:06 +0100 (BST)
Received: from d06av03.portsmouth.uk.ibm.com (d06av03.portsmouth.uk.ibm.com [9.149.37.213])
	by b06cxnps3074.portsmouth.uk.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r6C7IKt254198316
	for <netdev@vger.kernel.org>; Fri, 12 Jul 2013 07:18:20 GMT
Received: from d06av03.portsmouth.uk.ibm.com (localhost [127.0.0.1])
	by d06av03.portsmouth.uk.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id r6C7IUGX013501
	for <netdev@vger.kernel.org>; Fri, 12 Jul 2013 01:18:31 -0600
In-Reply-To: <20130711085638.75690edf@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 07/11/2013 05:56 PM, Stephen Hemminger wrote:
> On Thu, 11 Jul 2013 12:28:19 +0200
> Thomas Richter <tmricht@linux.vnet.ibm.com> wrote:
>=20
>> Add support to replace an existing entry found in the
>> vxlan fdb database. The entry in question is identified
>> by its unicast mac address and the destination information
>> is changed. If the entry is not found, it is added in the
>> forwarding database. This is similar to changing an entry
>> in the neighbour table.
>>
>> Multicast mac addresses can not be changed with the replace
>> option.
>>
>> This is useful for virtual machine migration when the
>> destination of a target virtual machine changes. The replace
>> feature can be used instead of delete followed by add.
>>
>> Signed-off-by: Thomas Richter <tmricht@linux.vnet.ibm.com>
>> ---
>>  drivers/net/vxlan.c | 40 +++++++++++++++++++++++++++++++++++++++-
>>  1 file changed, 39 insertions(+), 1 deletion(-)
>>
>> diff --git a/drivers/net/vxlan.c b/drivers/net/vxlan.c
>> index 227b54a..17681c6 100644
>> --- a/drivers/net/vxlan.c
>> +++ b/drivers/net/vxlan.c
>> @@ -42,7 +42,7 @@
>>  #include <net/net_namespace.h>
>>  #include <net/netns/generic.h>
>> =20
>> -#define VXLAN_VERSION	"0.1"
>> +#define VXLAN_VERSION	"0.1tmr3"
>=20
> I am ok with everything but the weird version string.
> Just make it 0.2 or 0.1.1 if you need it

Just send a version V2 with weird version string change removed.

--=20
Thomas Richter, Dept 3250, IBM LTC Boeblingen, Data Center Networking
--
Vorsitzende des Aufsichtsrats: Martina Koederitz=20
Gesch=E4ftsf=FChrung: Dirk Wittkopp
Sitz der Gesellschaft: B=F6blingen / Registergericht: Amtsgericht Stutt=
gart, HRB 243294
