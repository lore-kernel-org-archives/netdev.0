From: Jon Stanley <jstanley@rmrf.net>
Subject: regression between v3.0 and v3.3 in bringing up IPoIB devices in a
 bond at boot
Date: Tue, 16 Oct 2012 21:16:25 -0400
Message-ID: <CAJtaB1vQymkE7ebTj6QRJ-+mfirpTjh=j6vxTdXQFqwtKrKQVg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
To: netdev@vger.kernel.org, Jiri Pirko <jiri@resnulli.us>,
	Andy Gospodarek <andy@greyhouse.net>, davem@davemloft.net,
	fubar@us.ibm.com, kaber@trash.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qa0-f53.google.com ([209.85.216.53]:58281 "EHLO
	mail-qa0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755824Ab2JQBQZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Oct 2012 21:16:25 -0400
Received: by mail-qa0-f53.google.com with SMTP id s11so49610qaa.19
        for <netdev@vger.kernel.org>; Tue, 16 Oct 2012 18:16:25 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Firstly, I apologize that this report isn't as well-formed as it
should be (i.e. I can't point to a specific commit that broke it), but
I'll do my best failing that. The reason I can't be as specific as I'd
like is that starting at 3.1-rc1, I'd run into the original VLAN
problem that I was having, and the patchset required to fix it (the
patch just submitted, efc73f4b, and 9b361c1) won't apply cleanly to
older kernels and I'm not sure it's worth the (seemingly massive)
effort required to backport them to something I don't plan to use :)

First, let me explain the configuration a little:

bond0 -> eth0, eth1.100
bond1 -> ib0, ib1

The first problem, which is now resolved, was that ib0 and ib1
wouldn't enslave at all because of the presence of VLAN0. I can now
get them to enslave manually (echo +ib0 > /sys/.../slaves) *if* the
bond is down. If the bond is up, I still get the "refused to change
device type", which is fairly expected (I think, but that could be the
problem here).

However, if I leave the distro (stock RHEL except the kernel) to it's
own devices to bring it up at boot, I get the same symptoms as though
the master (bond1 in this case) isn't down ("refused to change device
type"). If  I go back to v3.0, everything works fine. I've also
verified that it doesn't work on current mainline, and that it works
fine without any VLAN devices configured on bond0.

Like I said, the only reason that I haven't already bisected this is
that I know that intermediate points are broken in a possibly
unrelated, but fatal, way. I'm more than willing to try things out to
figure this one out, it's got me stumped!

Thanks!
-Jon
