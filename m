From: David Ahern <dsa@cumulusnetworks.com>
Subject: Re: [PATCH net-next 6/7] net: ipv4: return route match in GETROUTE
 request
Date: Wed, 11 Jan 2017 10:24:40 -0700
Message-ID: <103ce935-42d1-6b7c-40e5-2734df07a3ea@cumulusnetworks.com>
References: <1483997571-3964-1-git-send-email-dsa@cumulusnetworks.com>
 <1483997571-3964-7-git-send-email-dsa@cumulusnetworks.com>
 <20170110.204034.925090776724245879.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f50.google.com ([74.125.83.50]:36411 "EHLO
        mail-pg0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751949AbdAKRYn (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 11 Jan 2017 12:24:43 -0500
Received: by mail-pg0-f50.google.com with SMTP id f188so283174244pgc.3
        for <netdev@vger.kernel.org>; Wed, 11 Jan 2017 09:24:42 -0800 (PST)
In-Reply-To: <20170110.204034.925090776724245879.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 1/10/17 6:40 PM, David Miller wrote:
> From: David Ahern <dsa@cumulusnetworks.com>
> Date: Mon,  9 Jan 2017 13:32:50 -0800
> 
>> diff --git a/include/uapi/linux/rtnetlink.h b/include/uapi/linux/rtnetlink.h
>> index 8c93ad1ef9ab..471384b72cea 100644
>> --- a/include/uapi/linux/rtnetlink.h
>> +++ b/include/uapi/linux/rtnetlink.h
>> @@ -319,6 +319,8 @@ enum rtattr_type_t {
>>  	RTA_EXPIRES,
>>  	RTA_PAD,
>>  	RTA_UID,
>> +	RTA_ROUTE_GET,  /* nested attribute; route spec for RTM_GETROUTE */
>> +	RTA_ROUTE_GET_RTM, /* struct rtmsg for nested spec */
>>  	__RTA_MAX
>>  };
> 
> The nested attribute and the attributes within that nested attribute
> live in two different attribute number namespaces.
> 
> So usually we allocate the nested attribute at the top level in the
> main enumeration.  Then the elements within the nested attribute
> get allocated with a new enumeration created specifically for items
> inside that nested attribute.
> 
> For example, RTA_METRICS --> RTAX_*
> 
> So please arrange things this way.

ok. I did it this way for code re-use since the nested attribute is a route spec. If separate attributes for the nest are desired I'll do that.
