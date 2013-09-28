From: Sohny Thomas <sthomas@linux.vnet.ibm.com>
Subject: Re: [PATCH] iproute2: xfrm state add abort issue
Date: Sat, 28 Sep 2013 18:54:31 +0530
Message-ID: <5246D88F.7090906@linux.vnet.ibm.com>
References: <524411AE.7000404@linux.vnet.ibm.com> <52447DAC.2060701@linux.vnet.ibm.com> <AE90C24D6B3A694183C094C60CF0A2F6026B7361@saturn3.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: stephen@networkplumber.org, netdev@vger.kernel.org
To: David Laight <David.Laight@aculab.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e28smtp05.in.ibm.com ([122.248.162.5]:57830 "EHLO
	e28smtp05.in.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753498Ab3I1NYm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 28 Sep 2013 09:24:42 -0400
Received: from /spool/local
	by e28smtp05.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <sthomas@linux.vnet.ibm.com>;
	Sat, 28 Sep 2013 18:54:40 +0530
Received: from d28relay02.in.ibm.com (d28relay02.in.ibm.com [9.184.220.59])
	by d28dlp02.in.ibm.com (Postfix) with ESMTP id 3EE24394004D
	for <netdev@vger.kernel.org>; Sat, 28 Sep 2013 18:54:19 +0530 (IST)
Received: from d28av03.in.ibm.com (d28av03.in.ibm.com [9.184.220.65])
	by d28relay02.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r8SDQwvp38273146
	for <netdev@vger.kernel.org>; Sat, 28 Sep 2013 18:56:59 +0530
Received: from d28av03.in.ibm.com (localhost [127.0.0.1])
	by d28av03.in.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id r8SDOYin009258
	for <netdev@vger.kernel.org>; Sat, 28 Sep 2013 18:54:34 +0530
In-Reply-To: <AE90C24D6B3A694183C094C60CF0A2F6026B7361@saturn3.aculab.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Friday 27 September 2013 01:56 PM, David Laight wrote:
>> ip xfrm state add causes a SIGABRT due to a strncpy_chk .
>> This happens since strncpy doesn't account for the '\0' .
>> I have fixed this using sizeof  instead of strlen .
>>
>> There is a redhat bug which documents this issue
>>
>> https://bugzilla.redhat.com/show_bug.cgi?id=982761
>>
>> Signed-off-by: Sohny Thomas <sohthoma@in.ibm.com>
>>
>> --------------
>>
>> diff --git a/ip/xfrm_state.c b/ip/xfrm_state.c
>> index 389942c..7dd8799 100644
>> --- a/ip/xfrm_state.c
>> +++ b/ip/xfrm_state.c
>> @@ -117,7 +117,7 @@ static int xfrm_algo_parse(struct xfrm_algo *alg,
>> enum xfrm_attr_type_t type,
>>                               char *name, char *key, char *buf, int max)
>>     {
>>            int len;
>> -       int slen = strlen(key);
>> +       int slen = sizeof(key);
>
> you definitely don't want sizeof(key) - that is either 4 or 8.
oh damn my bad.
I think i will go with strlen(key) + 1.

or i will pass slen+1 to strncpy .

Regards,
Sohny
>
> 	David
>
>
>
>
