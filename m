From: Joao Pinto <Joao.Pinto@synopsys.com>
Subject: Fwd: Re: [v2,net-next,1/3] net: stmmac: enable multiple buffers
Date: Fri, 24 Mar 2017 15:02:27 +0000
Message-ID: <748685e5-86f8-5f6b-66db-04ec96af4bd6@synopsys.com>
References: <abf8722f-5d3a-0bae-d6cd-6cc6fbb744cb@synopsys.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 8bit
Cc: <peppe.cavallaro@st.com>, <alexandre.torgue@st.com>,
        <f.fainelli@gmail.com>, netdev <netdev@vger.kernel.org>
To: <clabbe.montjoie@gmail.com>, <thierry.reding@gmail.com>,
        <Joao.Pinto@synopsys.com>, <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtprelay.synopsys.com ([198.182.47.9]:56969 "EHLO
        smtprelay.synopsys.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S936052AbdCXPMN (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 24 Mar 2017 11:12:13 -0400
In-Reply-To: <abf8722f-5d3a-0bae-d6cd-6cc6fbb744cb@synopsys.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Sorry, sending again with David Miller in TO: instead of CC.

Às 2:09 PM de 3/24/2017, Corentin Labbe escreveu:
> On Thu, Mar 23, 2017 at 07:10:59PM +0100, Thierry Reding wrote:
>> On Thu, Mar 23, 2017 at 05:27:08PM +0000, Joao Pinto wrote:
>>> Hi Thierry,
>>>
>>
>> Yes, I can submit a patch for that.
>>
>> After some more testing I did get a couple (roughly 2 out of 10)
>> successful boots (I'm booting over NFS using the EQOS), and given that
>> this pointed towards something related to uninitialized data, I changed
>> all occurrences of kmalloc_array() with kcalloc() and that I've gotten
>> 10 successful reboots out of 10.
>>
>> I still can't pinpoint why this is now necessary since previously the
>> kmalloc_array() was working just fine. The only thing I can think of is
>> that we're not properly initializing all fields of the new queue
>> structures, since that's the only thing that's changed with this commit.
>>
>> I haven't investigated in detail yet, but from nothing so far has jumped
>> out at me.
>>
>> Thierry
> 
> I have tried this change, but it made the situation worse on dwmac-sunxi (no network at all).
> 
> Joao, perhaps it's time to revert the faulty (and very huge) patch and rework it by splitting at least in two:
> - adding RX queue / adding TX queue
> And more if possible (like just adding an unused queue parameter) or a patch just for adding stmmac_free_tx_buffers() for example.
> I think it will help to find where the problem is.
> 
> And this time I will test them before applying:)
> 
> Regards
> Corentin Labbe
> 

Yes, I agree, it is better to revert and leave the tree functional for all.

@David Miller:
The multiple-buffer patch introduced some problems in some setups that are being
hard to debug, so Corentin gave the idea of reverting the until
commit 7bac4e1ec3ca2342929a39638d615c6b672c27a0 (net: stmmac: stmmac interrupt
treatment prepared for multiple queues), which I fully agree.

In my setup is ok, but the idea is to have everyone's setup working :), so lets
break them into smaller pieces, and let's only apply them when everyone confirms
that is working ok in your setups, agree?

What is the typical mechanism for this? I send a patch reverting them?

Thanks,
Joao
