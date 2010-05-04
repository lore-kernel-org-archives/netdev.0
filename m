From: David Stevens <dlstevens@us.ibm.com>
Subject: Re: linux kernel's IPV6_MULTICAST_HOPS default is 64; should be 1?
Date: Tue, 4 May 2010 09:12:59 -0700
Message-ID: <OFD462DFA3.FF279B8C-ON88257719.0057B1F8-88257719.005914D6@us.ibm.com>
References: <4BE031FA.6040006@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Cc: David Miller <davem@davemloft.net>, enh@google.com,
	netdev@vger.kernel.org, netdev-owner@vger.kernel.org
To: Brian Haley <brian.haley@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e35.co.us.ibm.com ([32.97.110.153]:53250 "EHLO
	e35.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933550Ab0EDQNO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 May 2010 12:13:14 -0400
In-Reply-To: <4BE031FA.6040006@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I think the original code was intending to do late binding -- carry "-1" 
as
meaning "not set by user" and use the default value _at_the_time_of_
_the_send_, and in its context. For that to have worked, the checks for
"<0" in the send paths should've checked for multicast and used the
multicast default as you're saying, Brian. And doing that not on the
set, but when generating packets, is what I would've expected.

I don't see anything that's broken by changing it to use the default at
the time of the set since for mcast the default is really a constant,
and in fact, it looks like in addition to not actually using the default 
of 1,
it was returning "-1" in the cmsg when not set by the user (and it, too,
should've been "1", which it would return now).

But if the default is different for each destination or interface in
the multicast case (ie, by adding conf settings for mcast), then
it really should do late binding and leave it as "-1" in the set, right?
That's what I thought it was already doing, but apparently not;
I think it used to, but maybe I just didn't notice.

                                        +-DLS

