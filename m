From: YOSHIFUJI Hideaki <hideaki.yoshifuji@miraclelinux.com>
Subject: Re: [PATCH net-next 1/2] net: neighbour: Add mcast_resolicit to configure
 the number of multicast resolicitations in PROBE state.
Date: Mon, 30 Mar 2015 09:04:50 +0900
Message-ID: <55189322.1040602@miraclelinux.com>
References: <20150319.224146.893461080038567220.yoshfuji@yoshifuji-H87MS01.miraclelinux.com> <550F7A33.1000708@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	hideaki.yoshifuji@miraclelinux.com, ulf.samuelsson@ericsson.com
To: yzhu1 <Yanjun.Zhu@windriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exprod7og107.obsmtp.com ([64.18.2.167]:58819 "HELO
	exprod7og107.obsmtp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S1751355AbbC3AEx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 29 Mar 2015 20:04:53 -0400
Received: by mail-pa0-f54.google.com with SMTP id we9so149997326pac.1
        for <netdev@vger.kernel.org>; Sun, 29 Mar 2015 17:04:53 -0700 (PDT)
In-Reply-To: <550F7A33.1000708@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

yzhu1 wrote:
>> diff --git a/net/core/neighbour.c b/net/core/neighbour.c
>> index 0e8b32e..3de6542 100644
>> --- a/net/core/neighbour.c
>> +++ b/net/core/neighbour.c
>> @@ -817,10 +817,9 @@ out:
>>   static __inline__ int neigh_max_probes(struct neighbour *n)
>>   {
>>       struct neigh_parms *p = n->parms;
>> -    int max_probes = NEIGH_VAR(p, UCAST_PROBES) + NEIGH_VAR(p, APP_PROBES);
>> -    if (!(n->nud_state & NUD_PROBE))
>> -        max_probes += NEIGH_VAR(p, MCAST_PROBES);
>> -    return max_probes;
>> +    return NEIGH_VAR(p, UCAST_PROBES) + NEIGH_VAR(p, APP_PROBES) +
>> +           (n->nud_state & NUD_PROBE ? NEIGH_VAR(p, MCAST_REPROBES) :
>> +            NEIGH_VAR(p, MCAST_PROBES));
>>   }
> Hi, YOSHIFUJI Hideaki
> 
> In my opinion, maybe the above should be implemented in ipv4 source code since
> this problem is only related with ipv4. But the neigh_max_probes is called in ipv6.

It is intentionally designed so that it could be used for other
protocols as well as IPv4.  For example, if the knob for IPv6
is set to non-zero, it becomes "non-compliant", but it works.

-- 
Hideaki Yoshifuji <hideaki.yoshifuji@miraclelinux.com>
Technical Division, MIRACLE LINUX CORPORATION
