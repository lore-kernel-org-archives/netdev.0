From: "H. Peter Anvin" <hpa@zytor.com>
Subject: Re: FYI: tftp-hpa breaks when used on secondary ip addresses
Date: Fri, 04 Mar 2011 17:31:00 -0800
Message-ID: <4D719254.8000903@zytor.com>
References: <m1sjv2qt68.fsf@fess.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Joel Sing <jsing@google.com>,
	David Miller <davem@davemloft.net>
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from terminus.zytor.com ([198.137.202.10]:60537 "EHLO mail.zytor.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751852Ab1CEBbK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 4 Mar 2011 20:31:10 -0500
In-Reply-To: <m1sjv2qt68.fsf@fess.ebiederm.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 03/04/2011 04:58 PM, Eric W. Biederman wrote:
> 
> Which if fails now if you happen to be running tftp-hpa on a secondary
> ip address on the same subnet as your first ip.  Because pref_source
> in the routing table points at the first ip.
> 
> The change in kernel behavior appears to be from the commit below to
> honor the preferred source address in local connections.
> 

If this is done for all local connections (as opposed to the ones that
have been configured explicitly by the administrator to behave that
way), that's a massive lossage.  Not only does a large number of
applications use this trick to determine if an address is local (e.g.
allowing bypass) -- it is pretty much the only portable way to do it --
but it would cause applications which expect to get a reply back from
the same address they sent a request to to completely fall on their face.

tftp-hpa needs this information in order to handle clients that send
their initial request to a broadcast (or multicast) address.

> This all seems very fuzzy to me and mostly this appears to be a bug in
> tftp-hpa but since I tracked it down I figured I would let everyone
> know what happened.

This seems like a broken change to me, or at the very least having
seriously unintended consequences.

	-hpa
