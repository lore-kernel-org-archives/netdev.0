From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: ip-token: unable to remove a token & multi-token handling & concurrent
 use w/ EUI64/privacy
Date: Tue, 22 Mar 2016 18:03:24 +0100
Message-ID: <56F17ADC.9080806@iogearbox.net>
References: <robbat2-20160319T175636-156562343Z@orbis-terrarum.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, hannes@stressinduktion.org
To: "Robin H. Johnson" <robbat2@gentoo.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:38697 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751242AbcCVRD2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Mar 2016 13:03:28 -0400
In-Reply-To: <robbat2-20160319T175636-156562343Z@orbis-terrarum.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Robin,

On 03/19/2016 07:53 PM, Robin H. Johnson wrote:
[...]
> Playing around with IPv6 tokens, I ran into a problem:
> Once you have a token set on an interface, it's impossible to remove it!
>
> # ip token set :: dev eth0
> RTNETLINK answers: Invalid argument

I'll have a look into a fix, I think this was intentional, but I currently
fail to recall a reason why (should have put a note into the commit log). ;)
The draft is pretty terse in any case, it seems as we only invalidate other
tokenized addresses, it should be okay to just remove it.

> This is a side-effect of rejecting ipv6_addr_any in inet6_set_iftoken.
>
> While this gets fixed, I have two related feature requests for this:
> - Please make it possible to configure multiple tokens on an interface:
>    Use case: Deploying local services on well-known addresses inside a
>    network without explicit prefix configuration.
> - Adding a token causes other address generation methods to be disabled,
>    this is problematic if you wish to prefer privacy addresses for
>    outbound connections.
>
> Design suggestion:
> Convert from using a single token to using a list of tokens, with an
> explicit default IPv6-any-addr (::) in the list, to represent that
> other address generation should ALSO take place (EUI64/privacy).
> Deletion of the any-addr from the list should disable EUI64/privacy
> addresses.

Seems you already have some patches, please feel free to send them. ;)

Thanks for the feedback!
Daniel
