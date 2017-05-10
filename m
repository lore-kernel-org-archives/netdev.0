From: Girish Moodalbail <girish.moodalbail@oracle.com>
Subject: Re: [PATCH iproute2 v2 1/1] vxlan: Add support for modifying vxlan
 device attributes
Date: Wed, 10 May 2017 00:31:27 -0700
Message-ID: <29877f9d-f6c7-5823-4ecb-4c2d1ee2b525@oracle.com>
References: <1494095863-21916-1-git-send-email-girish.moodalbail@oracle.com>
 <1494095863-21916-2-git-send-email-girish.moodalbail@oracle.com>
 <85shkgd92a.fsf@mojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: stephen@networkplumber.org, netdev@vger.kernel.org
To: Roman Mashak <mrv@mojatatu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:23443 "EHLO
        aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751890AbdEJHbX (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 10 May 2017 03:31:23 -0400
In-Reply-To: <85shkgd92a.fsf@mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 5/7/17 7:40 AM, Roman Mashak wrote:
> Girish Moodalbail <girish.moodalbail@oracle.com> writes:
>
>
> [...]
>
>>  ip/iplink_vxlan.c | 251 +++++++++++++++++++++++++++++++-----------------------
>>  1 file changed, 143 insertions(+), 108 deletions(-)
>>
>> diff --git a/ip/iplink_vxlan.c b/ip/iplink_vxlan.c
>> index b4ebb13..2bd619d 100644
>> --- a/ip/iplink_vxlan.c
>> +++ b/ip/iplink_vxlan.c
>> @@ -21,6 +21,8 @@
>>  #include "utils.h"
>>  #include "ip_common.h"
>>
>> +#define VXLAN_ATTRSET(attrs, type) (((attrs) & (1L << (type))) != 0)
>
> I think you can drop '!= 0' part in the macro.

Sure it can be done that way as well. However, I have seen both forms in use in 
iproute2 code base, so I would like to keep this as is unless you feel strongly 
about it. Furthermore, running 'checkpatch.pl --strict' on the patch didn't 
complain too.

regards,
~Girish

>
> [...]
>
>>
>> +static void check_duparg(__u64 *attrs, int type, const char *key,
>> +			 const char *argv)
>> +{
>> +	if (!VXLAN_ATTRSET(*attrs, type)) {
>> +		*attrs |= (1L << type);
>> +		return;
>> +	}
>> +	duparg2(key, argv);
>> +}
>
> [...]
>
