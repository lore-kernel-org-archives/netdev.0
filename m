From: Or Gerlitz <or.gerlitz@gmail.com>
Subject: Re: [net] net: sched: shrink struct qdisc_skb_cb to 28 bytes
Date: Fri, 19 Sep 2014 15:07:12 +0300
Message-ID: <CAJZOPZLheP-zD8y20cc5u23DduQp3Yu8=OxxHnggT+S-Cnt7AQ@mail.gmail.com>
References: <1411052525.7106.269.camel@edumazet-glaptop2.roam.corp.google.com>
	<541B5CCB.6060808@xsintricity.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Govindarajulu Varadarajan <_govind@gmx.com>,
	Yinghai Lu <yinghai@kernel.org>,
	NetDev <netdev@vger.kernel.org>, ssujith@cisco.com,
	gvaradar@cisco.com, "Christian Benvenuti (benve)" <benve@cisco.com>
To: Doug Ledford <dledford@xsintricity.com>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qg0-f44.google.com ([209.85.192.44]:62881 "EHLO
	mail-qg0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755372AbaISMHO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Sep 2014 08:07:14 -0400
Received: by mail-qg0-f44.google.com with SMTP id z107so2664201qgd.3
        for <netdev@vger.kernel.org>; Fri, 19 Sep 2014 05:07:13 -0700 (PDT)
In-Reply-To: <541B5CCB.6060808@xsintricity.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Sep 19, 2014 at 1:29 AM, Doug Ledford <dledford@xsintricity.com> wrote:
> On 09/18/2014 11:02 AM, Eric Dumazet wrote:
>> From: Eric Dumazet <edumazet@google.com>
>> We cannot make struct qdisc_skb_cb bigger without impacting IPoIB,
>> or increasing skb->cb[] size.
>>
>> Commit e0f31d849867 ("flow_keys: Record IP layer protocol in
>> skb_flow_dissect()") broke IPoIB.
>>
>> Only current offender is sch_choke, and this one do not need an
>> absolutely precise flow key.
>>
>> If we store 17 bytes of flow key, its more than enough. (Its the actual
>> size of flow_keys if it was a packed structure, but we might add new
>> fields at the end of it later)
>>
>> Signed-off-by: Eric Dumazet <edumazet@google.com>
>> Fixes: e0f31d849867 ("flow_keys: Record IP layer protocol in
>> skb_flow_dissect()")

> I've installed this patch on my cluster and it resolves the problem.
> Tested-by/Acked-by: Doug Ledford <dledford@redhat.com>

Thanks Eric/Doug!

Dave - just to make sure, this is for net, as the regression was
introduced in 3.17-rc1.

Or.
