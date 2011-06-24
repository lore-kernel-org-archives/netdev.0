From: John Haxby <john.haxby@oracle.com>
Subject: Re: [PATCH]: Add Network Sysrq Support
Date: Fri, 24 Jun 2011 15:37:14 +0100
Message-ID: <4E04A11A.7000104@oracle.com>
References: <20110621130040.12035.62533.sendpatchset@prarit.bos.redhat.com> <4E0115B3.2030802@redhat.com> <20110621225645.GD16021@Chamillionaire.breakpoint.cc> <20110621.155816.1840729860084652508.davem@davemloft.net> <4E01C34F.6050009@redhat.com> <20110622105434.GE16021@Chamillionaire.breakpoint.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Prarit Bhargava <prarit@redhat.com>,
	David Miller <davem@davemloft.net>, fbl@redhat.com,
	netdev@vger.kernel.org, agospoda@redhat.com, nhorman@redhat.com,
	lwoodman@redhat.com
To: Florian Westphal <fw@strlen.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rcsinet10.oracle.com ([148.87.113.121]:29395 "EHLO
	rcsinet10.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758274Ab1FXOho (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 24 Jun 2011 10:37:44 -0400
In-Reply-To: <20110622105434.GE16021@Chamillionaire.breakpoint.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 22/06/11 11:54, Florian Westphal wrote:
> Patrick McHardy suggested an alternative standalone method involving
> encapsulation sockets; perhaps the reasons why this path was not chosen
> have changed.
>
> I think that a standalone module (i.e. not requiring netfilter) that
> runs the sysreq handling after all netfilter hooks would be optimal,
> but I don't see a simple method to implement that.

Having just read the entire thread I have some different comments.

I think I mentioned that the standalone module didn't fly because I was
using an encapsulation socket: this preserved the ability to protect the
sysrq with iptables and also kept things nice and simple.  Unfortunately
that also meant I lost IPv6 ....

One of the comments in the thread (sorry, I've lost the attribution, not
to mention the exact quote) was that you would be crazy to run this in
production.    Hmmm.   One of the principle use cases of this is
precisely to run the code in production: machines in production do go
AWOL for all kinds of reasons and being able to run sysrq-m, t, s and c
is particularly useful.   It would be nice to be able to go up to the
machine and type on its keyboard.  If only it was even on the same
continent.   If only it a keyboard.  Or even a PS/2 keyboard socket
(getting a USB keyboard to configure itself when the machine is wedged
is, well, unlikely).

The changes I made to the xt_SYSRQ hashing a while back to avoid things
like replay were precisely because it needs to be run in a production
environment.   I've just submitted a patch that makes replay to other
machines that have the same password less likely to succeed, again, with
a view to how this thing would be used in production.

Sorry if I've repeated some things that have already been said.

jch
