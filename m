From: David Ahern <dsa@cumulusnetworks.com>
Subject: Re: VRF_DEVICE integration plan
Date: Mon, 2 May 2016 11:43:46 -0600
Message-ID: <572791D2.9050701@cumulusnetworks.com>
References: <AT5PR84MB00652788CA3C3F63146F9C08CA610@AT5PR84MB0065.NAMPRD84.PROD.OUTLOOK.COM>
 <571D5720.7000908@cumulusnetworks.com>
 <CS1PR84MB0072AC62E9EBCC5A42E33952CA650@CS1PR84MB0072.NAMPRD84.PROD.OUTLOOK.COM>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "Kumara, Shantha (HP Networking)" <shantha.kumara@hpe.com>,
	"Govindan Nair, Anoop" <anoop.g@hpe.com>
To: "Elluru, Krishna Mohan" <elluru.kri.mohan@hpe.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f179.google.com ([209.85.223.179]:34033 "EHLO
	mail-io0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754224AbcEBRnt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 May 2016 13:43:49 -0400
Received: by mail-io0-f179.google.com with SMTP id 190so169643458iow.1
        for <netdev@vger.kernel.org>; Mon, 02 May 2016 10:43:49 -0700 (PDT)
In-Reply-To: <CS1PR84MB0072AC62E9EBCC5A42E33952CA650@CS1PR84MB0072.NAMPRD84.PROD.OUTLOOK.COM>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 4/28/16 11:16 AM, Elluru, Krishna Mohan wrote:
>
> I posted a few bug fix patches a week or two ago. Not sure what the
> status is with respect to 4.3 - 4.5 trees.
>
> MOHAN> Sure. Are those patches sent over netdev mailer list?

yes. All patches for VRF - kernel and iproute2 - are sent to netdev.


> MOHAN> sorry for not being clear. My ask was, to create a namespace w=
e need cap_admin privileges currently, but your earlier mails suggested=
 that we should be able to configure/create vrf device with net_admin c=
apabilities. Is this support present /expected to be added soon?

VRF is implemented using a netdevice. As such the ability to create one=
=20
requires the same permissions as creating any other netdevice=20
(CAP_NET_ADMIN).


>> 5. Is there a possibility of enabling secondary level lookup, to giv=
e a leak functionality to parent route table from device local route ta=
ble? I tested with veth pair, configured one as default gateway, it is =
possible to forward traffic b/w the interfaces, looking for cleaner met=
hod.
>
> Are you referring to inter-vrf routing? See slide 27
> http://www.netdevconf.org/1.1/proceedings/slides/ahern-vrf-tutorial.p=
df
> Full lookup in VRF table
> =E2=96=AA ip route add table vrf-red 1.1.1.0/24 dev vrf-green
> MOHAN> In slide 27 above shows inter vrf routing, requirement is to u=
se current namespace global route table if the ip lookup fails in vrf-d=
evice routing table.
> Reference: https://www.juniper.net/techpubs/en_US/junose16.1/topics/t=
ask/configuration/mbgp-secondary-routing-table-search.html

One solution is to create a VRF device that is associated with the main=
=20
table and then use an inter-vrf route to jump to the main table.

VRF tables do need a default route (e.g., unreachable with high metric=20
value) else the FIB lookups will proceed to the next table which is mos=
t=20
likely not what you want.


David
