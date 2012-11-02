From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: switching network namespace midway
Date: Fri, 02 Nov 2012 13:45:53 -0700
Message-ID: <87y5ijd98e.fsf@xmission.com>
References: <CAFaHj6FjDULMCdta3bhVu2mtJeR9TuJVMmbC0H6jjkfb6A5t-Q@mail.gmail.com>
	<878vavshhp.fsf@xmission.com> <20121024212116.GG15034@kvack.org>
	<CAFaHj6Ey4vzXskvsKB_dG4fKGsn4X5oCF3N0YpGskiSaXrGSOw@mail.gmail.com>
	<20121025155927.GI15034@kvack.org> <87a9var0ih.fsf@xmission.com>
	<20121102022542.GD18091@kvack.org> <87k3u4il2l.fsf@xmission.com>
	<20121102140353.GE18091@kvack.org>
Mime-Version: 1.0
Content-Type: text/plain
Cc: rsa <ravi.mlists@gmail.com>, netdev@vger.kernel.org
To: Benjamin LaHaise <bcrl@kvack.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out01.mta.xmission.com ([166.70.13.231]:55383 "EHLO
	out01.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751742Ab2KBUqA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 2 Nov 2012 16:46:00 -0400
In-Reply-To: <20121102140353.GE18091@kvack.org> (Benjamin LaHaise's message of
	"Fri, 2 Nov 2012 10:03:53 -0400")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Benjamin LaHaise <bcrl@kvack.org> writes:

> On Thu, Nov 01, 2012 at 11:18:58PM -0700, Eric W. Biederman wrote:
>> You need a per network namespace exit function to delete the tunnel when
>> the xmit direction goes away.  Otherwise we have a very nasty race if
>> the original network namespace exits.
>
> That already exists as ipgre_exit_net().  Since the ip_tunnel structure 
> remains hashed in the network namespace that creation occurred in, this 
> case should be covered.

*blink*  I had looked for that, but I definitely missed that one.

The consequence of the design where we can run ioctls on network devices
we can't even see but whose ipaddrs are in our network namespace is
interesting.  Correct but interesting.

>> NETNS_LOCAL may make sense on the reference device that is used to
>> support ioctls for creating devices.
>
> *nod*  That makes sense.

After a second look.  fb_tunnel_dev is very special in the code so
allowing fb_tunnel_dev to change network namespace is almost certain
to create problems, so it should get a NETNS_LOCAL.

>> ipgre_open ?  It looks like it needs to be handled.  Probably that
>> ip_route_output_gre needs to be moved.
>
> Good catch.  Will respin with that changed.

I'm not seeing anything else but I will look again after you respin.

>> ipv6?
>
> That's next on the list.  There are also issues with ipip, ipmr and 
> ipvti, as well as their ipv6 versions.

I don't see sense in ip multicast routing tunnels (ipmr) changing
network namespaces as they are essentially aliases for other network
devices, and aren't really proper tunnels.

Eric
