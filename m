From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
Subject: Re: [BUG] "$ ss -a" incorrectly displays raw sockets as udp sockets
Date: Thu, 09 Jul 2015 17:30:39 +0200
Message-ID: <559E939F.8030307@cumulusnetworks.com>
References: <559E8178.9080808@beyondsemi.com> <1436454853.24939.31.camel@edumazet-glaptop2.roam.corp.google.com> <1436455270.24939.32.camel@edumazet-glaptop2.roam.corp.google.com> <20150709152804.GA16132@angus-think.lan>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: Miha Marolt <miham@beyondsemi.com>, netdev@vger.kernel.org
To: Vadim Kochan <vadim4j@gmail.com>,
	Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f181.google.com ([209.85.212.181]:37370 "EHLO
	mail-wi0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751125AbbGIPb1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Jul 2015 11:31:27 -0400
Received: by wiclp1 with SMTP id lp1so112751145wic.0
        for <netdev@vger.kernel.org>; Thu, 09 Jul 2015 08:31:26 -0700 (PDT)
In-Reply-To: <20150709152804.GA16132@angus-think.lan>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 07/09/2015 05:28 PM, Vadim Kochan wrote:
> On Thu, Jul 09, 2015 at 05:21:10PM +0200, Eric Dumazet wrote:
>> On Thu, 2015-07-09 at 17:14 +0200, Eric Dumazet wrote:
>>
>>>
>>> If I checkout iproute2 tree to db08bdb816d337102c5486744008db9c9faa43bf
>>> (before buggy commit) we indeed had this result :
>>>
>>> # ./ss -an | grep 127.0.0.1
>>> raw    UNCONN     213486 0      127.0.0.1:6                     *:*                  
>>
>> Maybe following patch would fix the issue.
>>
>> diff --git a/misc/ss.c b/misc/ss.c
>> index 03f92fa69270..9b7dad00290c 100644
>> --- a/misc/ss.c
>> +++ b/misc/ss.c
>> @@ -1552,6 +1552,8 @@ out:
>>  static char *proto_name(int protocol)
>>  {
>>  	switch (protocol) {
>> +	case 0:
>> +		return "raw";
>>  	case IPPROTO_UDP:
>>  		return "udp";
>>  	case IPPROTO_TCP:
>> @@ -2416,7 +2418,7 @@ static int dgram_show_line(char *line, const struct filter *f, int family)
>>  	if (n < 9)
>>  		opt[0] = 0;
>>  
>> -	inet_stats_print(&s, IPPROTO_UDP);
>> +	inet_stats_print(&s, 0);
>>  
>>  	if (show_details && opt[0])
>>  		printf(" opt:\"%s\"", opt);
>>
>>
> 
> Yes, it fixes the issue too.

Yeah, I think this is better than my solution because it's not really
IPPROTO_RAW protocol, so I'll drop my submission.

Thanks,
 Nik
