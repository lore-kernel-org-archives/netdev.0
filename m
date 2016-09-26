From: Jiri Benc <jbenc@redhat.com>
Subject: Re: [PATCH net-next 2/3] net: mpls: Fixups for GSO
Date: Mon, 26 Sep 2016 19:02:59 +0200
Message-ID: <20160926190259.3b878aa5@griffin>
References: <1471626542-13335-1-git-send-email-dsa@cumulusnetworks.com>
        <1471626542-13335-3-git-send-email-dsa@cumulusnetworks.com>
        <20160822122122.GA8689@penelope.isobedori.kobe.vergenet.net>
        <dcf3df40-3914-37c6-55dc-e5c3de7530b5@cumulusnetworks.com>
        <20160822145134.GA26491@penelope.isobedori.kobe.vergenet.net>
        <3297517c-2889-19fe-5aa4-89e1d14eadca@cumulusnetworks.com>
        <20160824072002.GA27254@penelope.isobedori.kobe.vergenet.net>
        <CAOrHB_BEn2D_iUgkqPD8ixhjJtnaLpYkANxL+Au7wO=8oKmGag@mail.gmail.com>
        <586321df-72c6-0dee-4ce6-22ca2a0860fb@cumulusnetworks.com>
        <20160926175622.3b00d478@griffin>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: pravin shelar <pshelar@ovn.org>,
        Simon Horman <simon.horman@netronome.com>,
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
Received: from mx1.redhat.com ([209.132.183.28]:54324 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751962AbcIZRDG (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 26 Sep 2016 13:03:06 -0400
In-Reply-To: <20160926175622.3b00d478@griffin>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 26 Sep 2016 17:56:22 +0200, Jiri Benc wrote:
> After push_mpls, network_header points to the start of MPLS headers.
> Which I understand was the point of this patch. However, push_mpls also
> calls invalidate_flow_key. Meaning that, depending on actions, we may
> end up calling key_extract soon after. And key_extract sets the network
> header *after* the MPLS headers.
> 
> That means that on output, for otherwise identical packet,
> network_header can point before or after MPLS headers based on what
> actions happened to be executed (recirculation, mainly).
> 
> If I'm not misreading the code or missing something, this can't be
> right.
> 
> mpls_gso_segment does not care, it resets the network_header anyway.
> What about drivers? What is the correct behavior?

Answering to myself: it breaks skb_mac_gso_segment. Seems we need to
fix key_extract to set network_header to the beginning of MPLS headers.
I'll prepare a patch.

 Jiri
