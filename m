From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH] igb: add module param to set max-rss-queues.
Date: Fri, 24 Mar 2017 16:14:57 -0700
Message-ID: <20170324161457.13d86ee0@xeon-e3>
References: <1490389127-23171-1-git-send-email-greearb@candelatech.com>
        <20170324.141237.1992801159655201421.davem@davemloft.net>
        <255aaae0-8634-c6b5-f4aa-545d2f717aed@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Ben Greear <greearb@candelatech.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f50.google.com ([74.125.83.50]:35322 "EHLO
        mail-pg0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753478AbdCXXPF (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 24 Mar 2017 19:15:05 -0400
Received: by mail-pg0-f50.google.com with SMTP id t143so2022313pgb.2
        for <netdev@vger.kernel.org>; Fri, 24 Mar 2017 16:15:04 -0700 (PDT)
In-Reply-To: <255aaae0-8634-c6b5-f4aa-545d2f717aed@candelatech.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 24 Mar 2017 14:20:56 -0700
Ben Greear <greearb@candelatech.com> wrote:

> On 03/24/2017 02:12 PM, David Miller wrote:
> > From: greearb@candelatech.com
> > Date: Fri, 24 Mar 2017 13:58:47 -0700
> >  
> >> From: Ben Greear <greearb@candelatech.com>
> >>
> >> In systems where you may have a very large number of network
> >> adapters, certain drivers may consume an unfair amount of
> >> IRQ resources.  So, allow a module param that will limit the
> >> number of IRQs at driver load time.  This way, other drivers
> >> (40G Ethernet, for instance), which probably will need the
> >> multiple IRQs more, will not be starved of IRQ resources.
> >>
> >> Signed-off-by: Ben Greear <greearb@candelatech.com>  
> >
> > Sorry, no module params.
> >
> > Use generic run-time facilities such as ethtool to configure
> > such things.  
> 
> You cannot call ethtool before module load time, and that is when
> the IRQs are first acquired.  It may be way more useful to give each
> of 20 network adapters 2 irqs than have the first few grab 16 and the rest
> get lumped into legacy crap.

Almost all network devices do not acquire interrupts until device is brought up.
I.e request_irq is called from open not probe. This is done so that configuration
can be done and also so that unused ports don't consume interrupt space.
