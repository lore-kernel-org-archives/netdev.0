From: Florian Weimer <fweimer@redhat.com>
Subject: Re: [PATCH] glibc: Terminate process on invalid netlink response from
 kernel [BZ #12926]
Date: Tue, 3 Nov 2015 15:00:03 +0100
Message-ID: <5638BDE3.2040608@redhat.com>
References: <562A9391.1040806@redhat.com>
 <1446558492.1880442.427793993.78B20B4F@webmail.messagingengine.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 8bit
Cc: Hannes Sowa <hannes@redhat.com>, netdev@vger.kernel.org
To: Hannes Frederic Sowa <hannes@stressinduktion.org>,
	GNU C Library <libc-alpha@sourceware.org>,
	davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:38410 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751019AbbKCOAG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 3 Nov 2015 09:00:06 -0500
In-Reply-To: <1446558492.1880442.427793993.78B20B4F@webmail.messagingengine.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/03/2015 02:48 PM, Hannes Frederic Sowa wrote:
> Hello,
> 
> On Fri, Oct 23, 2015, at 21:07, Florian Weimer wrote:
>> (By the way, we'd also love to have a better kernel interface to fulfill
>> the needs for getaddrinfo address sorting.  The netlink requests we
>> currently use are much too slow if the host has many addresses
>> configured.)
> 
> One solution would be to finish the IPv6 ioctl interface to list
> addresses. The ioctl interface would need less memory allocations and is
> a synchronous interface which would make it much more easier for glibc
> to deal with. No timeouts and retries like with netlink are necessary.

The more fundamental question is whether we actually have to copy all
the addresses to userspace.  In the end, it may be better to hand a list
of destination addresses to the kernel and have it sort them according
to some algorithm.  But for the algorithm proposed in RFC 6724 section
6, this may be not worth the effort because there are so many
configurable bits.

I still think most of the address sorting is bogus because it appears to
make guarantees which can break after renumbering.

Florian
