From: Or Gerlitz <gerlitz.or@gmail.com>
Subject: Re: [PATCH net] net: sched: shrink struct qdisc_skb_cb to 28 bytes
Date: Fri, 19 Sep 2014 00:28:17 +0300
Message-ID: <CAJ3xEMhMO7wydorRivtvSgJr9LBjRpYDJtbYfgd0ACPLYBXyzw@mail.gmail.com>
References: <1402338773-5996-1-git-send-email-_govind@gmx.com>
	<1402338773-5996-2-git-send-email-_govind@gmx.com>
	<CAE9FiQW+Rv4o9Pc1J9hyqgW1WrhEANKEXH6zYQc2NQqeMbAcvA@mail.gmail.com>
	<alpine.LNX.2.03.1406261159071.1438@ws.cisco>
	<CAJZOPZJ7+n0t1LCqaa3JCBByRw=f_Tp6rk8vm0ZnCzmtKFKX_g@mail.gmail.com>
	<1411052525.7106.269.camel@edumazet-glaptop2.roam.corp.google.com>
	<20140918092628.566eae2b@urahara>
	<1411057934.7106.275.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Stephen Hemminger <stephen@networkplumber.org>,
	Govindarajulu Varadarajan <_govind@gmx.com>,
	Yinghai Lu <yinghai@kernel.org>,
	David Miller <davem@davemloft.net>,
	NetDev <netdev@vger.kernel.org>, ssujith@cisco.com,
	gvaradar@cisco.com, "Christian Benvenuti (benve)" <benve@cisco.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f182.google.com ([209.85.214.182]:54224 "EHLO
	mail-ob0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751820AbaIRV2S (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Sep 2014 17:28:18 -0400
Received: by mail-ob0-f182.google.com with SMTP id wo20so1014196obc.13
        for <netdev@vger.kernel.org>; Thu, 18 Sep 2014 14:28:18 -0700 (PDT)
In-Reply-To: <1411057934.7106.275.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Sep 18, 2014 at 7:32 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> On Thu, 2014-09-18 at 09:26 -0700, Stephen Hemminger wrote:
>> On Thu, 18 Sep 2014 08:02:05 -0700
>> Eric Dumazet <eric.dumazet@gmail.com> wrote:
>>
>> > From: Eric Dumazet <edumazet@google.com>
>> >
>> > We cannot make struct qdisc_skb_cb bigger without impacting IPoIB,
>> > or increasing skb->cb[] size.
>> >
>> > Commit e0f31d849867 ("flow_keys: Record IP layer protocol in
>> > skb_flow_dissect()") broke IPoIB.
>> >
>> > Only current offender is sch_choke, and this one do not need an
>> > absolutely precise flow key.
>> >
>> > If we store 17 bytes of flow key, its more than enough. (Its the actual
>> > size of flow_keys if it was a packed structure, but we might add new
>> > fields at the end of it later)
>> >
>> > Signed-off-by: Eric Dumazet <edumazet@google.com>
>>
>> Can we add BUILD_BUG to stop next time something smacks this.
>
> I though we had.
>
> Maybe IPoIB lacks one.
>
> Or, do you have an idea ?

Nope, we currently don't have such build time check, I saw you posted
one and I will be able to test it Sunday.
