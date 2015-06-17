From: roopa <roopa@cumulusnetworks.com>
Subject: Re: [PATCH net] ipv4: include NLM_F_APPEND flag in append route notifications
Date: Wed, 17 Jun 2015 09:20:42 -0700
Message-ID: <55819E5A.8020801@cumulusnetworks.com>
References: <1434471120-26742-1-git-send-email-roopa@cumulusnetworks.com> <CAE4R7bDnVEq1mqUmmYMFAd9CeEbn9tTzD_UnoDKYVScT5G=QJA@mail.gmail.com> <5581893E.3070609@cumulusnetworks.com> <558193C1.70001@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Scott Feldman <sfeldma@gmail.com>,
	"David S. Miller" <davem@davemloft.net>,
	Netdev <netdev@vger.kernel.org>
To: Alexander Duyck <alexander.duyck@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f182.google.com ([209.85.192.182]:35745 "EHLO
	mail-pd0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753322AbbFQQUp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Jun 2015 12:20:45 -0400
Received: by pdbnf5 with SMTP id nf5so43689789pdb.2
        for <netdev@vger.kernel.org>; Wed, 17 Jun 2015 09:20:44 -0700 (PDT)
In-Reply-To: <558193C1.70001@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 6/17/15, 8:35 AM, Alexander Duyck wrote:
>
>> @@ -1189,8 +1190,9 @@ int fib_table_insert(struct fib_table *tb, struct
>> fib_config *cfg)
>>                          fib_release_info(fi_drop);
>>                          if (state & FA_S_ACCESSED)
>> rt_cache_flush(cfg->fc_nlinfo.nl_net);
>> +                       nlflags |= NLM_F_REPLACE;
>>                          rtmsg_fib(RTM_NEWROUTE, htonl(key), new_fa, 
>> plen,
>> -                               tb->tb_id, &cfg->fc_nlinfo, 
>> NLM_F_REPLACE);
>> +                               tb->tb_id, &cfg->fc_nlinfo, nlflags);
>>
>>                          goto succeeded;
>>
>
> Why even bother modifying this part?  Is this actually needed at all, 
> are there some other flags you plan to drop into nlflags as well that 
> would be passed as a part of this message?

agreed, for the same reason my initial patch did not touch this part. 
Nope, no other flags. I was trying to meet scotts concerns.
>
>> @@ -1201,7 +1203,9 @@ int fib_table_insert(struct fib_table *tb, struct
>> fib_config *cfg)
>>                  if (fa_match)
>>                          goto out;
>>
>> -               if (!(cfg->fc_nlflags & NLM_F_APPEND))
>> +               if (cfg->fc_nlflags & NLM_F_APPEND)
>> +                       nlflags |= NLM_F_APPEND;
>> +               else
>>                          fa = fa_first;
>>          }
>>          err = -ENOENT;
>
> I'm not sure I see the point of using the |=.   Why not just use a = 
> and save yourself an instruction or two since you don't really need 
> the OR operator in this case.
>
ack,

I would prefer keeping my initial patch which was pretty non-intrusive.

thanks,
Roopa
