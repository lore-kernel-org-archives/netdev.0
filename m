From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: HTB accuracy for high speed (and bonding)
Date: Sat, 23 May 2009 17:35:25 +0200
Message-ID: <20090523153525.GA2896@ami.dom.local>
References: <20090519140416.GA21270@francoudi.com> <20090519201027.GA4751@ami.dom.local> <1242857245.13519.17.camel@hazard2.francoudi.com> <4A148838.8010809@cosmosbay.com> <20090521072050.GA2892@ami.dom.local> <20090521074400.GA19113@francoudi.com> <20090521082805.GB2892@ami.dom.local> <1243075052.27210.22.camel@hazard2.francoudi.com> <20090523143432.GA2766@ami.dom.local> <20090523150630.GA4228@francoudi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Eric Dumazet <dada1@cosmosbay.com>, netdev@vger.kernel.org
To: Vladimir Ivashchenko <hazard@francoudi.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f174.google.com ([209.85.218.174]:55105 "EHLO
	mail-bw0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753370AbZEWPgG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 23 May 2009 11:36:06 -0400
Received: by bwz22 with SMTP id 22so2188885bwz.37
        for <netdev@vger.kernel.org>; Sat, 23 May 2009 08:36:06 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20090523150630.GA4228@francoudi.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, May 23, 2009 at 06:06:30PM +0300, Vladimir Ivashchenko wrote:
> > > So, I got rid of bonding completely and instead configured PBR on Cisco
> > > + Linux routing in such a way so that packet gets received and
> > > transmitted using NICs connected to the same pair of cores with common
> > > cache. 65-70% idle on all cores now, compared to 0-30% idle in worst
> > > case scenarios before.
> > 
> > As a matter of fact I don't understand this bonding idea vs. smp: I
> > guess Eric Dumazet wrote why it's wrong wrt. locking. I'm not an smp
> > expert but I think the most efficient use is with separate NICs per
> > cpu (so with separate HTB qdiscs if possible), or multiqueue NICs -
> 
> I tried the following scenario: 2 NICs used for receive + another 2 NICs 
> used for transmit having HTB. Each NIC on a separate core. No bonding, 
> just manual load balancing using IP routing.
> 
> The result was that RX cores would be 20% and 40% idle respectively, even 
> though the amount of traffic they were receiving was roughly the same. 
> The TX cores were idling at around 90%. 

There is not enough data to analyse this, but generally you should aim
at maintaining one flow (RX + TX) on the same cpu cache.

Jarek P.
