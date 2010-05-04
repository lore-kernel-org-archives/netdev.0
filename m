From: David Stevens <dlstevens@us.ibm.com>
Subject: Re: linux kernel's IPV6_MULTICAST_HOPS default is 64; should be 1?
Date: Tue, 4 May 2010 00:48:46 -0700
Message-ID: <OF8BB88147.4F3756DA-ON88257719.002A895A-88257719.002AEB08@us.ibm.com>
References: <AANLkTimf-FWCsiLqYDGg4nl-relRMuNvDowfTKZbe9kx@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Cc: brian.haley@hp.com, David Miller <davem@davemloft.net>,
	netdev@vger.kernel.org, netdev-owner@vger.kernel.org
To: enh <enh@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e34.co.us.ibm.com ([32.97.110.152]:59397 "EHLO
	e34.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756532Ab0EDHsw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 May 2010 03:48:52 -0400
In-Reply-To: <AANLkTimf-FWCsiLqYDGg4nl-relRMuNvDowfTKZbe9kx@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

It's set to -1 by default, but the common code for unicast and
multicast in getsockopt is falling through to use the dst_entry.

I believe (though I haven't actually tried it recently) it actually
uses "1" for the default value for multicast; it just doesn't
report it correctly. It should distinguish multicast from unicast
in the <0 check in getsockopt.
                                        +-DLS

