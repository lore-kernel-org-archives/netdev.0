From: David Stevens <dlstevens@us.ibm.com>
Subject: Re: [PATCH] Multicast: Avoid useless duplication of multicast messages
Date: Wed, 15 Apr 2009 15:16:33 -0700
Message-ID: <OF0CB99079.B56E714F-ON88257599.0079319C-88257599.007A5C56@us.ibm.com>
References: <alpine.DEB.1.10.0904141447310.30596@qirst.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	netdev-owner@vger.kernel.org, Neil Horman <nhorman@tuxdriver.com>
To: Christoph Lameter <cl@linux.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e38.co.us.ibm.com ([32.97.110.159]:57561 "EHLO
	e38.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751546AbZDOWQh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Apr 2009 18:16:37 -0400
In-Reply-To: <alpine.DEB.1.10.0904141447310.30596@qirst.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Actually, I think having an option for Solaris
compatibility might be a good idea, but I think
it should be per-socket.

I know of at least one application (a JVM) in
the wild that relies on the current behavior--
joins are done in one process for sockets in
another. It isn't necessarily obvious what
will break if you turn it off globally.

I tend to agree with Neil that it really shouldn't
be necessary, but there is no doubt it causes
great confusion to people.

Also, for the record, Linux doesn't support SSM
per RFC 4607. The filtering it requires applies
only to its address range and it explicitly states
the current Linux model as part of the reasoning
for it in the SSM address range only. That indicates
to me it is incorrect to filter all multicasts that
way, as Solaris does.

Doing something per-socket to express what you want
easily is fine with me and, as long as it defaults to
standard behavior, not a standards issue. Changing
all sockets on the machine from existing, correct
behavior I think is not appropriate.

                                                +-DLS

