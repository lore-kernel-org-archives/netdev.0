From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH net-next 0/5] net: dsa: Multi-CPU ground work
Date: Tue, 6 Jun 2017 12:20:54 -0700
Message-ID: <28e3b3c4-1f15-0473-ab51-e55c0de667d6@gmail.com>
References: <20170606170202.21491-1-f.fainelli@gmail.com>
 <87bmq1j7ni.fsf@weeman.i-did-not-set--mail-host-address--so-tickle-me>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Cc: andrew@lunn.ch, john@phrozen.org, davem@davemloft.net
To: Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
        netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qt0-f196.google.com ([209.85.216.196]:36488 "EHLO
        mail-qt0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751426AbdFFTU5 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 6 Jun 2017 15:20:57 -0400
Received: by mail-qt0-f196.google.com with SMTP id s33so18210827qtg.3
        for <netdev@vger.kernel.org>; Tue, 06 Jun 2017 12:20:57 -0700 (PDT)
In-Reply-To: <87bmq1j7ni.fsf@weeman.i-did-not-set--mail-host-address--so-tickle-me>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 06/06/2017 11:25 AM, Vivien Didelot wrote:
> Hi Florian,
> 
> Florian Fainelli <f.fainelli@gmail.com> writes:
> 
>> This patch series prepares the ground for adding mutliple CPU port support to
> 
>                                                    multiple
>                                                    
>> DSA, and starts by removing redundant pieces of information such as
>> master_netdev which is cpu_dp->ethernet. Finally drivers are moved away from
> 
>                          cpu_dp->netdev
>                          
>> directly accessing ds->dst->cpu_dp and use appropriate helper functions.
>>
>> Note that if you have Device Tree blobs/platform configurations that are
>> currently listing multiple CPU ports, the proposed behavior in
>> dsa_ds_get_cpu_dp() will be to return the last bit set in ds->cpu_port_mask.
>>
>> Future plans include:
>> - making dst->cpu_dp a flexible data structure (array, list, you name it)
>> - having the ability for drivers to return a default/preferred CPU port (if
>>   necessary)
> 
> The overall patchset looks good. I have questions for future work
> though.
> 
> I am still not sure that we need CPU port references in
> dsa_switch_tree. When device tree or pdata is parsed, we have allocated
> dsa_switch and dsa_port structures. We should be able validate and
> assign all ds->ports[x].cpu_dp, before setting up the switches and
> creating the slave devices. What do you think?

True, we should be able to do that, thanks for the suggestion.

> 
> Also I see dsa_ptr becoming a pointer to the assosicated dsa_port, and
> dsa_port should contain the tagging ops for quick access. That is more
> rigourous with the physical representation and much easier for
> transparent multi-CPU port support.

Ultimately, I agree we should probably have dev->dsa_ptr be the actual
CPU port within the switch, and from the switch be able to go to the
collection of switches (dst). This should indeed be a bit more optimized
as there should be less traversal of structures in such a case.

Thanks!
-- 
Florian
