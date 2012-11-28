From: Nikolay Aleksandrov <nikolay@redhat.com>
Subject: Re: [PATCH] bonding: make arp_ip_target parameter checks consistent
 with sysfs
Date: Wed, 28 Nov 2012 17:33:56 +0100
Message-ID: <50B63CF4.8070404@redhat.com>
References: <1353759675-30511-1-git-send-email-nikolay@redhat.com> <20121128.112316.33060261620694469.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, andy@greyhouse.net, fubar@us.ibm.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:50045 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753259Ab2K1QeK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 28 Nov 2012 11:34:10 -0500
In-Reply-To: <20121128.112316.33060261620694469.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Actually I did see it from kernel/module.c and didn't come up with it 
myself.
Anyway I will re-post with the change and will take a note for the future.

Thanks for the review

On 28/11/12 17:23, David Miller wrote:
> From: Nikolay Aleksandrov<nikolay@redhat.com>
> Date: Sat, 24 Nov 2012 13:21:15 +0100
>
>> @@ -4706,12 +4706,14 @@ static int bond_check_params(struct bond_params *params)
>>   	     arp_ip_count++) {
>>   		/* not complete check, but should be good enough to
>>   		   catch mistakes */
>> -		if (!isdigit(arp_ip_target[arp_ip_count][0])) {
>> +		__be32 ip = in_aton(arp_ip_target[arp_ip_count]);
>> +		if (!isdigit(arp_ip_target[arp_ip_count][0])
>> +		    || ip == 0
>> +		    || ip == htonl(INADDR_BROADCAST)) {
> Please format this properly, put the connecting operators at the end,
> not the beginning, of the lines of the if statement, like so:
>
> 		if (!isdigit(arp_ip_target[arp_ip_count][0]) ||
> 		    ip == 0 ||
> 		    ip == htonl(INADDR_BROADCAST)) {
>
> Where else did you see the layout you used?  It's not a prevalent
> construct, so as far as I can tell you came up with it on your own.
>
> Please don't do this, and instead use existing practice as your guide.
>
> Thanks.
