From: Joe Stringer <joe@ovn.org>
Subject: Re: [PATCH net-next v1 0/3] Flow Based GTP Tunneling
Date: Thu, 13 Jul 2017 11:14:27 -0700
Message-ID: <CAPWQB7F4aLDnZpqLqqDpNpzHG2nLOUAvcdibqR1CC4cO_ymz0g@mail.gmail.com>
References: <20170713004455.3946570-1-ouyangj@fb.com> <20170713071249.lk7dph6bpzgn622d@nataraja>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Jiannan Ouyang <ouyangj@fb.com>,
        osmocom-net-gprs@lists.osmocom.org,
        netdev <netdev@vger.kernel.org>, ovs dev <dev@openvswitch.org>,
        Pablo Neira Ayuso <pablo@netfilter.org>,
        Pravin B Shelar <pshelar@nicira.com>,
        Wieger IJntema <wieger.ijntema.tno@gmail.com>,
        "Yang, Yi Y" <yi.y.yang@intel.com>,
        Amar Padmanabhan <amarpadmanabhan@fb.com>
To: Harald Welte <laforge@gnumonks.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay2-d.mail.gandi.net ([217.70.183.194]:56211 "EHLO
        relay2-d.mail.gandi.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751271AbdGMSOv (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 13 Jul 2017 14:14:51 -0400
Received: from mail-oi0-f53.google.com (mail-oi0-f53.google.com [209.85.218.53])
        (Authenticated sender: joe@ovn.org)
        by relay2-d.mail.gandi.net (Postfix) with ESMTPSA id 55AD0C5A44
        for <netdev@vger.kernel.org>; Thu, 13 Jul 2017 20:14:49 +0200 (CEST)
Received: by mail-oi0-f53.google.com with SMTP id x187so53002047oig.3
        for <netdev@vger.kernel.org>; Thu, 13 Jul 2017 11:14:49 -0700 (PDT)
In-Reply-To: <20170713071249.lk7dph6bpzgn622d@nataraja>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 13 July 2017 at 00:12, Harald Welte <laforge@gnumonks.org> wrote:
> hi Jiannan,
>
> net-next si closed, as it has been pointed out already by Joe.
>
> On Wed, Jul 12, 2017 at 05:44:52PM -0700, Jiannan Ouyang wrote:
>> ovs-ofctl add-flow br0
>>     "in_port=2,tun_src=192.168.60.141,tun_id=123, \
>>     actions=set_field:02:00:00:00:00:00->eth_src, \
>>     set_field:ff:ff:ff:ff:ff:ff->eth_dst,LOCAL"
>
> I'm not familiar with the details here, but does this imply that you
> are matching on the outer (transport layer) source IP address? If so,
> please note this is in violation of the 3GPP specifications for GTP,
> which require explicitly that the TEID is the *only* criteria for
> matching an encapsulated packet to the tunnel.  Basically anyone can
> send you an encapsulated packet from any random source IP, just as long
> as the TEID matches a tunnel, it will be decapsulated.
>
> This is [presumably] in order to take care of mobility, as the
> subscribers' phone moves around different MME/S-GW/SGSN, each having
> different source IP addresses.

I think that this will be hard to avoid; the several existing tunnel
implementations that OVS plugs into all allow matching on the outer
addresses/ports, I don't see a good way to restrict it without
introducing completely new metadata_dst paths for GTP. I'd prefer not
to introduce something like this if we can avoid it; several tunnels
currently share all of the same metadata_dst code and that's proven
sufficient for all cases so far. If someone wishes to implement the
3GPP standard correctly then they should not create matches like this.
In quite a few cases, OVS tends to take the approach that we give the
user the tools to do what they need to do, but if they wish to shoot
themselves in the foot then that's up to them. We can of course work
towards ensuring the OVS userspace guides users in the right direction
though.
