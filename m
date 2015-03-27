From: David Ahern <dsahern@gmail.com>
Subject: Re: [PATCH 3/3] iproute2: Add support for phys_port_name
Date: Thu, 26 Mar 2015 21:41:33 -0600
Message-ID: <5514D16D.5010205@gmail.com>
References: <1426520818-11198-1-git-send-email-dsahern@gmail.com>	<1426520818-11198-3-git-send-email-dsahern@gmail.com> <20150324155015.2dae6252@urahara>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f169.google.com ([209.85.213.169]:37474 "EHLO
	mail-ig0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752411AbbC0Dlk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Mar 2015 23:41:40 -0400
Received: by igcxg11 with SMTP id xg11so10070328igc.0
        for <netdev@vger.kernel.org>; Thu, 26 Mar 2015 20:41:40 -0700 (PDT)
In-Reply-To: <20150324155015.2dae6252@urahara>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 3/24/15 4:50 PM, Stephen Hemminger wrote:
>> diff --git a/ip/ipaddress.c b/ip/ipaddress.c
>> index 99a6ab5977e3..9e65015b7a48 100644
>> --- a/ip/ipaddress.c
>> +++ b/ip/ipaddress.c
>> @@ -645,6 +645,9 @@ int print_linkinfo(const struct sockaddr_nl *who,
>>   				      b1, sizeof(b1)));
>>   	}
>>
>> +	if (tb[IFLA_PHYS_PORT_NAME])
>> +		fprintf(fp, "port name %s ", rta_getattr_str(tb[IFLA_PHYS_PORT_NAME]));
>> +
>>   	if (tb[IFLA_OPERSTATE])
>>   		print_operstate(fp, rta_getattr_u8(tb[IFLA_OPERSTATE]));
>>
>
> In general, this is a good idea, but there are several of issues.
> 1. There are programs that parse ip route output, therefore all new
>     fields need to go at the end.
> 2. The two word format 'port name' does not match other parts
> 3. Extra stuff usually goes int 'details' section
> 4. There are VPN scripts etc that expect all ip commands to
>     be invertable. I.e the output of ip link should also be easily
>     convertable to input.

The location of PORT_NAME is right after PORT_ID. I take it from this 
list you want it elsewhere. At the end?

And rather than 'port name' how about 'port-name'? no precedence for 
CamelCase and both 'port' and 'name' are too generic. 'pname' is not 
intuitive. Suggestions?

David
