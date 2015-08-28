From: David Ahern <dsa@cumulusnetworks.com>
Subject: Re: [PATCH net-next] net: FIB tracepoints
Date: Thu, 27 Aug 2015 22:12:01 -0700
Message-ID: <55DFEDA1.2070903@cumulusnetworks.com>
References: <1440737972-10468-1-git-send-email-dsa@cumulusnetworks.com>
 <20150827.220538.2154843333132928646.davem@davemloft.net>
 <55DFEC92.8050700@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f50.google.com ([209.85.220.50]:32863 "EHLO
	mail-pa0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750698AbbH1FMD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Aug 2015 01:12:03 -0400
Received: by padfo6 with SMTP id fo6so11199438pad.0
        for <netdev@vger.kernel.org>; Thu, 27 Aug 2015 22:12:02 -0700 (PDT)
In-Reply-To: <55DFEC92.8050700@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 8/27/15 10:07 PM, David Ahern wrote:
> On 8/27/15 10:05 PM, David Miller wrote:
>> From: David Ahern <dsa@cumulusnetworks.com>
>> Date: Thu, 27 Aug 2015 21:59:32 -0700
>>
>>> +        __array(    __u8,    src,    4    )
>>> +        __array(    __u8,    dst,    4    )
>>   ...
>>> +        __array(    __u8,    src,    4    )
>>
>> Maybe there is something I don't understand about tracing, but why not
>> use __u32?  If endianness types are the issue, just force cast it as
>> needed.
>>
>> Using a memcpy() on a 4-byte array is kinda excessive.
>>
>
> Silly trick need to use %pI4. ie., printing the addresses as strings vs.
> hex.

perhaps an example helps:

swapper     0 [000]   406.447548: fib:fib_table_lookup: table 255 oif 0 
iif 0 src 0.0.0.0 dst 2.1.1.2 tos 0 scope 0 flags 0

If src and dst are u32's then they print as either 0x%x or %d which is 
not intuitive. I added support to perf for the following printk formats 
with 3d199b5be53:

       %pi4 print an IPv4 address with leading zeros
       %pI4 print an IPv4 address without leading zeros
       %pi6 print an IPv6 address without colons
       %pI6 print an IPv6 address with colons
       %pI6c print an IPv6 address in compressed form with colons
       %pISpc print an IP address from a sockaddr
