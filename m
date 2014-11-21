From: Chris Mason <clm@fb.com>
Subject: Re: crash in __kfree_skb on v3.18-rc5 with CONFIG_DEBUG_PAGEALLOC
Date: Fri, 21 Nov 2014 12:18:03 -0500
Message-ID: <1416590283.24312.8@mail.thefacebook.com>
References: <20141121160937.GA32608@ret.masoncoding.com>
	<1416587469.8629.106.camel@edumazet-glaptop2.roam.corp.google.com>
	<1416587848.8629.108.camel@edumazet-glaptop2.roam.corp.google.com>
	<1416588426.24312.6@mail.thefacebook.com>
	<1416588995.8629.114.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"; format=flowed
Cc: <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-00082601.pphosted.com ([67.231.153.30]:37109 "EHLO
	mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S932081AbaKURSO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Nov 2014 12:18:14 -0500
In-Reply-To: <1416588995.8629.114.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On Fri, Nov 21, 2014 at 11:56 AM, Eric Dumazet <eric.dumazet@gmail.com> 
wrote:
> On Fri, 2014-11-21 at 11:47 -0500, Chris Mason wrote:
> 
>>  Once my current run is done, I can revert this and try a loop.  But 
>> I
>>  don't see how this commit causes a use-after-free on the skb itself?
> 
> Well, it is so obvious, you really want to make me miserable ;)
> 
> I am testing the revert and send it asap.

Grin, no I just don't know what fclones really are ;)  So dropping the 
ref by one on the clone opens up the skb to be freed and another CPU 
races in and frees skb before we can do the assignment lower down.

I've added your revert here and I'll restart the test.  It takes a few 
hours to get to the point where I've fallen over so far today, but I'll 
just leave it in a loop all day long.

Thanks!

-chris
