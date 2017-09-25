From: Simon Horman <simon.horman@netronome.com>
Subject: Re: [PATCH net-next 0/7] nfp: flower vxlan tunnel offload
Date: Mon, 25 Sep 2017 19:04:53 +0200
Message-ID: <20170925170451.GD18763@vergenet.net>
References: <1506335021-32024-1-git-send-email-simon.horman@netronome.com>
 <CAJ3xEMgfRuD2Y-P2eTKmXpciiopA8js4zbO_nNOA6J62sn--mw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>,
        Jakub Kicinski <jakub.kicinski@netronome.com>,
        Linux Netdev List <netdev@vger.kernel.org>,
        oss-drivers@netronome.com, John Hurley <john.hurley@netronome.com>
To: Or Gerlitz <gerlitz.or@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f45.google.com ([74.125.82.45]:45432 "EHLO
        mail-wm0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S935407AbdIYRE4 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 25 Sep 2017 13:04:56 -0400
Received: by mail-wm0-f45.google.com with SMTP id q124so21779115wmb.0
        for <netdev@vger.kernel.org>; Mon, 25 Sep 2017 10:04:56 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <CAJ3xEMgfRuD2Y-P2eTKmXpciiopA8js4zbO_nNOA6J62sn--mw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Sep 25, 2017 at 06:25:03PM +0300, Or Gerlitz wrote:
> On Mon, Sep 25, 2017 at 1:23 PM, Simon Horman
> <simon.horman@netronome.com> wrote:
> > From: Simon Horman <simon.horman@netronome.com>
> >
> > John says:
> >
> > This patch set allows offloading of TC flower match and set tunnel fields
> > to the NFP. The initial focus is on VXLAN traffic. Due to the current
> > state of the NFP firmware, only VXLAN traffic on well known port 4789 is
> > handled. The match and action fields must explicity set this value to be
> > supported. Tunnel end point information is also offloaded to the NFP for
> > both encapsulation and decapsulation. The NFP expects 3 separate data sets
> > to be supplied.
> 
> > For decapsulation, 2 separate lists exist; a list of MAC addresses
> > referenced by an index comprised of the port number, and a list of IP
> > addresses. These IP addresses are not connected to a MAC or port.
> 
> Do these IP addresses exist on the host kernel SW stack? can the same
> set of TC rules be fully functional and generate the same traffic
> pattern when set to run in SW (skip_hw)?

Hi Or,

I asked John (now CCed) about this and his response was:

The MAC addresses are extracted from the netdevs already loaded in the
kernel and are monitored for any changes. The IP addresses are slightly
different in that they are extracted from the rules themselves. We make the
assumption that, if a packet is decapsulated at the end point and a match
is attempted on the IP address, that this IP address should be recognised
in the kernel. That being the case, the same traffic pattern should be
witnessed if the skip_hw flag is applied.
