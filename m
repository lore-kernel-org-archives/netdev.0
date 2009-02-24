From: =?UTF-8?Q?Kolbj=C3=B8rn_Barmen?= <linux@kolla.no>
Subject: PROBLEM: IPv6 autoconf/accept_ra default values
Date: Tue, 24 Feb 2009 10:50:26 +0100 (CET)
Message-ID: <alpine.LNX.2.00.0902241031470.28298@halbrend.uninett.no>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ufisa.uninett.no ([158.38.152.126]:56298 "EHLO ufisa.uninett.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753263AbZBXKGc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 24 Feb 2009 05:06:32 -0500
Received: from uninett.no (halbrend.uninett.no [158.38.62.143])
	by ufisa.uninett.no (Postfix) with ESMTP id 6D68433714
	for <netdev@vger.kernel.org>; Tue, 24 Feb 2009 10:47:22 +0100 (CET)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello

I was tipped by someone at linux-kernel@vger.kernel.org to post this to 
netdev@vger.kernel.org instead, so here goes...

1. Summary of problem

autoconfig and accept_ra is by default on (by the way of forwarning) -
this is very problematic in many ways.

2. Full description of the problem/report:

* if you want staticly only configured addresses/gateway (which is
  something you just might want for server machines for example) you need
  to change the sysctl parameters before the interface is brought up. 
  (yes, I want staticly, and only staticly configured addresses, dont get
  me started on why - keywords: source address, dns, ssl, access control)

* to change the default values, ipv6 module needs to be loaded, in many
  distros this leads to race conditions, especially in these "autodetect
  hardware and bring up everything magically" days :)

* if you netboot with ipv6 enabled kernel, interface will pick up ipv6
  autoconf no matter, so you need to remove addresses and routes manually
  after boot. As far as I know there is now kernel parameters to tell
  kernel to not autoconf ipv6. I admit I have not tested out whether it's
  possible to use ipv6-addresses as kernel parameters at all.

* ipv6 kernel module has no load paramters as far as I can tell?

* changing net.ipv6.conf.all.* and net.ipv6.conf.default.* dont work as
  intended? I'm really not sure how this is meant to work, but intuitively
  I would think that "...all.*" would affect all interfaces present, and
  "...*.default.*" would set the default values for "future" interfaces.
  Maybe I'm wrong? Look further down...

3. Keywords
   ipv6, forwarding, autoconf, accept_ra

4. Kernel version (from /proc/version):
   This goes accross all 2.6 kernels as far as I can tell, no matter what
   distro.

5. Output of Oops.. message
   No oops so far :)

6. A small shell script or example program which triggers the problem 
   
   root:~# sysctl net.ipv6.conf.all.accept_ra
   net.ipv6.conf.all.accept_ra = 1
   root:~# sysctl -w net.ipv6.conf.all.accept_ra=0
   net.ipv6.conf.all.accept_ra = 0
   root:~# sysctl net.ipv6.conf.eth0.accept_ra
   net.ipv6.conf.all.accept_ra = 1
   
I suppose the above is fals behaviour? I'm really not sure, but if this is
not a bug, then I fail to see the purpose of the "...all.*" and
"...default.*" sysctl parameters. From the documentation
(networking/ip-sysctl.txt) I get the impression that the above behaviour
is wrong:

--- 
conf/default/*:
        Change the interface-specific default settings.

conf/all/*:
        Change all the interface-specific settings.

        [XXX:  Other special features than forwarding?]
---

Looks like this is unclear for more than just me :)


My personal oppinion is that anything ipv6 autoconfig/accept_ra should be
default _off_, since this simplifies all the above mentioned issues, and
it is incredibly easy to turn on again with systcl if people want it.
It is much easier to enable ipv6 automagic than to disable it.
At least there should be kernel/module parameter to set default behaviour.

Part of the problem with deploying IPv6 is due to "magic" like this, all
the autoconfig/router announcement magic looks very well on paper and in
theory, but out in the field it quickly leads to loads of totally
unnecessary extra work, work that could easily be avoided if default
behaviour was to have it off. It should be in the interest of IPv6
advocates to support a "soft" transition from IPv4-only to dual-stack,
fencing off unwanted "magic" only adds to the frustration for those who
actually try to deploy it.

What do you think?

If there already is a simple stright forward solution, then I apologize
for this rant - please enlighten me :)

-- kolla
