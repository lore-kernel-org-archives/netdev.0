From: Steven Barth <cyrus@openwrt.org>
Subject: Re: [PATCH v2] ipv6: fix inconsistent prefix route handling
Date: Mon, 17 Feb 2014 14:13:27 +0100
Message-ID: <53020AF7.60702@openwrt.org>
References: <20140216165128.GF8634@order.stressinduktion.org> <5301AF26.7080102@openwrt.org> <20140217130557.GC22833@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Hannes Frederic Sowa <hannes@stressinduktion.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from chi.subsignal.org ([188.40.166.11]:41153 "EHLO
	chi.subsignal.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751594AbaBQNNa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Feb 2014 08:13:30 -0500
In-Reply-To: <20140217130557.GC22833@order.stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ah sorry, maybe I was a bit unclear about this. With temporary addresses 
I meant addresses created like this:

ip address add 2001:db8::1/64 dev eth0 valid_lft 1234 preferred_lft 1001

or the equivalent netlink-calls and with permanent addresses i was 
referring to addresses created similarly but with an infinite lifetime 
(e.g. through ip without giving valid_lft or preferred_lft arguments).

Hope that makes it clear.


Cheers,

Steven


On 17.02.2014 14:05, Hannes Frederic Sowa wrote:
> On Mon, Feb 17, 2014 at 07:41:42AM +0100, Steven Barth wrote:
>> Hannes Frederic Sowa wrote:
>>> This could too easily clean up valid on-link information if the address
>>> just happens to be in the same subnet. Would (ifp-flags &
>>> (IFA_F_PERMANENET|IFA_F_TEMPORARY) && !(...)) solve the problem, too?
>> No, that doesn't do the trick unfortunately. Seems that the
>> (non-permanent) address created by "ip" don't have IFA_F_TEMPORARY set.
>> Any other good ideas?
> We are talking about managed temp addresses, no? What ip command do you use?
>
> Bye,
>
>    Hannes
>
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
