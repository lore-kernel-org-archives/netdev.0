From: Kamala R <kamala@aristanetworks.com>
Subject: Re: IPv6: Blackhole route support partial ?
Date: Fri, 15 Nov 2013 15:06:28 +0530
Message-ID: <CAP8BHkF_axGOChL=GigyKxWY1XYr_tQhWFF21ZxpVX9YpRpQSQ@mail.gmail.com>
References: <CAP8BHkGZ5EFxW4BNervKrOiEaQTNdSh9s2YOrFoexzQCOR=AqQ@mail.gmail.com>
	<20131111203954.GB3043@order.stressinduktion.org>
	<CAP8BHkG6=KuU9K7=sGsZftMDe58eTYByRu2DZ+j+KNqcfsOfAA@mail.gmail.com>
	<20131112135412.GF14929@order.stressinduktion.org>
	<CAP8BHkEyASA52Q4Zg4w5OqR7Hv7Y_it8SnG_tMPViza_T9TV+Q@mail.gmail.com>
	<20131114141149.GC26901@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
To: Kamala R <kamala@aristanetworks.com>, davem@davemloft.net,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qa0-f46.google.com ([209.85.216.46]:42593 "EHLO
	mail-qa0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753874Ab3KOJg3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 Nov 2013 04:36:29 -0500
Received: by mail-qa0-f46.google.com with SMTP id j7so401413qaq.19
        for <netdev@vger.kernel.org>; Fri, 15 Nov 2013 01:36:29 -0800 (PST)
In-Reply-To: <20131114141149.GC26901@order.stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

That's right. We don't show the error for IPv4 routes as it follows a
different path in kernel while dumping the information as compared
with IPv6. Therefore, "ip route show" does not show an error while "ip
-6 route show" does.  So it looks to me that this a kernel problem
which needs to be fixed for consistent behavior. The simplest way to
fix this seems to be to set the error to zero while dumping the
information in the v6 path. I have tested this solution and found that
it works fine. Do you think this is the way to go ?

Regards,
Kamala

On Thu, Nov 14, 2013 at 7:41 PM, Hannes Frederic Sowa
<hannes@stressinduktion.org> wrote:
> Hi!
>
> On Thu, Nov 14, 2013 at 01:50:20PM +0530, Kamala R wrote:
>> I have one quick question before I send the patch across. I noticed
>> that "ip -6 route show" shows an error -22 in the output which
>> signifies -EINVAL associated with blackhole routes. This behaviour is
>> not consistent with that of "ip route show" that shows no such error
>> for a blackhole route. Does this qualify a bug that needs fixing ?
>
> You mean that we don't show the error for IPv4 routes? Is this a kernel or
> iproute problem?
>
> Greetings,
>
>   Hannes
>
