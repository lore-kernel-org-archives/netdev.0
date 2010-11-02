From: Dan Rosenberg <drosenberg@vsecurity.com>
Subject: Re: [SECURITY] CAN info leak/minor heap overflow
Date: Tue, 02 Nov 2010 15:53:25 -0400
Message-ID: <1288727605.2504.21.camel@dan>
References: <1288722503.2504.14.camel@dan>  <4CD069D4.7010801@hartkopp.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, security@kernel.org
To: Oliver Hartkopp <socketcan@hartkopp.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.vsecurity.com ([209.67.252.12]:53458 "EHLO
	mx1.vsecurity.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755229Ab0KBTx2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Nov 2010 15:53:28 -0400
In-Reply-To: <4CD069D4.7010801@hartkopp.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


> Why is this bad? Can the addresses of CAN-BCM sock structs be used for
> anything from userspace?
> 
> For me they are just intented to be unique numbers ...
> 

This is a bad idea because it makes exploiting other kernel
vulnerabilities easier.  Exposing the address of an object in a slab
cache, especially an object that unprivileged users have some level of
control of, is just an invitation to use that structure when writing
exploits, for heap overflows or otherwise.

-Dan

> > Secondly,
> > on 64-bit platforms, up to 17 bytes may be copied into the buffer.
> 
> Hm - that's indeed not wanted. Will send a patch at least for this issue.
> 
> > Fortunately, structure padding will most likely prevent this from being
> > a problem, except for the trailing NULL byte, which may overwrite the
> > first byte of the next heap object.  Please name your procfile in a way
> > that doesn't leak information and fits into the desired name buffer.
> > 
> > -Dan
> > 
> 
> Regards,
> Oliver


