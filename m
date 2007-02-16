From: lsorense@csclub.uwaterloo.ca (Lennart Sorensen)
Subject: Re: Re: Strange connection slowdown on pcnet32
Date: Fri, 16 Feb 2007 12:21:10 -0500
Message-ID: <20070216172110.GC7582@csclub.uwaterloo.ca>
References: <32943920.1119801171642884331.JavaMail.root@vms226.mailsrvcs.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: pcnet32@verizon.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from caffeine.uwaterloo.ca ([129.97.134.17]:40999 "EHLO
	caffeine.csclub.uwaterloo.ca" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932504AbXBPRVN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 Feb 2007 12:21:13 -0500
Content-Disposition: inline
In-Reply-To: <32943920.1119801171642884331.JavaMail.root@vms226.mailsrvcs.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Feb 16, 2007 at 10:21:24AM -0600, pcnet32@verizon.net wrote:
> Are there any messages in the log about timeouts, or anything else from the driver? When it gets in this state, can you communicate with another system, and does it have the same slow behavior?

Nope no timeouts or messages.  As far as the system looks, cpu and ram and
logs show nothing unusual.  Just very slow reception on the ethernet port
going towards the server providing the data for the transfer.  Messages do
get through eventually, but very very late (when a ping reply arives at
the port and takes 5 to 10 seconds to make it to the network stack, then
something isn't right, at least when there is no other traffic waiting).

I did have NAPI in the driver even in 2.6.8 (I was adding that at the
time).  I am now testing with 2.6.8 without NAPI (so no mask/unmask of
receive interrupts taking place), and so far it has run for over an hour
without failing, although that doens't prove it won't, just that it has
lasted longer.

I think I will try compiling 2.6.18 again with NAPI disabled on the
pcnet32 and see what that does.  There is a chance that something in the
NAPI implementation is breaking the chip's receive somehow although I
can't currently imagine what it could be or how.

--
Len Sorensen
