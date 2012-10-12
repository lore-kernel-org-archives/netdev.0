From: "Banerjee, Debabrata" <dbanerje@akamai.com>
Subject: Re: [PATCH] tcp resets are misrouted
Date: Fri, 12 Oct 2012 13:47:56 -0400
Message-ID: <CC9DCD9C.B68D%dbanerje@akamai.com>
References: <62162DF05402B341B3DB59932A1FA992BB7FD4730D@EUSAACMS0702.eamcs.ericsson.se>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"eric.dumazet@gmail.com" <eric.dumazet@gmail.com>,
	"sol@eqv.ru" <sol@eqv.ru>
To: Shawn Lu <shawn.lu@ericsson.com>,
	Debabrata Banerjee <dbavatar@gmail.com>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from prod-mail-xrelay02.akamai.com ([72.246.2.14]:42186 "EHLO
	prod-mail-xrelay02.akamai.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757703Ab2JLRzC convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 12 Oct 2012 13:55:02 -0400
In-Reply-To: <62162DF05402B341B3DB59932A1FA992BB7FD4730D@EUSAACMS0702.eamcs.ericsson.se>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I was trying to think of the scenario you were running into, since it
falls back to using a route lookup. You do not have routes on your machine
that would correctly send the packet, I assume? Then it simply comes down
to the kernel doesn't have enough information to know where to send the
packet.

Debabrata

On 10/12/12 1:31 PM, "Shawn Lu" <shawn.lu@ericsson.com> wrote:

>I admit the commit e2446eaa did break the reset in asymmetric case.
>There are also many use cases in interface binding, we don't want to
>break it too... I am ok with your patch, if asymmetric route take higher
>priority. Somehow, we need  come up with another one to resolve RST lost
>in binding interface case, otherwise, people using interface binding will
>find later on that RST break again...
>
>thanks!
>
>Shawn Lu <shawn.lu@ericsson.com>
>
>> -----Original Message-----
>> From: Debabrata Banerjee [mailto:dbavatar@gmail.com]
>> Sent: Friday, October 12, 2012 8:57 AM
>> To: Alexey Kuznetsov; Banerjee, Debabrata
>> Cc: netdev@vger.kernel.org; davem@davemloft.net; Shawn Lu;
>> eric.dumazet@gmail.com; sol@eqv.ru
>> Subject: Re: [PATCH] tcp resets are misrouted
>> 
>> On Fri, Oct 12, 2012 at 10:34 AM, Alexey Kuznetsov
>> <kuznet@ms2.inr.ac.ru> wrote:
>>
>> 
>> We ran into this as well and pulled that commit from our
>> tree, it was causing serious problems. Sending the RST back
>> on the iif was definitely the wrong thing to do. Patch looks
>> good to me.
>> 
>> Thanks,
>> Debabrata
>> 
