From: "Holger Hoffstaette" <holger@wizards.de>
Subject: Re: Reproducible data corruption with sendfile+vsftp - splice regression?
Date: Thu, 13 Dec 2007 03:19:43 +0100
Message-ID: <pan.2007.12.13.02.19.40.200510@wizards.de>
References: <pan.2007.11.29.23.42.52.661624@wizards.de> <474FC4D9.3020506@cosmosbay.com> <pan.2007.11.30.09.20.24.737500@wizards.de> <475055EE.9060105@hp.com> <pan.2007.12.02.16.00.03.568000@wizards.de> <pan.2007.12.02.20.49.42.675000@wizards.de> <20071205225429.GA10186@electric-eye.fr.zoreil.com> <pan.2007.12.06.09.28.08.913625@wizards.de> <20071206184426.GA32599@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from main.gmane.org ([80.91.229.2]:52793 "EHLO ciao.gmane.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751568AbXLMCUH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 12 Dec 2007 21:20:07 -0500
Received: from root by ciao.gmane.org with local (Exim 4.43)
	id 1J2dgA-0007bQ-8q
	for netdev@vger.kernel.org; Thu, 13 Dec 2007 02:20:02 +0000
Received: from port-87-234-135-174.dynamic.qsc.de ([87.234.135.174])
        by main.gmane.org with esmtp (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Thu, 13 Dec 2007 02:20:02 +0000
Received: from holger by port-87-234-135-174.dynamic.qsc.de with local (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Thu, 13 Dec 2007 02:20:02 +0000
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 06 Dec 2007 19:44:26 +0100, Francois Romieu wrote:

> Holger Hoffstaette <holger@wizards.de> : [...]
>> Maybe turning off sendfile or NAPI just lead to random success - so far
>> it really looks like tso on the r8169 is the common cause.
> 
> TSO on the r8169 is the magic switch but the regression makes imvho more
> sense from a VM pov:
> 
> - the corrupted file has the same size as the expected file - the
> corrupted file exhibits holes which come as a multiple of 4096 bytes
>   (8*4k, 2 places, there may be more)
> - the r8169 driver does not know what a page is - the 8169 hardware has a
> small 8192 bytes Tx buffer
> 
> It would be nice if someone could do a sendfile + vsftp test with TSO on a
> different hardware. While I could not reproduce the corruption when simply
> downloading a file that I had copied on the server with scp, it triggered
> almost immediately after I copied it locally and tried to download the
> copy.

Here's an update - sorry for the delay but I need that machine for everyday work.

I have now gone back to enable TSO since vsftp with sendfile really seems
to be the only app that causes this. I have simply set it to
use_sendfile=NO and no corruption occurs at all; the machine is stable and
fast.

FWIW the corruption can still be reproduced with 2.6.24-rc5. For kicks I
have also tried -rc5 with SLAB instead of SLUB, but that didn't help
either.

The directory with the tcpdump & test data now also contains a few more
corrupted files; maybe comparing the corruption offsets gives someone a
better idea.

thanks
Holger


