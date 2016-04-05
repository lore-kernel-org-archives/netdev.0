From: Jakub Kicinski <jakub.kicinski@netronome.com>
Subject: Re: [PATCH v4 net-next 01/15] nfp: correct RX buffer length
 calculation
Date: Tue, 5 Apr 2016 18:24:56 +0100
Message-ID: <20160405182456.1dfbb3e7@jkicinski-Precision-T1700>
References: <1459544811-24879-1-git-send-email-jakub.kicinski@netronome.com>
	<1459544811-24879-2-git-send-email-jakub.kicinski@netronome.com>
	<20160405.113917.846241936652070162.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f43.google.com ([74.125.82.43]:36119 "EHLO
	mail-wm0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752385AbcDERZC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Apr 2016 13:25:02 -0400
Received: by mail-wm0-f43.google.com with SMTP id 127so31879200wmu.1
        for <netdev@vger.kernel.org>; Tue, 05 Apr 2016 10:25:01 -0700 (PDT)
In-Reply-To: <20160405.113917.846241936652070162.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 05 Apr 2016 11:39:17 -0400 (EDT), David Miller wrote:
> From: Jakub Kicinski <jakub.kicinski@netronome.com>
> Date: Fri,  1 Apr 2016 22:06:37 +0100
> 
> > When calculating the RX buffer length we need to account for
> > up to 2 VLAN tags and up to 8 MPLS labels.  Rounding up to 1k
> > is an relic of a distant past and can be removed.  While at
> > it also remove trivial print statement.
> > 
> > Signed-off-by: Jakub Kicinski <jakub.kicinski@netronome.com>  
> 
> I disagree with the MPLS aspect of this change.
> 
> VLAN is special, in that when the hardware supports VLAN properly, the
> VLAN header doesn't eat into the MTU and is sort of "transparent".
> 
> But MPLS doesn't work that way.
> 
> MPLS is in the main frame and takes up MTU space.

Makes sense.  RFC3032 counts MPLS label stack as Frame Payload.
 
> Therefore I see no reason to increase the buffer length by 8 * MPLS
> which is just a rediculous amount of wasted space.
> 
> I'm not applying this without at least some more explanations about
> why exactly you need to account for these values in the commit message.

It's just what FW guys asked me for.  I'll try to find out what their
reasoning was.  

I have a patch queued up which gets rid of unconditionally reserving
64B for firmware prepend, I guess that made me too excited to pay
attention to the fact the accounting for MPLS is indeed questionable...
