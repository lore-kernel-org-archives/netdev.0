From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: Re: [PATCH net-next 0/5] net: dsa: Multi-CPU ground work
Date: Tue, 06 Jun 2017 14:25:05 -0400
Message-ID: <87bmq1j7ni.fsf@weeman.i-did-not-set--mail-host-address--so-tickle-me>
References: <20170606170202.21491-1-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: andrew@lunn.ch, john@phrozen.org, davem@davemloft.net,
        Florian Fainelli <f.fainelli@gmail.com>
To: Florian Fainelli <f.fainelli@gmail.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.savoirfairelinux.com ([208.88.110.44]:36678 "EHLO
        mail.savoirfairelinux.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751658AbdFFS1N (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 6 Jun 2017 14:27:13 -0400
In-Reply-To: <20170606170202.21491-1-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Florian,

Florian Fainelli <f.fainelli@gmail.com> writes:

> This patch series prepares the ground for adding mutliple CPU port support to

                                                   multiple
                                                   
> DSA, and starts by removing redundant pieces of information such as
> master_netdev which is cpu_dp->ethernet. Finally drivers are moved away from

                         cpu_dp->netdev
                         
> directly accessing ds->dst->cpu_dp and use appropriate helper functions.
>
> Note that if you have Device Tree blobs/platform configurations that are
> currently listing multiple CPU ports, the proposed behavior in
> dsa_ds_get_cpu_dp() will be to return the last bit set in ds->cpu_port_mask.
>
> Future plans include:
> - making dst->cpu_dp a flexible data structure (array, list, you name it)
> - having the ability for drivers to return a default/preferred CPU port (if
>   necessary)

The overall patchset looks good. I have questions for future work
though.

I am still not sure that we need CPU port references in
dsa_switch_tree. When device tree or pdata is parsed, we have allocated
dsa_switch and dsa_port structures. We should be able validate and
assign all ds->ports[x].cpu_dp, before setting up the switches and
creating the slave devices. What do you think?

Also I see dsa_ptr becoming a pointer to the assosicated dsa_port, and
dsa_port should contain the tagging ops for quick access. That is more
rigourous with the physical representation and much easier for
transparent multi-CPU port support.

Thanks,

        Vivien
