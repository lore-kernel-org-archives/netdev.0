From: Yang Yingliang <yangyingliang@huawei.com>
Subject: Re: [PATCH iproute2 v2] fq: allow options of fair queue set to ~0U
Date: Tue, 13 May 2014 12:10:38 +0800
Message-ID: <53719B3E.5040706@huawei.com>
References: <1399868319-2184-1-git-send-email-yangyingliang@huawei.com>		 <1399874336.7973.17.camel@edumazet-glaptop2.roam.corp.google.com>		 <5370713F.7040701@huawei.com>	 <1399908225.7973.25.camel@edumazet-glaptop2.roam.corp.google.com>	 <53718221.6040909@huawei.com> <1399950239.7973.38.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <stephen@networkplumber.org>, <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga02-in.huawei.com ([119.145.14.65]:60816 "EHLO
	szxga02-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750743AbaEMELJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 May 2014 00:11:09 -0400
In-Reply-To: <1399950239.7973.38.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2014/5/13 11:03, Eric Dumazet wrote:
> On Tue, 2014-05-13 at 10:23 +0800, Yang Yingliang wrote:
>> From: Yang Yingliang <yangyingliang@huawei.com>
>>
>> Some options of fair queue cannot be (~0U). It leads to maxrate
>> cannot be reset to unlimited because it cannot be (~0U).
>>
>> Suggested-by: Eric Dumazet <edumazet@google.com>
>> Signed-off-by: Yang Yingliang <yangyingliang@huawei.com>
>> ---
>>  tc/q_fq.c | 36 ++++++++++++++++++++++++------------
>>  1 file changed, 24 insertions(+), 12 deletions(-)
>>
>> diff --git a/tc/q_fq.c b/tc/q_fq.c
>> index c1f658e..6a493a5 100644
>> --- a/tc/q_fq.c
>> +++ b/tc/q_fq.c
>> @@ -71,13 +71,19 @@ static unsigned int ilog2(unsigned int val)
>>  static int fq_parse_opt(struct qdisc_util *qu, int argc, char **argv,
>>  			struct nlmsghdr *n)
>>  {
>> -	unsigned int plimit = ~0U;
>> -	unsigned int flow_plimit = ~0U;
>> -	unsigned int quantum = ~0U;
>> -	unsigned int initial_quantum = ~0U;
>> +	unsigned int plimit;
>> +	unsigned int flow_plimit;
>> +	unsigned int quantum;
>> +	unsigned int initial_quantum;
>>  	unsigned int buckets = 0;
>> -	unsigned int maxrate = ~0U;
>> -	unsigned int defrate = ~0U;
>> +	unsigned int maxrate;
>> +	unsigned int defrate;
>> +	int set_plimit = 0;
>> +	int set_flow_plimit = 0;
>> +	int set_quantum = 0;
>> +	int set_initial_quantum = 0;
>> +	int set_maxrate = 0;
>> +	int set_defrate = 0;
>>  	int pacing = -1;
>>  	struct rtattr *tail;
>>  
>> @@ -88,12 +94,14 @@ static int fq_parse_opt(struct qdisc_util *qu, int argc, char **argv,
>>  				fprintf(stderr, "Illegal \"limit\"\n");
>>  				return -1;
>>  			}
>> +			set_plimit = 1;
>>  		} else if (strcmp(*argv, "flow_limit") == 0) {
>>  			NEXT_ARG();
>>  			if (get_unsigned(&flow_plimit, *argv, 0)) {
>>  				fprintf(stderr, "Illegal \"flow_limit\"\n");
>>  				return -1;
>>  			}
>> +			set_flow_plimit = 0;
> 
> 
> = 1; ?
> 
Yes, thanks!
