From: David Ahern <dsa@cumulusnetworks.com>
Subject: Re: [PATCH] net: ipv6: Make address flushing on ifdown optional
Date: Tue, 16 Feb 2016 20:45:58 -0700
Message-ID: <56C3ECF6.9090103@cumulusnetworks.com>
References: <1455402207-9217-1-git-send-email-dsa@cumulusnetworks.com>
 <56C2E1BD.30006@miraclelinux.com> <56C33D5F.2060005@cumulusnetworks.com>
 <56C3D6A3.7030605@miraclelinux.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-2022-jp
Content-Transfer-Encoding: 7bit
Cc: hannes@stressinduktion.org
To: YOSHIFUJI Hideaki <hideaki.yoshifuji@miraclelinux.com>,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f178.google.com ([209.85.223.178]:34891 "EHLO
	mail-io0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965182AbcBQDqB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Feb 2016 22:46:01 -0500
Received: by mail-io0-f178.google.com with SMTP id g203so20088967iof.2
        for <netdev@vger.kernel.org>; Tue, 16 Feb 2016 19:46:00 -0800 (PST)
In-Reply-To: <56C3D6A3.7030605@miraclelinux.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2/16/16 7:10 PM, YOSHIFUJI Hideaki wrote:
> Hi,
> 
> David Ahern wrote:
>> On 2/16/16 1:45 AM, YOSHIFUJI Hideaki wrote:
>>>> diff --git a/Documentation/networking/ip-sysctl.txt b/Documentation/networking/ip-sysctl.txt
>>>> index 24ce97f42d35..7ddbbb67f0db 100644
>>>> --- a/Documentation/networking/ip-sysctl.txt
>>>> +++ b/Documentation/networking/ip-sysctl.txt
>>>> @@ -1563,6 +1563,12 @@ temp_prefered_lft - INTEGER
>>>>    	Preferred lifetime (in seconds) for temporary addresses.
>>>>    	Default: 86400 (1 day)
>>>>    
>>>> +keep_addr_on_down - BOOLEAN
>>>> +	Keep all IPv6 addresses on an interface down event. If set static
>>>> +	global addresses with no expiration time are not flushed.
>>>> +
>>>> +	Default: disabled
>>>> +
>>>
>>> How about this:
>>>      1: enabled
>>>      0: system default
>>>     -1: disabled
>>> so that an iterface can override system-wide config?
>>
>> It is my understanding that the 'all' settings override the individual
>> interface settings. From Documentation/networking/ip-sysctl.txt +1346:
>>
>> conf/all/*:
>>          Change all the interface-specific settings.
> 
> Well, document is not correct.
> 1) Some of "all" variables set all interface specific settings.
> 2) Some of "all" variables override interface specific settings.
> 3) Some provide "fall-back" values; such an interface specific
>     setting overrides the corresponding "all" variable.
>     (Note: "default" variables are values per-interface settings
>     are initialized to.)
> 4) Others are ignored (the exists but no-ops).

Seems like a nightmare for an admin to understand which ones fall into
which category.

I really don't have a preference here beyond having the feature and
making it easy to enable (e.g., enable 'all' and it works for all). If
you want the 1/0/-1 trio and allow individual netdev settings to
override all then I will update the patch.

Thanks,
David
