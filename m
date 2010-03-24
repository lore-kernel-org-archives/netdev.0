From: "Chris Friesen" <cfriesen@nortel.com>
Subject: Re: bug in bonding driver
Date: Wed, 24 Mar 2010 13:47:21 -0600
Message-ID: <4BAA6C49.3040404@nortel.com>
References: <4BAA58B3.2040504@nortel.com> <21160.1269458000@death.nxdomain.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, bonding-devel@lists.sourceforge.net
To: Jay Vosburgh <fubar@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from zrtps0kp.nortel.com ([47.140.192.56]:49126 "EHLO
	zrtps0kp.nortel.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751396Ab0CXTtd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Mar 2010 15:49:33 -0400
In-Reply-To: <21160.1269458000@death.nxdomain.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 03/24/2010 01:13 PM, Jay Vosburgh wrote:
> Chris Friesen <cfriesen@nortel.com> wrote:

>> The catch here is that slave->jiffies may not ever get updated after
>> being set initially, and on long-running systems jiffies will overflow.
>> That could cause this check to be true for a substantial amount of time
>> rather than for just a short period.

> 	Some quick fooling around suggests that if, for example,
> slave->jiffies is near the top of the range (ULONG_MAX - a few hundred),
> when jiffies gets up to around ULONG_MAX / 2 time_after_eq will flip
> from "after" to "before."
> 
> 	I don't think this is a particularly farfetched example, since
> jiffies is intentionally started near the top of the range, so
> slave->jiffies is likely to be high in the range after bonding is
> configured at boot.

Agreed.  If I understand it right the result of time_after_eq is only
valid if the result of the subtraction is less than LONG_MAX.

>> One way to fix it would be a boolean which tracks whether or not we've
>> gone past the time, and if we have then we don't bother actually
>> checking the time anymore.
> 
> 	It might be clearer to make the slave->jiffies some kind of
> countdown instead, perhaps reusing the slave->delay used for
> updelay/downdelay and eliminating slave->jiffies entirely.

Yes, that seems reasonable as well.

Chris
