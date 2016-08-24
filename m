From: pravin shelar <pshelar@ovn.org>
Subject: Re: [PATCH net-next 2/3] net: mpls: Fixups for GSO
Date: Wed, 24 Aug 2016 09:28:27 -0700
Message-ID: <CAOrHB_BEn2D_iUgkqPD8ixhjJtnaLpYkANxL+Au7wO=8oKmGag@mail.gmail.com>
References: <1471626542-13335-1-git-send-email-dsa@cumulusnetworks.com>
 <1471626542-13335-3-git-send-email-dsa@cumulusnetworks.com>
 <20160822122122.GA8689@penelope.isobedori.kobe.vergenet.net>
 <dcf3df40-3914-37c6-55dc-e5c3de7530b5@cumulusnetworks.com>
 <20160822145134.GA26491@penelope.isobedori.kobe.vergenet.net>
 <3297517c-2889-19fe-5aa4-89e1d14eadca@cumulusnetworks.com> <20160824072002.GA27254@penelope.isobedori.kobe.vergenet.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8BIT
Cc: David Ahern <dsa@cumulusnetworks.com>,
        Pravin B Shelar <pshelar@nicira.com>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>,
        "David S. Miller" <davem@davemloft.net>, buytenh@wantstofly.org,
        "Eric W. Biederman" <ebiederm@xmission.com>, rshearma@brocade.com,
        tom@herbertland.com, Thomas Graf <tgraf@suug.ch>,
        olivier.dugeon@orange.com,
        Alexander Duyck <alexander.duyck@gmail.com>,
        roopa@cumulusnetworks.com
To: Simon Horman <simon.horman@netronome.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from slow1-d.mail.gandi.net ([217.70.178.86]:46357 "EHLO
        slow1-d.mail.gandi.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755062AbcHXQcH (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 24 Aug 2016 12:32:07 -0400
Received: from relay4-d.mail.gandi.net (relay4-d.mail.gandi.net [217.70.183.196])
        by slow1-d.mail.gandi.net (Postfix) with ESMTP id 65A4948603C
        for <netdev@vger.kernel.org>; Wed, 24 Aug 2016 18:29:32 +0200 (CEST)
Received: from mfilter19-d.gandi.net (mfilter19-d.gandi.net [217.70.178.147])
        by relay4-d.mail.gandi.net (Postfix) with ESMTP id 7EE8B172094
        for <netdev@vger.kernel.org>; Wed, 24 Aug 2016 18:28:30 +0200 (CEST)
Received: from relay4-d.mail.gandi.net ([IPv6:::ffff:217.70.183.196])
        by mfilter19-d.gandi.net (mfilter19-d.gandi.net [::ffff:10.0.15.180]) (amavisd-new, port 10024)
        with ESMTP id E307jrLSAJOv for <netdev@vger.kernel.org>;
        Wed, 24 Aug 2016 18:28:29 +0200 (CEST)
Received: from mail-it0-f43.google.com (mail-it0-f43.google.com [209.85.214.43])
        (Authenticated sender: pshelar@ovn.org)
        by relay4-d.mail.gandi.net (Postfix) with ESMTPSA id F0E331720BC
        for <netdev@vger.kernel.org>; Wed, 24 Aug 2016 18:28:28 +0200 (CEST)
Received: by mail-it0-f43.google.com with SMTP id x131so219654274ite.0
        for <netdev@vger.kernel.org>; Wed, 24 Aug 2016 09:28:28 -0700 (PDT)
In-Reply-To: <20160824072002.GA27254@penelope.isobedori.kobe.vergenet.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Aug 24, 2016 at 12:20 AM, Simon Horman
<simon.horman@netronome.com> wrote:
> Hi David,
>
> On Tue, Aug 23, 2016 at 01:24:51PM -0600, David Ahern wrote:
>> On 8/22/16 8:51 AM, Simon Horman wrote:
>> >
>> > The scheme that OvS uses so far is that mac_len denotes the number of bytes
>> > from the start of the MAC header until its end. In the absence of MPLS that
>> > will be the beginning of the network header. And in the presence of MPLS it
>> > will be the beginning of the MPLS label stack. The network header is... the
>> > network header. This allows the MAC header, MPLS label stack and network
>> > header to be tracked.
>>
>> The neigh output functions do '__skb_pull(skb, skb_network_offset(skb))' so if mpls_xmit does not reset the network header the labels get dropped. To me this says MPLS labels can not be lumped with the mac header which leaves the only option as the outer network header.
>>
>> >
>> > Pravin (CCed) may have different ideas but I wonder if the above scheme can
>> > be preserved while also meeting the needs of your new MPLS GSO scheme if
>> > you set skb_set_network_header() and skb_set_inner_network_header() in
>> > net/openvswitch/actions.c:do_output().
>> >
>> > It may also be possible to teach OvS to use skb_set_network_header to
>> > denote the beginning of the MPLS LSE and skb_set_inner_network_header to
>> > denote the network header in the presence of MPLS. Which is my current
>> > understanding of what you are trying to achieve. But I think its likely
>> > that I misunderstand things as it seems strange to me to pretend that an
>> > MPLS LSE is a network header and the outer most network header is an inner
>> > network header
>> >
>>
>> This is the only option I can see working, but open to patches showing an
>> alternative.
>
> On reflection I came to a similar conclusion.
>
>> I would like to get it resolved this week so I can move on to gso in the
>> mpls forward case.
>
> How do you feel about implementing the do_output() idea I suggested above?
> I'm happy to provide testing and review.

I am not sure about changing do_output(). why not just use same scheme
to track mpls header in OVS datapath as done in mpls device?
