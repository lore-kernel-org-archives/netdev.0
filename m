From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH iproute2] Ability to compile iproute2 as shared library
Date: Thu, 12 Jul 2012 09:03:30 -0700
Message-ID: <20120712090330.38dd5b37@nehalam.linuxnetplumber.net>
References: <1342093501.19963.11.camel@gol>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: hamid jafarian <hamid.jafarian@pdnsoft.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:43100 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1030689Ab2GLQDu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 12 Jul 2012 12:03:50 -0400
In-Reply-To: <1342093501.19963.11.camel@gol>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 12 Jul 2012 16:14:54 +0430
hamid jafarian <hamid.jafarian@pdnsoft.com> wrote:

> Hi,
> 
> This is a try with minimum changes to compile iproute2 as shared
> library.
> Some functions would be used when we compile iproute2 as
> shared library has been defined in "ip.c".
> Also NICs caching strategy has been changed because, when we use
> "libiproute2.so", system NIC list may change, so we should
> re-cache all NICs at each call to NIC manipulation functions.
> Also some call of "exit(*)" changed to "return *".
> HOWTO Make: # export LIBIPROUTE2_SO=y; make
> 
> in attached files there is a simple wrapper to work with 
> libiproute2.so ...
> 

Thank you for the contribution. I can see how this could be useful
in some limited embedded applications, but at this moment it doesn't
seem to be generally worth adding to the upstream code.

The patch does contain some cleanup bits for where the existing
code is not freeing stuff. This should be fixed, independent of
whether library support is added, because it would remove the number
of leaks reported when testing under valgrind. Could you resubmit
that part please.
