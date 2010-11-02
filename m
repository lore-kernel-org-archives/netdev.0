From: Oliver Hartkopp <socketcan@hartkopp.net>
Subject: Re: [SECURITY] CAN info leak/minor heap overflow
Date: Tue, 02 Nov 2010 20:43:16 +0100
Message-ID: <4CD069D4.7010801@hartkopp.net>
References: <1288722503.2504.14.camel@dan>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: urs.thuermann@volkswagen.de, netdev@vger.kernel.org,
	security@kernel.org
To: Dan Rosenberg <drosenberg@vsecurity.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mo-p00-ob.rzone.de ([81.169.146.161]:60842 "EHLO
	mo-p00-ob.rzone.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751077Ab0KBTna (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Nov 2010 15:43:30 -0400
In-Reply-To: <1288722503.2504.14.camel@dan>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello Dan,

On 02.11.2010 19:28, Dan Rosenberg wrote:
> In bcm_connect() (in net/can/bcm.c), I noticed the following code:
> 
> 	sprintf(bo->procname, "%p", sock);
> 
> "procname" is a 9-byte char array.  This code is wrong on two levels.
> First, leaking a kernel address via a /proc filename is bad.

Why is this bad? Can the addresses of CAN-BCM sock structs be used for
anything from userspace?

For me they are just intented to be unique numbers ...

> Secondly,
> on 64-bit platforms, up to 17 bytes may be copied into the buffer.

Hm - that's indeed not wanted. Will send a patch at least for this issue.

> Fortunately, structure padding will most likely prevent this from being
> a problem, except for the trailing NULL byte, which may overwrite the
> first byte of the next heap object.  Please name your procfile in a way
> that doesn't leak information and fits into the desired name buffer.
> 
> -Dan
> 

Regards,
Oliver


