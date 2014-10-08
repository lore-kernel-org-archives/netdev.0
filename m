From: John Fastabend <john.fastabend@gmail.com>
Subject: Re: Quota in __qdisc_run()
Date: Wed, 08 Oct 2014 10:38:45 -0700
Message-ID: <543576A5.3070403@gmail.com>
References: <20141003.145647.1980640682969765484.davem@davemloft.net>  <1412373477.17245.5.camel@edumazet-glaptop2.roam.corp.google.com>  <1412375467.17245.16.camel@edumazet-glaptop2.roam.corp.google.com>  <20141003.153645.72976986956341944.davem@davemloft.net>  <1412379044.17245.26.camel@edumazet-glaptop2.roam.corp.google.com>  <20141007093441.35ce3a02@redhat.com> <1412686038.11091.111.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Jesper Dangaard Brouer <brouer@redhat.com>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	therbert@google.com, hannes@stressinduktion.org, fw@strlen.de,
	dborkman@redhat.com, jhs@mojatatu.com, alexander.duyck@gmail.com,
	john.r.fastabend@intel.com, dave.taht@gmail.com, toke@toke.dk
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f51.google.com ([209.85.218.51]:33963 "EHLO
	mail-oi0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751643AbaJHRjR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Oct 2014 13:39:17 -0400
Received: by mail-oi0-f51.google.com with SMTP id h136so5607211oig.10
        for <netdev@vger.kernel.org>; Wed, 08 Oct 2014 10:39:17 -0700 (PDT)
In-Reply-To: <1412686038.11091.111.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/07/2014 05:47 AM, Eric Dumazet wrote:
> On Tue, 2014-10-07 at 09:34 +0200, Jesper Dangaard Brouer wrote:
>> On Fri, 03 Oct 2014 16:30:44 -0700 Eric Dumazet <eric.dumazet@gmail.com> wrote:
>>
>>> Another problem we need to address is the quota in __qdisc_run()
>>> is no longer meaningfull, if each qdisc_restart() can pump many packets.
>>
>> I fully agree. My earlier "magic" packet limit was covering/pampering
>> over this issue.
>
> Although quota was multiplied by 7 or 8 in worst case ?
>
>>
>>> An idea would be to use the bstats (or cpu_qstats if applicable)
>>
>> Please elaborate some more, as I don't completely follow (feel free to
>> show with a patch ;-)).
>>
>
> I was hoping John could finish the percpu stats before I do that.

What stats are you referring to? I assume the remaining stats in the
xmit path mostly in sch_generic.c? By the way I need to do another
review of the classifier code paths but I believe we could drop the
ingress qdisc lock now (finally)...

Also some clean up in sch_generic.c could help this. Notes for
myself mostly,

	dev_requeue_skb() can be a void its return value is always 0

	the users of handle_dev_cpu_collision and sch_direct_xmit
	don't use the qlen for anything returning any positive
	integer looks like it would work.


Thanks,
John


-- 
John Fastabend         Intel Corporation
