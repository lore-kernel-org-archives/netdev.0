From: Yang Yingliang <yangyingliang@huawei.com>
Subject: Re: [PATCH iproute2 2/2] netem: add 64bit rates support
Date: Thu, 16 Jan 2014 10:28:59 +0800
Message-ID: <52D743EB.9010701@huawei.com>
References: <1389778932-17404-1-git-send-email-yangyingliang@huawei.com>	 <1389778932-17404-3-git-send-email-yangyingliang@huawei.com> <1389801367.31367.345.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <stephen@networkplumber.org>, <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga02-in.huawei.com ([119.145.14.65]:64299 "EHLO
	szxga02-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751314AbaAPCaV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Jan 2014 21:30:21 -0500
In-Reply-To: <1389801367.31367.345.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2014/1/15 23:56, Eric Dumazet wrote:
> On Wed, 2014-01-15 at 17:42 +0800, Yang Yingliang wrote:
>> netem support 64bit rates start from linux-3.13.
>> Add 64bit rates support in tc tools.
>>
>> tc qdisc show dev eth0
>> qdisc netem 1: dev eth4 root refcnt 2 limit 1000 rate 35Gbit
>>
>> Signed-off-by: Yang Yingliang <yangyingliang@huawei.com>
>> ---
>>  tc/q_netem.c | 29 ++++++++++++++++++++++++-----
>>  1 file changed, 24 insertions(+), 5 deletions(-)
>>
[...]
>>  
>>  	if (dist_data) {
>>  		if (addattr_l(n, MAX_DIST * sizeof(dist_data[0]),
>> @@ -522,6 +532,7 @@ static int netem_print_opt(struct qdisc_util *qu, FILE *f, struct rtattr *opt)
>>  	struct tc_netem_qopt qopt;
>>  	const struct tc_netem_rate *rate = NULL;
>>  	int len = RTA_PAYLOAD(opt) - sizeof(qopt);
>> +	__u64 *rate64 = NULL;
> 
> __u64 rate64 = 0;
> 
>>  	SPRINT_BUF(b1);
>>  
>>  	if (opt == NULL)
>> @@ -572,6 +583,11 @@ static int netem_print_opt(struct qdisc_util *qu, FILE *f, struct rtattr *opt)
>>  				return -1;
>>  			ecn = RTA_DATA(tb[TCA_NETEM_ECN]);
>>  		}
>> +		if (tb[TCA_NETEM_RATE64]) {
>> +			if (RTA_PAYLOAD(tb[TCA_NETEM_RATE64]) < sizeof(*rate64))
>> +				return -1;
>> +			rate64 = RTA_DATA(tb[TCA_NETEM_RATE64]);
> 
> rate64 = rta_getattr_u64(tb[TCA_NETEM_RATE64]);

It looks better, I'll send a v2.

Thanks!
