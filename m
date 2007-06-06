From: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
Subject: Re: [RFC RTNETLINK 00/09]: Netlink link creation API
Date: Wed, 6 Jun 2007 23:14:09 +0400
Message-ID: <20070606191409.GA2495@ms2.inr.ac.ru>
References: <20070605141250.15650.47178.sendpatchset@localhost.localdomain> <m1tztlvrsp.fsf@ebiederm.dsl.xmission.com> <46669FA0.3030405@trash.net> <m1d509umtp.fsf@ebiederm.dsl.xmission.com> <4666D426.2070606@trash.net> <20070606155634.GA15067@ms2.inr.ac.ru> <4666E1B2.1070109@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "Eric W. Biederman" <ebiederm@xmission.com>,
	netdev@vger.kernel.org, socketcan@hartkopp.net, hadi@cyberus.ca,
	xemul@sw.ru, tgraf@suug.ch
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from minus.inr.ac.ru ([194.67.69.97]:40203 "HELO ms2.inr.ac.ru"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with SMTP
	id S935494AbXFFTUu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 6 Jun 2007 15:20:50 -0400
Content-Disposition: inline
In-Reply-To: <4666E1B2.1070109@trash.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello!

> Good point, I didn't think of that. Is there a version of this patch
> that already uses different namespaces so I can look at it?

Pavel does not like the idea. It looks "not exactly pretty", like you said. :-)

The alternative is to create pair in main namespace and then move
one end to another namespace renaming it and changing index.
Why I do not like it? Because this makes RTM_NEWLINK just useless step,
all its work is undone and real work is remade when the device moves,
with all the unrettiness moved to another place.

>From another hand, some move operation is required in any case.
Right now in openvz the problem is solved in tricky, but quite
inerseting way: all the devices in main namespace are assigned
with odd index, child devices get odd index. So that, when a device
moves from main namespace to child, openvz does not need to change
ifindex, conflict is impossible. Well, it is working approach.
But it is not pretty either.


> Are network namespace completely seperated or is there some hierarchy
> with all lower namespaces visible above or something like that?

Right now they are completely separate.

It is possible to make child devices visible in parent namespace
like it is done for process pids: i.e. there is an abstract identity
which is seen under different names and indices in different namespaces.
Sounds cool, but this add a lot of complexity, which has no meaning
outside of context of device creation, I do not think it is worth to do.




> The identity of the main device has no meaning within a different
> namespace, but are there other reasons for hiding it?

Perhaps, security. It is not a good idea to leak information
about parent namespace to child namespace.

Also, people will want to see emulated ethernet inside namespace
looking exactly like ethernet. No freaking additional attributes.

Alexey
