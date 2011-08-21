From: Corey Hickey <bugfood-ml@fatooh.org>
Subject: Re: strange routing issue--packets stop getting forwarded for a live
 connection
Date: Sun, 21 Aug 2011 01:12:43 -0700
Message-ID: <4E50BDFB.7050502@fatooh.org>
References: <4E506A46.6060407@fatooh.org> <alpine.LFD.2.00.1108210924010.1581@ja.ssi.bg>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>
To: Julian Anastasov <ja@ssi.bg>
Return-path: <netdev-owner@vger.kernel.org>
Received: from juniper.fatooh.org ([173.255.221.30]:57420 "EHLO
	juniper.fatooh.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750878Ab1HUIMp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 21 Aug 2011 04:12:45 -0400
In-Reply-To: <alpine.LFD.2.00.1108210924010.1581@ja.ssi.bg>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2011-08-20 23:35, Julian Anastasov wrote:
>> I have a strange issue where, reliably, certain conditions cause my
>> Linux router to stop forwarding packets for a connection.

[...]

>> 3. MTU size; 1500 on eth0 and 1406 on tun0. Bigger packets have been
>> transferred fine.
> 
> 	Lower MTU, it can be PMTUD problem. At 04:50:24.112658
> I see 7801:9169 is 1420 bytes and no ICMP FRAG NEEDED is generated.
> May be these two regressions explain it:
> 
> http://marc.info/?l=linux-netdev&m=131342172722536&w=2
> 
> 	There are 2 fixes you can try or more recent kernel
> tree, for example 3.1-rc2 has the fixes.

Many thanks for your reply--it looks like you're on to something. You
didn't specify which interface to lower the MTU on, so I tried them each
in turn, and found that lowering the MTU on the client machine to 1406
(matching tun0 on the router) did indeed solve the problem. That makes
sense in retrospect.

It's a bit late at night for me to be patching my kernel, but I'll see
if I can do it tomorrow.

Thanks again, and I'll let you know how it turns out.

-Corey
