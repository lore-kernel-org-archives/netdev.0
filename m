From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [PATCH net-next 2/3] nfp: look for firmware image by device
 serial number and PCI name
Date: Thu, 27 Jul 2017 10:15:35 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6DD0043824@AcuExch.aculab.com>
References: <20170726180948.3220-1-jakub.kicinski@netronome.com>
        <20170726180948.3220-3-jakub.kicinski@netronome.com>
        <063D6719AE5E284EB5DD2968C1650D6DD0043717@AcuExch.aculab.com>
 <20170727022546.1fe8d1ea@cakuba.netronome.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "oss-drivers@netronome.com" <oss-drivers@netronome.com>
To: 'Jakub Kicinski' <jakub.kicinski@netronome.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out6.electric.net ([192.162.217.186]:54628 "EHLO
        smtp-out6.electric.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750836AbdG0KPj (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 27 Jul 2017 06:15:39 -0400
In-Reply-To: <20170727022546.1fe8d1ea@cakuba.netronome.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jakub Kicinski
> Sent: 27 July 2017 10:26
...
> > - use snprintf().
> 
> To effectively print an integer into an amply sized array?  I need to
> guarantee that the string will fit otherwise I would request a FW image
> with a wrong name.  snprintf() would only mask such a bug.

Eh?
If, for any reason, the buffer isn't long enough snprintf() won't
write over random memory - sprint() will, and you may not notice.

> > - kill those hh, the arguments are of type 'int'.
> 
> It doesn't matter.  I will be more careful in the future, though.
> 
> > In fact make 'interface' 'unsigned int' as well.
> 
> It's a value read from the hardware, and it's 16 bits wide, therefore
> my preference it to explicitly size the variable.

Right, so you keep asking the compiler to generate code to mask
any arithmetic results (written into the variable) back down to
16 bits.

OTOH, looking at some of the functions in nfp_cppcore.c you don't
care about performance at all.

	David
