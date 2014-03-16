From: Veaceslav Falico <vfalico@redhat.com>
Subject: Re: [PATCH net-next] bonding: net_ratelimit() pr_warn()s in 802.3ad
 mode
Date: Sun, 16 Mar 2014 17:50:34 +0100
Message-ID: <20140316165034.GC30498@redhat.com>
References: <1394987380-15765-1-git-send-email-vfalico@redhat.com>
 <1394988315.9668.33.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Cc: netdev@vger.kernel.org, Jay Vosburgh <fubar@us.ibm.com>,
	Andy Gospodarek <andy@greyhouse.net>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:4624 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752187AbaCPQup (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 16 Mar 2014 12:50:45 -0400
Content-Disposition: inline
In-Reply-To: <1394988315.9668.33.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Mar 16, 2014 at 09:45:15AM -0700, Eric Dumazet wrote:
>On Sun, 2014-03-16 at 17:29 +0100, Veaceslav Falico wrote:
>
>> @@ -1559,7 +1560,7 @@ static void ad_agg_selection_logic(struct aggregator *agg)
>>  		}
>>
>>  		/* check if any partner replys */
>> -		if (best->is_individual) {
>> +		if (best->is_individual && net_ratelimit()) {
>
>This looks odd, to mix conditions that are not of the same domain.

It indeed looks odd and kinda hard to read.

>
>Have you considered using pr_warn_ratelimited() ?

Nice, didn't know (or forgot...) about that function.

Thanks, will use it and re-send.

>
>>  			pr_warn("%s: Warning: No 802.3ad response from the link partner for any adapters in the bond\n",
>>  				best->slave ?
>>  				best->slave->bond->dev->name : "NULL");
>> @@ -2080,7 +2081,7 @@ void bond_3ad_state_machine_handler(struct work_struct *work)
>
>
>
>
