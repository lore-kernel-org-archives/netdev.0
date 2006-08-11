From: Michael Tokarev <mjt@tls.msk.ru>
Subject: Re: [NET 00/06]: Increase number of possible routing tables
Date: Fri, 11 Aug 2006 10:56:34 +0400
Message-ID: <44DC2A22.2080905@tls.msk.ru>
References: <20060810192957.14867.71965.sendpatchset@localhost.localdomain>	<44DC2617.7020200@tls.msk.ru> <20060810.234414.89236927.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: kaber@trash.net, netdev@vger.kernel.org, patrick@tykepenguin.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from hobbit.corpit.ru ([81.13.94.6]:45151 "EHLO hobbit.corpit.ru")
	by vger.kernel.org with ESMTP id S1161138AbWHKG4l (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 Aug 2006 02:56:41 -0400
To: David Miller <davem@davemloft.net>
In-Reply-To: <20060810.234414.89236927.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David Miller wrote:
> From: Michael Tokarev <mjt@tls.msk.ru>
[]
>>> - Use u32 for routing table IDs everywhere inside the kernel
>> Just out of curiocity: why current limit of 2^31 isn't sufficient?
>> Or am I missing the point?
> 
> The current limit is 256 because the table member of the struct
> used to configure them is an 8-bit quantity.
> 
> That's the whole purpose of Patrick's patch set, to provide a new
> optional attribute that allows specifying a 32-bit rather than
> the 8-bit table ID.

Aha, it was 256, not 2^31.  I remember now.

So the question probably should have been like, why u32 and additional
attribute (to represent former -1) instead of current int?  I mean,
it probably makes no difference whenever there are 2^32 or 2^31 tables
(both values are pretty large), but 2^32 requires more changes for the
existing code.

And while we're at it...  How about using table *names* instead of
numbers in kernel too, a-la iptables?  Once possible number of tables
is large, and we're using hashes for tables now anyway, keeping a
name inside the table structure wont hurt ;)

/mjt
