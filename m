From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [net-next:master 1512/1524] net/ipv4/af_inet.c:1486:26: error:
 'offt' undeclared
Date: Mon, 31 Aug 2015 11:09:40 -0700
Message-ID: <55E49864.3050102@gmail.com>
References: <201508311307.3W9KBVXz%fengguang.wu@intel.com> <20150830.224133.1682564292994363817.davem@davemloft.net> <BL2PR03MB5454539B9B4A98A341595B9E66B0@BL2PR03MB545.namprd03.prod.outlook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: "fengguang.wu@intel.com" <fengguang.wu@intel.com>,
	"kbuild-all@01.org" <kbuild-all@01.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Madalin-Cristian Bucur <madalin.bucur@freescale.com>,
	David Miller <davem@davemloft.net>,
	"raghavendra.kt@linux.vnet.ibm.com"
	<raghavendra.kt@linux.vnet.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f43.google.com ([209.85.220.43]:35349 "EHLO
	mail-pa0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753848AbbHaSMO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 31 Aug 2015 14:12:14 -0400
Received: by pacdd16 with SMTP id dd16so146740616pac.2
        for <netdev@vger.kernel.org>; Mon, 31 Aug 2015 11:12:13 -0700 (PDT)
In-Reply-To: <BL2PR03MB5454539B9B4A98A341595B9E66B0@BL2PR03MB545.namprd03.prod.outlook.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 31/08/15 05:25, Madalin-Cristian Bucur wrote:
>> -----Original Message-----
>> From: netdev-owner@vger.kernel.org [mailto:netdev-
>> Subject: Re: [net-next:master 1512/1524] net/ipv4/af_inet.c:1486:26: error:
>> 'offt' undeclared
>>
>> From: kbuild test robot <fengguang.wu@intel.com>
>> Date: Mon, 31 Aug 2015 13:06:10 +0800
>>
>>>    net/ipv4/af_inet.c: In function 'snmp_get_cpu_field64':
>>>>> net/ipv4/af_inet.c:1486:26: error: 'offt' undeclared (first use in this
>> function)
>>>       v = *(((u64 *)bhptr) + offt);
>>>                              ^
>>>    net/ipv4/af_inet.c:1486:26: note: each undeclared identifier is reported
>> only once for each function it appears in
>>>    net/ipv4/af_inet.c: In function 'snmp_fold_field64':
>>>>> net/ipv4/af_inet.c:1499:39: error: 'offct' undeclared (first use in this
>> function)
>>>       res += snmp_get_cpu_field(mib, cpu, offct, syncp_offset);
>>>                                           ^
>>>>> net/ipv4/af_inet.c:1499:10: error: too many arguments to function
>> 'snmp_get_cpu_field'
>>>       res += snmp_get_cpu_field(mib, cpu, offct, syncp_offset);
>>>              ^
>>>    net/ipv4/af_inet.c:1455:5: note: declared here
>>>     u64 snmp_get_cpu_field(void __percpu *mib, int cpu, int offt)
>>>         ^
>>>    net/ipv4/af_inet.c:1499: confused by earlier errors, bailing out
>>
>> Thanks, this should fix it:
>>
>> ====================
>> [PATCH] ipv4: Fix 32-bit build.
>>
>>    net/ipv4/af_inet.c: In function 'snmp_get_cpu_field64':
>>>> net/ipv4/af_inet.c:1486:26: error: 'offt' undeclared (first use in this
>> function)
>>       v = *(((u64 *)bhptr) + offt);
>>                              ^
>>    net/ipv4/af_inet.c:1486:26: note: each undeclared identifier is reported
>> only once for each function it appears in
>>    net/ipv4/af_inet.c: In function 'snmp_fold_field64':
>>>> net/ipv4/af_inet.c:1499:39: error: 'offct' undeclared (first use in this
>> function)
>>       res += snmp_get_cpu_field(mib, cpu, offct, syncp_offset);
>>                                           ^
>>>> net/ipv4/af_inet.c:1499:10: error: too many arguments to function
>> 'snmp_get_cpu_field'
>>       res += snmp_get_cpu_field(mib, cpu, offct, syncp_offset);
>>              ^
>>    net/ipv4/af_inet.c:1455:5: note: declared here
>>     u64 snmp_get_cpu_field(void __percpu *mib, int cpu, int offt)
>>         ^
>>
>> Reported-by: kbuild test robot <fengguang.wu@intel.com>
>> Signed-off-by: David S. Miller <davem@davemloft.net>
>> ---
>>  net/ipv4/af_inet.c | 4 ++--
>>  1 file changed, 2 insertions(+), 2 deletions(-)
>>
>> diff --git a/net/ipv4/af_inet.c b/net/ipv4/af_inet.c
>> index 0c69c0b..c2d0ebc 100644
>> --- a/net/ipv4/af_inet.c
>> +++ b/net/ipv4/af_inet.c
>> @@ -1471,7 +1471,7 @@ EXPORT_SYMBOL_GPL(snmp_fold_field);
>>
>>  #if BITS_PER_LONG==32
>>
>> -u64 snmp_get_cpu_field64(void __percpu *mib, int cpu, int offct,
>> +u64 snmp_get_cpu_field64(void __percpu *mib, int cpu, int offt,
>>  			 size_t syncp_offset)
>>  {
>>  	void *bhptr;
>> @@ -1496,7 +1496,7 @@ u64 snmp_fold_field64(void __percpu *mib, int
>> offt, size_t syncp_offset)
>>  	int cpu;
>>
>>  	for_each_possible_cpu(cpu) {
>> -		res += snmp_get_cpu_field(mib, cpu, offct, syncp_offset);
>> +		res += snmp_get_cpu_field(mib, cpu, offt, syncp_offset);
>>  	}
>>  	return res;
>>  }
>> --
>> 2.1.0
>>
>> --
> 
> Hi,
> 
> shouldn't that be snmp_get_cpu_field64() ?
> 
> -		res += snmp_get_cpu_field(mib, cpu, offct, syncp_offset);
> +		res += snmp_get_cpu_field64(mib, cpu, offt, syncp_offset);

Yes, that fixes the build for me as well and sounds like the intent.
-- 
Florian
