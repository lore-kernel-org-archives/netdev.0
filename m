From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH net]  vxlan: revert per-vxlan port
Date: Mon, 20 May 2013 11:30:00 -0700
Message-ID: <20130520113000.0057ce90@nehalam.linuxnetplumber.net>
References: <20130520103017.054ae605@nehalam.linuxnetplumber.net>
	<OFECE722DE.3DBEE821-ON85257B71.00610478-85257B71.006456B5@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	netdev-owner@vger.kernel.org
To: David Stevens <dlstevens@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f44.google.com ([209.85.220.44]:39237 "EHLO
	mail-pa0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757734Ab3ETSaH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 May 2013 14:30:07 -0400
Received: by mail-pa0-f44.google.com with SMTP id jh10so5923780pab.31
        for <netdev@vger.kernel.org>; Mon, 20 May 2013 11:30:06 -0700 (PDT)
In-Reply-To: <OFECE722DE.3DBEE821-ON85257B71.00610478-85257B71.006456B5@us.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 20 May 2013 14:15:59 -0400
David Stevens <dlstevens@us.ibm.com> wrote:

> > From: Stephen Hemminger <stephen@networkplumber.org>
>  
> > \This commit 823aa873bc782f1c51b1ce8ec6da7cfcaf93836e
> > Author: stephen hemminger <stephen@networkplumber.org>
> > Date:   Sat Apr 27 11:31:57 2013 +0000
> > 
> >     vxlan: allow choosing destination port per vxlan
> > 
> > is broken revert it. The change allowed setting per port for transmit
> > but did not add additional listening sockets, which made any vxlan's
> > defined with non-default port send only.
> 
> This allows you to specify a different default port for
> transmits, which is what you want to do if your own instance
> of VXLAN is the odd one. I don't see any requirement for multiple
> listen ports for that to be useful, since those sending to you
> can have complete fdb tables even if the local instance doesn't
> and relies on the default. Not to mention using an agent to
> fill the fdb triggered by packets sent to the default, so the
> receiver is not necessarily even a VXLAN instance. The receiver
> side and transmit side ports can be completely independent of
> each other, as in any other client-server system.

Vxlan's are a weird beast. They can be viewed as either bridge like
entities or tunnel like entities. I view them more as bridge type
devices where user configures two hosts with equivalent values and
they learn about each other. In that case the code in 3.10 is broken;
but the version with the learning in net-next works.

Your view is that VXLAN's are more like tunnels, where each host
has static entries to know about every other host. In that mode,
3.10 is useable, but the same effect can be had by defining static
neighbour entries. 

Both views are valid, but I don't want the behaviour to change from
3.10 to 3.11, since 3.10 is not released yet, it makes more sense
to go back and remove IFLA_VXLAN_PORT from 3.10 and make it work
like 3.9.


> I think an administrator should have full flexibility to specify
> the ports and destinations as s/he sees fit and if you don't think
> that's a useful feature, you don't have to use it; the defaults
> work fine, too.

They can do that with neighbour entries.
