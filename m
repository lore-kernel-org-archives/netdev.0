From: Jan Engelhardt <jengelh@computergmbh.de>
Subject: Re: Netfilter and IPSec
Date: Tue, 15 Apr 2008 13:26:48 +0200 (CEST)
Message-ID: <alpine.LNX.1.10.0804151322470.13202@fbirervta.pbzchgretzou.qr>
References: <480423CD.3060707@lasige.di.fc.ul.pt>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netfilter@vger.kernel.org, netdev@vger.kernel.org
To: =?UTF-8?Q?F=C3=A1bio_Souto?= <fsouto@lasige.di.fc.ul.pt>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sovereign.computergmbh.de ([85.214.69.204]:44239 "EHLO
	sovereign.computergmbh.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757978AbYDOL0t (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Apr 2008 07:26:49 -0400
In-Reply-To: <480423CD.3060707@lasige.di.fc.ul.pt>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Tuesday 2008-04-15 05:41, F=C3=A1bio Souto wrote:
>
> I'm trying to find out some alternatives for a task I have been
> assigned. Basically, I want to sign IPSec packets on another
> machine. The idea is when I receive an IPSec packet, I delegate the
> cryptographic signature generation to another machine, and I
> receive the signed packet.
>
> I'm currently studying several alternatives for doing this, and
> even tried a socket-based approach, by changing some kernel
> modules, which has failed. It would require a huge remake of kernel
> code; this task is made even harder due to lack of documentation.
>
> So I was wondering if anyone knew if with netfilter is possible to
> achieve this. Any other suggestions/hints would be extremely
> valued.

The situation is deliberate, yes. IPsec is done in what you could
call the xfrm subsystem, not netfilter. To that end, the only
suggestion I could give is that you create a new xfrm policy/state
from esp where esp is split into your encryption and signing
"targets".

It kinda brings me the question why the ipsec transformation is
not done with an xtables target instead; that would also give
handy access to connection tracking if needed.
