From: Simon Horman <simon.horman@netronome.com>
Subject: Re: [PATCH net-next 2/3] net: mpls: Fixups for GSO
Date: Wed, 24 Aug 2016 09:20:11 +0200
Message-ID: <20160824072002.GA27254@penelope.isobedori.kobe.vergenet.net>
References: <1471626542-13335-1-git-send-email-dsa@cumulusnetworks.com>
 <1471626542-13335-3-git-send-email-dsa@cumulusnetworks.com>
 <20160822122122.GA8689@penelope.isobedori.kobe.vergenet.net>
 <dcf3df40-3914-37c6-55dc-e5c3de7530b5@cumulusnetworks.com>
 <20160822145134.GA26491@penelope.isobedori.kobe.vergenet.net>
 <3297517c-2889-19fe-5aa4-89e1d14eadca@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Pravin B Shelar <pshelar@nicira.com>, netdev@vger.kernel.org,
        davem@davemloft.net, buytenh@wantstofly.org, ebiederm@xmission.com,
        rshearma@brocade.com, tom@herbertland.com, tgraf@suug.ch,
        olivier.dugeon@orange.com, alexander.duyck@gmail.com,
        roopa@cumulusnetworks.com
To: David Ahern <dsa@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f43.google.com ([74.125.82.43]:33242 "EHLO
        mail-wm0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752758AbcHXHUP (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 24 Aug 2016 03:20:15 -0400
Received: by mail-wm0-f43.google.com with SMTP id d196so31306876wmd.0
        for <netdev@vger.kernel.org>; Wed, 24 Aug 2016 00:20:14 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <3297517c-2889-19fe-5aa4-89e1d14eadca@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi David,

On Tue, Aug 23, 2016 at 01:24:51PM -0600, David Ahern wrote:
> On 8/22/16 8:51 AM, Simon Horman wrote:
> > 
> > The scheme that OvS uses so far is that mac_len denotes the number of bytes
> > from the start of the MAC header until its end. In the absence of MPLS that
> > will be the beginning of the network header. And in the presence of MPLS it
> > will be the beginning of the MPLS label stack. The network header is... the
> > network header. This allows the MAC header, MPLS label stack and network
> > header to be tracked.
> 
> The neigh output functions do '__skb_pull(skb, skb_network_offset(skb))' so if mpls_xmit does not reset the network header the labels get dropped. To me this says MPLS labels can not be lumped with the mac header which leaves the only option as the outer network header.
> 
> > 
> > Pravin (CCed) may have different ideas but I wonder if the above scheme can
> > be preserved while also meeting the needs of your new MPLS GSO scheme if
> > you set skb_set_network_header() and skb_set_inner_network_header() in
> > net/openvswitch/actions.c:do_output().
> > 
> > It may also be possible to teach OvS to use skb_set_network_header to
> > denote the beginning of the MPLS LSE and skb_set_inner_network_header to
> > denote the network header in the presence of MPLS. Which is my current
> > understanding of what you are trying to achieve. But I think its likely
> > that I misunderstand things as it seems strange to me to pretend that an
> > MPLS LSE is a network header and the outer most network header is an inner
> > network header
> > 
> 
> This is the only option I can see working, but open to patches showing an
> alternative.

On reflection I came to a similar conclusion.

> I would like to get it resolved this week so I can move on to gso in the
> mpls forward case.

How do you feel about implementing the do_output() idea I suggested above?
I'm happy to provide testing and review.
