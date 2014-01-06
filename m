From: Daniel Borkmann <dborkman@redhat.com>
Subject: Re: [PATCH net-next] net: netdev_kobject_init: annotate with __init
Date: Mon, 06 Jan 2014 17:18:19 +0100
Message-ID: <52CAD74B.6070602@redhat.com>
References: <1388967611-14263-1-git-send-email-dborkman@redhat.com> <52CAC804.9080603@cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:60830 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754699AbaAFQS0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 6 Jan 2014 11:18:26 -0500
In-Reply-To: <52CAC804.9080603@cogentembedded.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/06/2014 04:13 PM, Sergei Shtylyov wrote:
> Hello.
>
> On 06-01-2014 4:20, Daniel Borkmann wrote:
>
>> netdev_kobject_init() is only being called from __init context,
>> that is, net_dev_init(), so annotate it with __init as well, thus
>> the kernel can take this as a hint that the function is used only
>> during the initialization phase and free up used memory resources
>> after its invocation.
>
>> Signed-off-by: Daniel Borkmann <dborkman@redhat.com>
> [...]
>
>> diff --git a/net/core/net-sysfs.h b/net/core/net-sysfs.h
>> index bd7751e..2745a1b 100644
>> --- a/net/core/net-sysfs.h
>> +++ b/net/core/net-sysfs.h
>> @@ -1,7 +1,7 @@
>>   #ifndef __NET_SYSFS_H__
>>   #define __NET_SYSFS_H__
>>
>> -int netdev_kobject_init(void);
>> +int __init netdev_kobject_init(void);
>
>     There's no need to also annotate function prototype.

Hm, is that general convention? Having this in a header file
annotated (even if not strictly necessary) would probably
better prevent from possible misuse resp. section mismatches
if people forget to look into the actual c file where the
function is being defined.

> WBR, Sergei
>
