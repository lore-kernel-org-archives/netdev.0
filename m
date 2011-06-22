From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: Reported regression against commit a05d2ad
Date: Wed, 22 Jun 2011 11:00:56 -0700
Message-ID: <m1y60tlp9j.fsf@fess.ebiederm.org>
References: <20110621201528.GB2249@herton-IdeaPad-Y430>
	<m1oc1qnc46.fsf@fess.ebiederm.org> <4E02273E.2080000@canonical.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Herton Ronaldo Krzesinski <herton.krzesinski@canonical.com>,
	lamont@canonical.com, sconklin@canonical.com,
	netdev@vger.kernel.org
To: tim.gardner@canonical.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from out01.mta.xmission.com ([166.70.13.231]:47614 "EHLO
	out01.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758455Ab1FVSBA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Jun 2011 14:01:00 -0400
In-Reply-To: <4E02273E.2080000@canonical.com> (Tim Gardner's message of "Wed,
	22 Jun 2011 11:32:46 -0600")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Tim Gardner <tim.gardner@canonical.com> writes:

> On 06/21/2011 02:49 PM, Eric W. Biederman wrote:
> <snip>
>> I respectfully suggest that the bug is elsewhere perhaps a broken user
>> space application out there that needs to be fixed, or you have a kernel
>> memory stomp that removing patch a05d2ad happens to shift the memory
>> layout to be harmful in a different way.
>>
>
> OK, I'm remembering how PF_UNIX Unix domain sockets are used, so I think your
> theory about a misbehaving user space application is more likely. However, I am
> a bit confused about how an application can attempt to receive before the socket
> is fully opened. Some kind of race condition with socketpair() ?

The case that is relevant is a listening SOCK_SEQPACKET socket.

The case that is affected is when you call receive on a listening
socket.

It isn't that the socket isn't fully opened.  It is that accept is the
only legitimate operation at that point.

It took a mistake while someone was developing an application for this
kernel bug to be found.

Eric
