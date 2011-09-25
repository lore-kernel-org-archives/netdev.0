From: Marc Haber <mh+netdev@zugschlus.de>
Subject: Re: [PATCH 1/2] bridge: leave carrier on for empty bridge
Date: Sun, 25 Sep 2011 11:05:19 +0200
Message-ID: <20110925090519.GD32712@torres.zugschlus.de>
References: <20110902172220.830228928@vyatta.com>
 <20110902172247.396753508@vyatta.com>
 <4E614CF7.7030700@gmail.com>
 <20110902151100.327af0bf@nehalam.ftrdhcpuser.net>
 <4E6272BC.4020707@gmail.com>
 <20110903211438.2a43d2f2@nehalam.ftrdhcpuser.net>
 <4E632A2E.5040805@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from torres.zugschlus.de ([85.214.131.164]:33785 "EHLO
	torres.zugschlus.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751583Ab1IYJFU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 25 Sep 2011 05:05:20 -0400
Received: from mh by torres.zugschlus.de with local (Exim 4.72)
	(envelope-from <mh+netdev@zugschlus.de>)
	id 1R7keF-0000CW-DL
	for netdev@vger.kernel.org; Sun, 25 Sep 2011 11:05:19 +0200
Content-Disposition: inline
In-Reply-To: <4E632A2E.5040805@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Sep 04, 2011 at 09:35:10AM +0200, Nicolas de Peslo=C3=BCan wrot=
e:
> - for those using bridge without any port, manually setting the IP
> will assert carrier on. (By the way, why don't they use a dummy
> device instead?)

Because there is no documentation or recommendation how to use things.
Being a networking guy, I have always treated a bridge as kind of a
switch, where it is natural to say "vlan 120, ip address a.b.c.d". I
just did the same with br0 on all my virtualization hosts, which used
to work until just recently.

Additionally, most distributions' init mechanisms are not very good in
handling dependencies between network interfaces, so writing stuff
like "configure br0, configure dummy0, add dummy0 to br0, wait for
things to settle, start daemons, start VMs" requires tweaking.

Is it recommended to actually have radvd and/or dhcpd listen on the
dummy interface wich is member of a bridge instead of the bridge itself=
?

> - for those using bridge with ports:
> -- Using any kind of autoconfig will work as expected. Carrier will
> only be asserted at the time first port get carrier.

This only holds when the host with the bridge is the network client,
and only if rdnssd is not used. If the host with the bridge is
supposed to run radvd and/or dhcpd, it is desired to have those
services running before the first port gets attached to the bridge
(which may be hours after the system boot in the desktop
virtualization case).

> -- Using static IP confifiguration, carrier will possibly be
> erroneously reported as on during the small time gap between IP
> address configuration and first port is added to the bridge. This
> time gap may be removed by simply configuring the IP after the first
> port is added. This is probably already true for most distribs. And
> anyway, this time gap is probably not a problem.

You're assuming that the first port gets added immediately after the
port was created. This is not the case, Virtualbox only creates the
vboxnet interface that gets added to the bridge when the VM is
started, which may be a manual operation done by the user at the time
she actually needs the VM.

> -- Carrier will also be erroneously reported as on after removing
> the last port, if the bridge still has an IP.

=46or my use cases, this is the desired behavior.

>  (But we can arrange for this not to happen).

Please not.

> And in order to ensure user really understand why carrier is on of
> off, we can simply issue an INFO message for the non-natural case
> (bridge_has_no_port & bridga_has_at_least_one_ip).

I fail to understand why this is the non-natural case.

Greetings
Marc

--=20
-----------------------------------------------------------------------=
------
Marc Haber         | "I don't trust Computers. They | Mailadresse im He=
ader
Mannheim, Germany  |  lose things."    Winona Ryder | Fon: *49 621 7273=
9834
Nordisch by Nature |  How to make an American Quilt | Fax: *49 3221 232=
3190
