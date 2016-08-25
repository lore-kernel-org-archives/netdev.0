From: pravin shelar <pshelar@ovn.org>
Subject: Re: [PATCH net-next 2/3] net: mpls: Fixups for GSO
Date: Wed, 24 Aug 2016 20:58:07 -0700
Message-ID: <CAOrHB_CP-RY0UnS0cDq6=SwHFUCtFRoiOKzchoFxEaQqeNBSwQ@mail.gmail.com>
References: <1471626542-13335-1-git-send-email-dsa@cumulusnetworks.com>
 <1471626542-13335-3-git-send-email-dsa@cumulusnetworks.com>
 <20160822122122.GA8689@penelope.isobedori.kobe.vergenet.net>
 <dcf3df40-3914-37c6-55dc-e5c3de7530b5@cumulusnetworks.com>
 <20160822145134.GA26491@penelope.isobedori.kobe.vergenet.net>
 <3297517c-2889-19fe-5aa4-89e1d14eadca@cumulusnetworks.com>
 <20160824072002.GA27254@penelope.isobedori.kobe.vergenet.net>
 <CAOrHB_BEn2D_iUgkqPD8ixhjJtnaLpYkANxL+Au7wO=8oKmGag@mail.gmail.com>
 <586321df-72c6-0dee-4ce6-22ca2a0860fb@cumulusnetworks.com>
 <CAOrHB_Dw1MJnfeD034HzGWkMrzEhP6PUKGFP3jDJzeNyRSZcHg@mail.gmail.com> <350fc449-ae3a-8e48-8a09-6d95cfa9901e@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8BIT
Cc: Simon Horman <simon.horman@netronome.com>,
        Pravin B Shelar <pshelar@nicira.com>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>,
        "David S. Miller" <davem@davemloft.net>, buytenh@wantstofly.org,
        "Eric W. Biederman" <ebiederm@xmission.com>, rshearma@brocade.com,
        tom@herbertland.com, Thomas Graf <tgraf@suug.ch>,
        olivier.dugeon@orange.com,
        Alexander Duyck <alexander.duyck@gmail.com>,
        roopa@cumulusnetworks.com
To: David Ahern <dsa@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from slow1-d.mail.gandi.net ([217.70.178.86]:49188 "EHLO
        slow1-d.mail.gandi.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750715AbcHYEZ0 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 25 Aug 2016 00:25:26 -0400
Received: from relay2-d.mail.gandi.net (relay2-d.mail.gandi.net [217.70.183.194])
        by slow1-d.mail.gandi.net (Postfix) with ESMTP id 5008B47ED71
        for <netdev@vger.kernel.org>; Thu, 25 Aug 2016 05:58:14 +0200 (CEST)
Received: from mfilter37-d.gandi.net (mfilter37-d.gandi.net [217.70.178.168])
        by relay2-d.mail.gandi.net (Postfix) with ESMTP id 3C817C5A46
        for <netdev@vger.kernel.org>; Thu, 25 Aug 2016 05:58:12 +0200 (CEST)
Received: from relay2-d.mail.gandi.net ([IPv6:::ffff:217.70.183.194])
        by mfilter37-d.gandi.net (mfilter37-d.gandi.net [::ffff:10.0.15.180]) (amavisd-new, port 10024)
        with ESMTP id yCQqLvcFIP0f for <netdev@vger.kernel.org>;
        Thu, 25 Aug 2016 05:58:10 +0200 (CEST)
Received: from mail-it0-f53.google.com (mail-it0-f53.google.com [209.85.214.53])
        (Authenticated sender: pshelar@ovn.org)
        by relay2-d.mail.gandi.net (Postfix) with ESMTPSA id AFC76C5A53
        for <netdev@vger.kernel.org>; Thu, 25 Aug 2016 05:58:09 +0200 (CEST)
Received: by mail-it0-f53.google.com with SMTP id f6so30265260ith.0
        for <netdev@vger.kernel.org>; Wed, 24 Aug 2016 20:58:09 -0700 (PDT)
In-Reply-To: <350fc449-ae3a-8e48-8a09-6d95cfa9901e@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Aug 24, 2016 at 11:53 AM, David Ahern <dsa@cumulusnetworks.com> wrote:
> On 8/24/16 11:41 AM, pravin shelar wrote:
>> You also need to change pop_mpls().
>
> What change is needed in pop_mpls? It already resets the mac_header and if MPLS labels are removed there is no need to set network_header. I take it you mean if the protocol is still MPLS and there are still labels then the network header needs to be set and that means finding the bottom label. Does OVS set the bottom of stack bit? From what I can tell OVS is not parsing the MPLS label so no requirement that BOS is set. Without that there is no way to tell when the labels are done short of guessing.
>

OVS mpls push and pop action works on outer most mpls label. So
according to new mpls offsets tracking scheme on mpls_pop action you
need to adjust skb network offset.
