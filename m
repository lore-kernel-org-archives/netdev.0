From: "Yurij M. Plotnikov" <Yurij.Plotnikov@oktetlabs.ru>
Subject: Re: PMTU discovery is broken on kernel 3.7.1 for UDP sockets
Date: Mon, 21 Jan 2013 15:31:20 +0400
Message-ID: <50FD2708.6060906@oktetlabs.ru>
References: <50D1BCC0.2000208@oktetlabs.ru> <1355924119.2676.6.camel@bwh-desktop.uk.solarflarecom.com> <50D1CECE.7090706@oktetlabs.ru> <1355945864.2676.21.camel@bwh-desktop.uk.solarflarecom.com> <20121220073445.GM18940@secunet.com> <50D2F4E5.4050904@oktetlabs.ru> <20121220123535.GN18940@secunet.com> <20121221102253.GO18940@secunet.com> <50F3C153.9030204@oktetlabs.ru> <20130118081145.GB24987@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Ben Hutchings <bhutchings@solarflare.com>, netdev@vger.kernel.org,
	"Alexandra N. Kossovsky" <Alexandra.Kossovsky@oktetlabs.ru>
To: Steffen Klassert <steffen.klassert@secunet.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shelob.oktetlabs.ru ([195.131.132.186]:44115 "EHLO
	shelob.oktetlabs.ru" rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752332Ab3AULbb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Jan 2013 06:31:31 -0500
In-Reply-To: <20130118081145.GB24987@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/18/13 12:11, Steffen Klassert wrote:
> On Mon, Jan 14, 2013 at 12:26:59PM +0400, Yurij M. Plotnikov wrote:
>    
>> Could you, please, tell me is there any news about this bug?
>>
>>      
> Ok, I tried to reconstruct your testcase and I can confirm this bug.
> It happens only on the first pmtu event on a given route. It works
> if I run this test again. Actually it works sometimes even on the
> first pmtu event, so it took me quite a while to understand what's ging on.
>
> This is because standart routes (no pmtu or redirect events happened on
> that route) are per cpu, so each cpu has it's own struct rtable. This means
> that we do not invalidate the socket cached route if the NET_RX_SOFTIRQ
> (which handles the pmtu event) is not served by the same cpu that the
> sending socket uses. Exceptional routes (routes where a pmtu or redirect
> event occured) are not per cpu, so there is no problem.
>
> I'll send three patches in reply to this mail. Applying patch one and two
> should fix the bug you reported. If you use IPsec you need patch three too.
> The patches are marked as RFC, I'll do proper patch submission if you can
> confirm that they fix this bug.
>    
Sorry for long delay. I've just checked patches 1+2 and they fix the bug 
for me.

Yurij.
