From: David Ahern <dsa@cumulusnetworks.com>
Subject: Re: [PATCH net-next 2/3] net: mpls: Fixups for GSO
Date: Tue, 23 Aug 2016 13:24:51 -0600
Message-ID: <3297517c-2889-19fe-5aa4-89e1d14eadca@cumulusnetworks.com>
References: <1471626542-13335-1-git-send-email-dsa@cumulusnetworks.com>
 <1471626542-13335-3-git-send-email-dsa@cumulusnetworks.com>
 <20160822122122.GA8689@penelope.isobedori.kobe.vergenet.net>
 <dcf3df40-3914-37c6-55dc-e5c3de7530b5@cumulusnetworks.com>
 <20160822145134.GA26491@penelope.isobedori.kobe.vergenet.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net,
        buytenh@wantstofly.org, ebiederm@xmission.com,
        rshearma@brocade.com, tom@herbertland.com, tgraf@suug.ch,
        olivier.dugeon@orange.com, alexander.duyck@gmail.com,
        roopa@cumulusnetworks.com
To: Simon Horman <simon.horman@netronome.com>,
        Pravin B Shelar <pshelar@nicira.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f179.google.com ([209.85.192.179]:35418 "EHLO
        mail-pf0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752094AbcHWTcz (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 23 Aug 2016 15:32:55 -0400
Received: by mail-pf0-f179.google.com with SMTP id x72so46567648pfd.2
        for <netdev@vger.kernel.org>; Tue, 23 Aug 2016 12:32:20 -0700 (PDT)
In-Reply-To: <20160822145134.GA26491@penelope.isobedori.kobe.vergenet.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 8/22/16 8:51 AM, Simon Horman wrote:
> 
> The scheme that OvS uses so far is that mac_len denotes the number of bytes
> from the start of the MAC header until its end. In the absence of MPLS that
> will be the beginning of the network header. And in the presence of MPLS it
> will be the beginning of the MPLS label stack. The network header is... the
> network header. This allows the MAC header, MPLS label stack and network
> header to be tracked.

The neigh output functions do '__skb_pull(skb, skb_network_offset(skb))' so if mpls_xmit does not reset the network header the labels get dropped. To me this says MPLS labels can not be lumped with the mac header which leaves the only option as the outer network header.

> 
> Pravin (CCed) may have different ideas but I wonder if the above scheme can
> be preserved while also meeting the needs of your new MPLS GSO scheme if
> you set skb_set_network_header() and skb_set_inner_network_header() in
> net/openvswitch/actions.c:do_output().
> 
> It may also be possible to teach OvS to use skb_set_network_header to
> denote the beginning of the MPLS LSE and skb_set_inner_network_header to
> denote the network header in the presence of MPLS. Which is my current
> understanding of what you are trying to achieve. But I think its likely
> that I misunderstand things as it seems strange to me to pretend that an
> MPLS LSE is a network header and the outer most network header is an inner
> network header
> 

This is the only option I can see working, but open to patches showing an alternative.

I would like to get it resolved this week so I can move on to gso in the mpls forward case.
