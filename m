From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: Netlink for kernel<->user space communication?
Date: Tue, 24 Apr 2012 16:57:55 -0700
Message-ID: <20120424165755.76432821@nehalam.linuxnetplumber.net>
References: <4F973CC1.8000002@xdin.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Arvid Brodin <Arvid.Brodin@xdin.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:50240 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754063Ab2DXX56 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 24 Apr 2012 19:57:58 -0400
In-Reply-To: <4F973CC1.8000002@xdin.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 24 Apr 2012 23:52:34 +0000
Arvid Brodin <Arvid.Brodin@xdin.com> wrote:

> Hi.
> 
> I'm writing a kernel driver for the HSR protocol, a standard for high availability
> networks. I want to send messages from the kernel to user space about broken network
> links. I also want user space to be able to ask the kernel about its view of the status of
> nodes on the network.
> 
> Netlink seems like a good tool for this. (Is it?)

Yes.

> But do I use raw netlink? (Described here: http://www.linuxjournal.com/article/7356 - but
> this seems a bit out of date, the kernel API description differs from today's kernel
> implementation.)

No. Your driver probably looks like a device so you should be
using rtnetlink messages.

> Or do I use the "Kernel Connector" (Documentation/connector/connector.txt)?
no.

> Do I use libnetlink?
if you extend iproute2 to support your link type, then yes,
but use the version inside iproute2 (rather than the older extracted libnetlink
in some distros).

> Or do I use libnl? (This seems to be actively maintained.)
If you aren't going to be in iproute2 then use libmnl. libnl does lots
of caching etc, which makes it good for monitoring and gui tools but a pain
for simple management.

Advice is free, code is what counts.
