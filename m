From: Jussi Kivilinna <jussi.kivilinna@iki.fi>
Subject: Re: [PATCH iproute2] htb: report overhead attribute
Date: Mon, 03 Jun 2013 22:50:10 +0300
Message-ID: <51ACF372.9060607@iki.fi>
References: <20130529151330.22c5c89e@redhat.com> <1370207755.24311.81.camel@edumazet-glaptop> <1370208781.24311.89.camel@edumazet-glaptop> <51ACB9FE.1020100@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Jesper Dangaard Brouer <brouer@redhat.com>,
	Stephen Hemminger <stephen@networkplumber.org>,
	netdev <netdev@vger.kernel.org>
To: Rick Jones <rick.jones2@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sinikuusama.dnainternet.net ([83.102.40.134]:60808 "EHLO
	sinikuusama.dnainternet.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1759748Ab3FCTuT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 Jun 2013 15:50:19 -0400
In-Reply-To: <51ACB9FE.1020100@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 03.06.2013 18:45, Rick Jones wrote:
> On 06/02/2013 02:33 PM, Eric Dumazet wrote:
>> From: Eric Dumazet <edumazet@google.com>
>>
>> "tc class show dev ..." omits the overhead attribute for HTB.
>>
>> After patch I have :
>>
>> tc class add dev $DEV parent 1: classid 1:1 est 1sec 4sec htb \
>>      rate 12Mbit mtu 1500 quantum 1514 overhead 20
>>
>> tc class show dev $DEV
>> class htb 1:1 root prio 0 rate 12000Kbit overhead 20 ceil 12000Kbit
>> burst 1500b cburst 1500b
>>
>> Signed-off-by: Eric Dumazet <edumazet@google.com>
>> ---
>>   tc/q_htb.c |    2 ++
>>   1 file changed, 2 insertions(+)
>>
>> diff --git a/tc/q_htb.c b/tc/q_htb.c
>> index caa47c2..e6b09bb 100644
>> --- a/tc/q_htb.c
>> +++ b/tc/q_htb.c
>> @@ -264,6 +264,8 @@ static int htb_print_opt(struct qdisc_util *qu, FILE *f, struct rtattr *opt)
>>                   fprintf(f, "quantum %d ", (int)hopt->quantum);
>>           }
>>           fprintf(f, "rate %s ", sprint_rate(hopt->rate.rate, b1));
>> +        if (hopt->rate.overhead)
>> +        fprintf(f, "overhead %u ", hopt->rate.overhead);
> 
> Is it (still) possible to have a negative overhead?
> 
> http://www.linksysinfo.org/index.php?threads/speedmod-with-tc-atm-qos-patch-for-adsl.31541/
> 

You can use 'tc-stab' for negative overhead.

http://stuff.onse.fi/man?program=tc-stab&section=8

-Jussi
