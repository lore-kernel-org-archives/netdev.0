From: Terry Lam <vtlam@google.com>
Subject: Re: [PATCH v2] net-qdisc-hhf: Heavy-Hitter Filter (HHF) qdisc
Date: Wed, 11 Dec 2013 20:21:56 -0800
Message-ID: <CAHy_qTwj8nNrgq=i6Qfmqh5GdnVE=p_yxmYawPcFXLu50NGACg@mail.gmail.com>
References: <1386746796-490-1-git-send-email-vtlam@google.com>
	<1386814204-16000-1-git-send-email-vtlam@google.com>
	<1386820274.19078.30.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Nandita Dukkipati <nanditad@google.com>,
	Eric Dumazet <edumazet@google.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f173.google.com ([209.85.214.173]:41556 "EHLO
	mail-ob0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751086Ab3LLEV5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Dec 2013 23:21:57 -0500
Received: by mail-ob0-f173.google.com with SMTP id gq1so8071698obb.32
        for <netdev@vger.kernel.org>; Wed, 11 Dec 2013 20:21:56 -0800 (PST)
In-Reply-To: <1386820274.19078.30.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Dec 11, 2013 at 7:51 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> On Wed, 2013-12-11 at 18:10 -0800, Terry Lam wrote:
>
>> +static u32 hhf_time_stamp(void)
>> +{
>> +     return jiffies;
>> +}
>
>
> This is a 32 bit value (For a good reason)
>
>> +{
>> +     struct hh_flow_state *flow, *next;
>> +     unsigned long now = hhf_time_stamp();
>
> stored in a 'unsigned long'
>
>> +
>> +     if (list_empty(head))
>> +             return NULL;
>> +
>> +     list_for_each_entry_safe(flow, next, head, flowchain) {
>> +             unsigned long prev = flow->hit_timestamp + q->hhf_evict_timeout;
>
>
> 32bit + ...
>
>> +
>> +             if (time_before(prev, now)) {
>
> This wont work on 64 bit arches : Wrapping wont be detected anymore.
>
> We keep 32bit variables to lower memory usage,
> this is why we have special macros in include/net/codel.h
>
> Please make sure you test your v3 patch, there is no hurry ;)
>

Thanks for spotting out this, Eric! time_before() needs an "unsigned
long" to avoid compile warning and I was confused by the existence of
both time_before() and time_before64() in jiffies.h.

I agree we should keep 32bit to save memory, so the best solution here
is to put back hhf_time_before() definition.
