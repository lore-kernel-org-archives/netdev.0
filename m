From: Ido Schimmel <idosch@mellanox.com>
Subject: Re: [PATCH net 3/3] Documentation: networking: dsa: Describe
 port_vlan_filtering
Date: Tue, 24 May 2016 18:09:59 +0300
Message-ID: <20160524150959.GB13430@colbert.mtl.com>
References: <1464064337-8743-1-git-send-email-f.fainelli@gmail.com>
 <1464064337-8743-4-git-send-email-f.fainelli@gmail.com>
 <871t4rsf0e.fsf@ketchup.mtl.sfl>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Florian Fainelli <f.fainelli@gmail.com>, <netdev@vger.kernel.org>,
	<davem@davemloft.net>, <andrew@lunn.ch>
To: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-db3on0081.outbound.protection.outlook.com ([157.55.234.81]:18944
	"EHLO emea01-db3-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751497AbcEXPLy (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 24 May 2016 11:11:54 -0400
Content-Disposition: inline
In-Reply-To: <871t4rsf0e.fsf@ketchup.mtl.sfl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Vivien, Florian,

Tue, May 24, 2016 at 05:32:33PM IDT, vivien.didelot@savoirfairelinux.com wrote:
>Hi Florian,
>
>Florian Fainelli <f.fainelli@gmail.com> writes:
>
>> Described what the port_vlan_filtering function is supposed to
>> accomplish.
>>
>> Fixes: fb2dabad69f0 ("net: dsa: support VLAN filtering switchdev attr")
>> Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
>> ---
>>  Documentation/networking/dsa/dsa.txt | 6 ++++++
>>  1 file changed, 6 insertions(+)
>>
>> diff --git a/Documentation/networking/dsa/dsa.txt b/Documentation/networking/dsa/dsa.txt
>> index 411b57fd73aa..a42fd2ec32a5 100644
>> --- a/Documentation/networking/dsa/dsa.txt
>> +++ b/Documentation/networking/dsa/dsa.txt
>> @@ -535,6 +535,12 @@ Bridge layer
>>  Bridge VLAN filtering
>>  ---------------------
>>  
>> +- port_vlan_filtering: bridge layer function invoked when the bridge gets
>> +  configured for turning on or off VLAN filtering. If nothing specific needs to
>> +  be done at the hardware level, 0 must be returned. When VLAN filtering is
>> +  turned on, the hardware must be programmed with rejecting non-802.1Q frames,
>> +  when turned off the switch must accept any 802.1Q frames.
>
>Note that port_vlan_filtering is optional so a driver don't need to
>implement it if nothing specific needs to be done at the hardware level.
>
>Also I'd think that with VLAN filtering on, the hardware must not reject
>untagged frames, only 802.1Q frames which don't respect the programmed
>VLAN rules.

With VLAN filtering on I believe you only need to reject untagged frames
when there's no PVID on the port. See __allowed_ingress() in
net/bridge/br_vlan.c
