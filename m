From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [patch net-next v3 04/17] net: introduce generic switch devices
 support
Date: Thu, 27 Nov 2014 07:35:23 -0500
Message-ID: <54771A8B.2030305@mojatatu.com>
References: <1416911328-10979-1-git-send-email-jiri@resnulli.us> <1416911328-10979-5-git-send-email-jiri@resnulli.us> <5474A567.4040401@mojatatu.com> <20141125164954.GJ1971@nanopsycho.orion> <5474B795.3080204@mojatatu.com> <20141125215402.GA3912@casper.infradead.org> <54754A10.6020601@mojatatu.com> <20141127031315.GD1649@vergenet.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Thomas Graf <tgraf@suug.ch>, Jiri Pirko <jiri@resnulli.us>,
	netdev@vger.kernel.org, davem@davemloft.net, nhorman@tuxdriver.com,
	andy@greyhouse.net, dborkman@redhat.com, ogerlitz@mellanox.com,
	jesse@nicira.com, pshelar@nicira.com, azhou@nicira.com,
	ben@decadent.org.uk, stephen@networkplumber.org,
	jeffrey.t.kirsher@intel.com, vyasevic@redhat.com,
	xiyou.wangcong@gmail.com, john.r.fastabend@intel.com,
	edumazet@google.com, sfeldma@gmail.com, f.fainelli@gmail.com,
	roopa@cumulusnetworks.com, linville@tuxdriver.com,
	jasowang@redhat.com, ebiederm@xmission.com,
	nicolas.dichtel@6wind.com, ryazanov.s.a@gmail.com,
	buytenh@wantstofly.org, aviadr@mellanox.com, nbd@openwrt.org,
	alexei.starovoitov@gmail.com, Neil.Jerram@metaswitch.com,
	ronye@mellanox.com, alexander.h.duyck@redhat.com,
	john.ronciak@intel.com, mleitner@redhat.com, shrijeet@gmail.com,
	gospo@cumulusnetworks.com, bcrl@kvack
To: Simon Horman <simon.horman@netronome.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f173.google.com ([209.85.223.173]:62046 "EHLO
	mail-ie0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754658AbaK0Mf3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Nov 2014 07:35:29 -0500
Received: by mail-ie0-f173.google.com with SMTP id y20so4473990ier.32
        for <netdev@vger.kernel.org>; Thu, 27 Nov 2014 04:35:29 -0800 (PST)
In-Reply-To: <20141127031315.GD1649@vergenet.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/26/14 22:13, Simon Horman wrote:
> On Tue, Nov 25, 2014 at 10:33:36PM -0500, Jamal Hadi Salim wrote:

[..]
> I may be missing the point but I see two problems that are solved by
> the switch abstraction.
>
> - Cases where no ports are configured.
>
>    Perhaps no such use cases exist for the API in question.
>    But it does seem plausible to me that non-physical ports could
>    be added at run-time and that thus a "switch" could initially
>    exist with no configured port. Something like how bridges
>    initially have no ports (IIRC).
>
> - Discovering the association between ports and "switches".
>
> My recollection from the double round table discussion on the last da=
y of
> the D=C3=BCsseldorf sessions was that these were reasons that simply =
accessing
> any port belonging to the "switch" were not entirely satisfactory.
>

So in Du I illustrated in a slide the internals of the Realtek that
Ben had patches on. Ben first exposes the realtek ports and when
you wish you can build a bridge and attach the exposed ports
and then hardware switching functionality is used. What is interesting
about it is infact you didnt need to use the switching on it. You
could attach a filter to any of the exposed ports, then specify an
action to do a redirect to another port for example.
(Scott i know you were not there, but i cant find where those slides
are posted; will send them when i do - or ask Thomas).
This is very easy to map to port/ingress classifier/actions in Linux.
I was hoping i could produce a patch to do this - but waiting on Ben
to complete the reverse engineering.
In any case the realtek is a toy example but there's millions deployed
and producing a patch for tc (if Jiri doesnt beat me to it) is a useful
exercise.
My devices (as would a netronome) would apply the same concept.
Essentially, you take an ingress packet arriving on a port,
you apply a classifier to it, apply actions to i and eventually
ingress it to a port. i.e

Ingress packet-->port->classifier-->...actions..->egress port

I can model the above with tc.

cheers,
jamal
