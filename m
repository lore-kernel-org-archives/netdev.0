From: Chris Friesen <chris.friesen@genband.com>
Subject: Re: why is it not allowed to add a new socket protocol family as
 an external module?
Date: Thu, 21 Feb 2013 11:58:04 -0600
Message-ID: <5126602C.5000003@genband.com>
References: <5125002D.9080008@genband.com>		 <20130220152325.64c57d55@samsung-9> <51256E02.4080509@genband.com>	 <1361410797.17413.3.camel@edumazet-glaptop> <51264195.9060800@genband.com> <1361464988.17413.6.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <stephen@networkplumber.org>,
	netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exprod7og121.obsmtp.com ([64.18.2.20]:37483 "EHLO
	exprod7og121.obsmtp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754238Ab3BUR6k (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Feb 2013 12:58:40 -0500
In-Reply-To: <1361464988.17413.6.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 02/21/2013 10:43 AM, Eric Dumazet wrote:
> On Thu, 2013-02-21 at 09:47 -0600, Chris Friesen wrote:

>> The three lock_class_key structs (corresponding to
>> af_family_keys/af_family_slock_keys/af_callback_keys) can be
>> auto-allocated by the network core at dynamic registration time.
>
> Nope, this was the point I specifically raised but you missed it
>
> Take a look at kernel/lockdep.c, lines 2981-2988
>
> All the other stuff you mention seems pretty obvious.

Ah, sorry.  I'm not familiar with the guts of lockdep, so I was not 
aware that the keys needed to be static.

Given that the lockdep code considers module addresses to be okay, it 
should work to make the keys static in the KLM implementing the new 
protocol and pass the addresses in at registration time.

Chris
