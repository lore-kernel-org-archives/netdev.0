From: Wei Yang <weiyang@linux.vnet.ibm.com>
Subject: Re: [Patch net-next] pktgen: small code cleanup
Date: Fri, 4 Apr 2014 21:29:51 +0800
Message-ID: <20140404132951.GA5969@richard>
References: <1396427091-8230-1-git-send-email-weiyang@linux.vnet.ibm.com>
 <20140403.133525.1594438930436435429.davem@davemloft.net>
Reply-To: Wei Yang <weiyang@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: weiyang@linux.vnet.ibm.com, fan.du@windriver.com,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e23smtp05.au.ibm.com ([202.81.31.147]:46745 "EHLO
	e23smtp05.au.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752473AbaDDN37 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 4 Apr 2014 09:29:59 -0400
Received: from /spool/local
	by e23smtp05.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <weiyang@linux.vnet.ibm.com>;
	Fri, 4 Apr 2014 23:29:56 +1000
Received: from d23relay03.au.ibm.com (d23relay03.au.ibm.com [9.190.235.21])
	by d23dlp03.au.ibm.com (Postfix) with ESMTP id 4E810357804F
	for <netdev@vger.kernel.org>; Sat,  5 Apr 2014 00:29:54 +1100 (EST)
Received: from d23av03.au.ibm.com (d23av03.au.ibm.com [9.190.234.97])
	by d23relay03.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id s34DTdxK7143806
	for <netdev@vger.kernel.org>; Sat, 5 Apr 2014 00:29:40 +1100
Received: from d23av03.au.ibm.com (localhost [127.0.0.1])
	by d23av03.au.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id s34DTrBh022375
	for <netdev@vger.kernel.org>; Sat, 5 Apr 2014 00:29:53 +1100
Content-Disposition: inline
In-Reply-To: <20140403.133525.1594438930436435429.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Apr 03, 2014 at 01:35:25PM -0400, David Miller wrote:
>From: Wei Yang <weiyang@linux.vnet.ibm.com>
>Date: Wed,  2 Apr 2014 16:24:51 +0800
>
>> Print the warning when the format is not correct.
>> 
>> Signed-off-by: Wei Yang <weiyang@linux.vnet.ibm.com>
>> ---
>>  net/core/pktgen.c |    2 +-
>>  1 file changed, 1 insertion(+), 1 deletion(-)
>> 
>> diff --git a/net/core/pktgen.c b/net/core/pktgen.c
>> index fdac61c..89d33c2 100644
>> --- a/net/core/pktgen.c
>> +++ b/net/core/pktgen.c
>> @@ -1767,7 +1767,7 @@ static ssize_t pktgen_thread_write(struct file *file,
>>  	char *pg_result;
>>  
>>  	if (count < 1) {
>> -		//      sprintf(pg_result, "Wrong command format");
>> +		pr_warn("WARNING: Wrong command format in %s\n", __func__);
>>  		return -EINVAL;
>>  	}
>>  
>
>I don't think a kernel log message is appropriate.
>
>The intention, as per the comment protected code, was to make this
>error message show up in show_results()'s output.

Agree, I guess the author originally intended to put this warning and shows in
show_results(). While since there is a chance that at this moment that the
pktgen_thread doesn't exist, then can't put into the results.

I did a search and try to find who introduce this code. Finally found this
commit 
        e051211 [NET]: pktgen update
in git repo:
        git://git.kernel.org/pub/scm/linux/kernel/git/tglx/history.git

Unfortunately, this looks like a typo and author forgot to remove it.

At the mean time, I found in proc_if_write(), it print a kernel log message
when the format is not correct. From this log, it shows originally it tried to
save the warning message in the "reslut", but I don't know why it change to
just print a kernel log.

This code is preserved till now in pktgen_if_write(). Actually, I think in
this place we could save it in the pg_result.

So, my suggestion is:
1. in pktgen_thread_write(), remove the code which is commented out
2. in pktgen_if_write(), save warning message in pg_result

Hope my understanding is correct, if not, please let me know :-)

>
>I'm not applying this, sorry.

-- 
Richard Yang
Help you, Help me
