From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH] NET: catch signed nla_len() retval in tcf_simp_init()
Date: Thu, 17 Apr 2008 06:55:35 +0200
Message-ID: <4806D847.2030806@trash.net>
References: <4806C501.20300@tiscali.nl> <20080416.213712.78410382.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------010509000709090900030409"
Cc: 12o3l@tiscali.nl, hadi@cyberus.ca, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1754730AbYDQEzw@vger.kernel.org>
In-Reply-To: <20080416.213712.78410382.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------010509000709090900030409
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit

David Miller wrote:
> From: Roel Kluin <12o3l@tiscali.nl>
> Date: Thu, 17 Apr 2008 05:33:21 +0200
> 
>> 'datalen' is unsigned, use 'ret' instead to catch a negative return value.
>>
>> Signed-off-by: Roel Kluin <12o3l@tiscali.nl>
>> ---
>> diff --git a/net/sched/act_simple.c b/net/sched/act_simple.c
>> index fbde461..b78d015 100644
>> --- a/net/sched/act_simple.c
>> +++ b/net/sched/act_simple.c
>> @@ -114,9 +114,10 @@ static int tcf_simp_init(struct nlattr *nla, struct nlattr *est,
>>  	if (defdata == NULL)
>>  		return -EINVAL;
>>  
>> -	datalen = nla_len(tb[TCA_DEF_DATA]);
>> -	if (datalen <= 0)
>> +	ret = nla_len(tb[TCA_DEF_DATA]);
>> +	if (ret <= 0)
>>  		return -EINVAL;
>> +	datalen = ret;
>>  
>>  	pc = tcf_hash_check(parm->index, a, bind, &simp_hash_info);
>>  	if (!pc) {
> 
> This clobbers 'ret' which is compared to ACT_P_CREATED
> later in the function.  If the !pc branch below this code
> is not taken, ret must be left at it's initial value of
> zero.  Now, it will take on some non-zero positive value
> which is not correct.

The change is also unnecessary because the attribute was
already validated and the length can not be less than zero.

This patch changes it to only check for zero length.

Signed-off-by: Patrick McHardy <kaber@trash.net>


--------------010509000709090900030409
Content-Type: text/plain;
 name="x"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="x"

diff --git a/net/sched/act_simple.c b/net/sched/act_simple.c
index fbde461..64b2d13 100644
--- a/net/sched/act_simple.c
+++ b/net/sched/act_simple.c
@@ -115,7 +115,7 @@ static int tcf_simp_init(struct nlattr *nla, struct nlattr *est,
 		return -EINVAL;
 
 	datalen = nla_len(tb[TCA_DEF_DATA]);
-	if (datalen <= 0)
+	if (datalen == 0)
 		return -EINVAL;
 
 	pc = tcf_hash_check(parm->index, a, bind, &simp_hash_info);

--------------010509000709090900030409--
