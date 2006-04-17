From: edwin@gurde.com
Subject: Re: [PATCH][RFC] Security marking
Date: Mon, 17 Apr 2006 21:40:53 +0300 (EEST)
Message-ID: <20060417184053.6D618378FD@localhost.localdomain>
Cc: netdev@vger.kernel.org, fireflier-devel@lists.sourceforge.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 216.255.188.82-custblock.intercage.com ([216.255.188.82]:33724
	"EHLO main.astronetworks.net") by vger.kernel.org with ESMTP
	id S1751174AbWDQSlU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 17 Apr 2006 14:41:20 -0400
To: jmorris@namei.org
In-Reply-To: Pine.LNX.4.64.0604160012500.16600@d.namei
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Secmark, or skfilter is exactly what fireflier needs to solve the shared socket issue. Thanks for working on this.
If this gets integrated in mainline, fireflier LSM will be dropped. 

Is it possible to have an SELinux policy that reinjects the packets if didn't match any rules?
I.e. if a program that listens on port 80 doesn't have access to the packet, (because it doesn't have the proper domain,)
and the SELinux won't allow the program to read the packet: is it possible to reinject this packet in the netfilter chain,
instead of dropping it?

This would allow creating rules interactively (fireflier). 

But it could also be used for other purposes.
For example: if the program that listens on that port crashes, that means no program would match the required domain+port.
if in that case the packet would be reinjected, then the packet could be rerouted (by adding proper rules to mangle the packet)
to a different program/computer. AFAIK this isn't currently possible with netfilter (please correct me if I'm wrong).

What does the secmark currently do with packets that aren't allowed by policy to be received?

P.S.: Where can I get the full secmark patches, so I can test them to see if they really fit my needs?
Do you have an estimate timeline for mainline integration? (in terms of n weeks, m months)

Cheers,
Edwin
