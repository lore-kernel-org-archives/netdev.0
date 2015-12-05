From: Alexander Duyck <alexander.duyck@gmail.com>
Subject: Re: [PATCH v1 1/6] net: Generalize udp based tunnel offload
Date: Sat, 5 Dec 2015 00:24:55 -0800
Message-ID: <CAKgT0Uc1bJRrzpLUdr3vOFkYZbcqP=J8wgOz1feF+u04aNBg1g@mail.gmail.com>
References: <CAKgT0UepW=VehhXncrAM=tvqrVDD_KOdVJBpwEU+hYTAdMz_dg@mail.gmail.com>
	<CALx6S36Y4fP9a6U40My+kuhik5THPOjHNYfRrVe8Szte03K7Ew@mail.gmail.com>
	<566279E5.9070500@gmail.com>
	<20151205.014909.1572453190886968569.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Tom Herbert <tom@herbertland.com>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	John Linville <linville@tuxdriver.com>,
	Jesse Gross <jesse@kernel.org>,
	Anjali Singhai Jain <anjali.singhai@intel.com>,
	Netdev <netdev@vger.kernel.org>,
	Kiran Patil <kiran.patil@intel.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f176.google.com ([209.85.213.176]:37439 "EHLO
	mail-ig0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752892AbbLEIY4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 5 Dec 2015 03:24:56 -0500
Received: by igcto18 with SMTP id to18so51725042igc.0
        for <netdev@vger.kernel.org>; Sat, 05 Dec 2015 00:24:56 -0800 (PST)
In-Reply-To: <20151205.014909.1572453190886968569.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Dec 4, 2015 at 10:49 PM, David Miller <davem@davemloft.net> wrote:
> From: Alexander Duyck <alexander.duyck@gmail.com>
> Date: Fri, 4 Dec 2015 21:45:09 -0800
>
>> Not having this feature has to in some way impact sales.
>
> I'm glad money trumps clean design and performance these days.
>
> Would they ship a literal turd until some customer asked for
> something better?  You have to be kidding me.

You think they wouldn't?  It all comes down to the bottom line.

Also, do you really think not having support for CHECKSUM_COMPLETE
makes the part a complete turd?  That hasn't stopped anyone from
buying many of the NICs out there that are using the port based
approach for VXLAN up to now.  Really what we are arguing about here
is a "nice to have feature" not something that will make or break a
sale for most people.  It was implemented just well enough to be able
to show gains on marketing data but there are enough corner cases
where the feature won't do much of anything since there is always some
upper limit on the number of ports supported.

> If it's true, then what a sad world we live in.

That is the nature of business.  If there is isn't any significant
impact on the bottom line most companies won't be pushed to take
action.

> And part of this is bogus, the circuit is already there and
> implemented already.  The missing part is putting the value computed
> by that circuit into the receive descriptor.

Yes, but that part doesn't complete the whole piece.  As I stated in
my other email it is still a bit of effort to complete something like
this.

> And furthermore, nobody is going to drop to BSD or DPDK for VXLAN
> tunnels just because I push back hard on this facility.

I agree, that was a bit of hyperbole on my part.  Still, hard blocking
this isn't necessarily going to push the vendors to change their ways.
It just ends up punishing the customers who already own the devices.
You may think the port based approach for the UDP tunnel offloads is a
"literal turd" but the fact is no amount of software changes is going
to do anything to fundamentally change how the hardware was designed,
and like I said there is likely more of that to come.

Keep in mind I don't represent one of the hardware vendors here
anymore.  I am approaching this from the customer point of view.  I
would like to have the performance I can get out of the parts I have.
In the future Mirantis may not buy nor recommend the devices, but I
have an OpenStack environment filled with NICs from various vendors
that support this UDP port number based offload.  I have to come up
with a means of polishing these "turds" in such a way that we can get
the maximum benefit out of them.  The question I would have is if you
see a constructive way of me doing this and working it out through the
kernel network stack, or do I need to suggest a bypass solution such
as ovs-dpdk and just give up on the hope of using kernel networking
with these parts?

- Alex
