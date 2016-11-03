From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v2 1/1] driver: veth: Refine the statistics
 codes of veth driver
Date: Thu, 03 Nov 2016 13:18:10 -0400 (EDT)
Message-ID: <20161103.131810.2042355356026457407.davem@davemloft.net>
References: <CA+6hz4r9zkPp7-mG7b98ocPvjTiheSnEBMjffSkLXD1MM-aMtg@mail.gmail.com>
        <1478183516.7065.440.camel@edumazet-glaptop3.roam.corp.google.com>
        <CA+6hz4owi2WgeGWd98=8d=Q5DBPY4_ZtYAOgcM1V_0+OU8UHrw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, cwang@twopensource.com, vijayp@vijayp.ca,
        ej@evanjones.ca, pabeni@redhat.com, netdev@vger.kernel.org
To: fgao@ikuai8.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:38938 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1758423AbcKCRSM (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 3 Nov 2016 13:18:12 -0400
In-Reply-To: <CA+6hz4owi2WgeGWd98=8d=Q5DBPY4_ZtYAOgcM1V_0+OU8UHrw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Gao Feng <fgao@ikuai8.com>
Date: Thu, 3 Nov 2016 22:38:28 +0800

> On Thu, Nov 3, 2016 at 10:31 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
>> On Thu, 2016-11-03 at 21:39 +0800, Gao Feng wrote:
>>> Hi Eric,
>>>
>>> On Thu, Nov 3, 2016 at 9:30 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
>>> > On Thu, 2016-11-03 at 21:03 +0800, fgao@ikuai8.com wrote:
>>> >> From: Gao Feng <fgao@ikuai8.com>
>>> >>
>>> >> The dropped count of veth is located in struct veth_priv, but other
>>> >> statistics like packets and bytes are in another struct pcpu_vstats.
>>> >> Now keep these three counters in the same struct.
>>> >>
>>> >> Signed-off-by: Gao Feng <fgao@ikuai8.com>
>>> >> ---
>>> >>  v2: Use right "peer" instead of "dev";
>>> >>  v1: Initial version
>>> >
>>> > May I ask : Why ?
>>>
>>> Just because I think statistics should be in the same struct.
>>
>> That is not a good reason then.
> 
> Because other net devices put the statistics together.

Organizational "prettyness" is not argument for this change, when the
downsides are fundamentally clear:

1) It is not a fast-path accessed statistic, so the per-cpu'ness is
   not important.

2) We aim to minimize the amount of per-cpu data in the kernel because
   it is expensive.  So when not necessary, as is the case here, we
   do not user per-cpu data.

There are no good reasons to make this change, so I am dropping your
patch.
