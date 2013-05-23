From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH net] vxlan: revert per-vxlan port
Date: Wed, 22 May 2013 17:39:54 -0700
Message-ID: <20130522173954.7f75f62d@nehalam.linuxnetplumber.net>
References: <20130520103017.054ae605@nehalam.linuxnetplumber.net>
 <OFECE722DE.3DBEE821-ON85257B71.00610478-85257B71.006456B5@us.ibm.com>
 <20130520113000.0057ce90@nehalam.linuxnetplumber.net>
 <20130522.150830.1305371698781503084.davem@davemloft.net>
 <OFB688A387.A3698315-ON85257B73.007C1B7B-85257B73.00800294@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	netdev-owner@vger.kernel.org
To: David Stevens <dlstevens@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f49.google.com ([209.85.160.49]:59535 "EHLO
	mail-pb0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754087Ab3EWAj6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 May 2013 20:39:58 -0400
Received: by mail-pb0-f49.google.com with SMTP id rp8so2298890pbb.36
        for <netdev@vger.kernel.org>; Wed, 22 May 2013 17:39:58 -0700 (PDT)
In-Reply-To: <OFB688A387.A3698315-ON85257B73.007C1B7B-85257B73.00800294@us.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 22 May 2013 19:18:12 -0400
David Stevens <dlstevens@us.ibm.com> wrote:

> David Miller <davem@davemloft.net> wrote on 05/22/2013 06:08:30 PM:
> 
> > David, please come to some kind of agreement with Stephen about what
> > we're going to do about this.
> 
> Well, I think being able to specify an alternate port for the
> default fdb entry is a useful feature in its own right. It is
> not equivalent to individual fdb entries with alternate ports
> because those require the host to know all the destinations in
> advance. It's certainly reasonable to use an alternate port for
> the default entry as well, and is not "useless" without multiple
> listen ports; it is as useful for the default port as it is for
> individual fdb entries.
> 
> I'm not sure what the benefit of reverting any working feature
> is, only to re-add it later, which I believe is what Stephen
> is proposing. I think it is useful for some configurations now,
> even if it only becomes useful for other configurations after
> multiple listen ports.
> 
> Stephen, can you explain what the benefit of reverting this is?
> 
> I think we want it long term, but I can live without it
> temporarily. I just don't see any reasoning for removing it
> temporarily in the first place. It isn't broken, or breaking
> anything else, after all.
> 
>                                                 +-DLS
> 

There are two different config things here
  1. FDB - NDA_PORT
  2. VXLAN - IFLA_VXLAN_PORT

The FDB stuff is seperate and fine, Dave did a complete job on that.
I was confused, but it's fine.

The per-vxlan device stuff is the issue. I don't think it works
as is in 3.10 because there is no real way to use it to receive.
And don't want to let it out broken. By reverting that part, we avoid
raising false expectations.
