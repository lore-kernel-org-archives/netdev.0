From: Michael Tokarev <mjt@tls.msk.ru>
Subject: bridging a wifi interface into kvm guest possible?
Date: Sun, 12 Oct 2008 16:45:54 +0400
Message-ID: <48F1F182.7020308@msgid.tls.msk.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org, kvm@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from hobbit.corpit.ru ([81.13.33.150]:23832 "EHLO hobbit.corpit.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752183AbYJLMpz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 12 Oct 2008 08:45:55 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

[cross-posted to netdev and kvm lists]
[..which failed due to wrong (old) kvm address.
  Please excuse me for the repost]

Hello!

I'm trying to set up a [virtual/guest] network of hosts to
form something like a DMZ and a gateway, but in virtual
"hardware" instead of real hardware.  One of the things
I tried is to run the gateway/router machine inside a
guest system too, not only all the dmz hosts (there are
some obscure historical reasons for that, don't ask ;).

Real hardware has 2 ethernet interfaces - external and
internal LAN.  In order for the gateway to run as a
guest, one has to "move" external interface into guest.

Since kvm does not [fully] support PCI device "moving"
(what's the right word for this?) from host to guest
(which is the simplest solution possible), I were
thinking about something different: bridging.  Since
bridge is already used to connect gateway host to the
LAN, why not use it for external<=>gateway link too?
The difference is that there will be no IP address on
the host on that "external" bridge, i.e. the host will
not participate in the IP traffic transmission, only
ethernet.

So far so good, and that setup worked on a test environment,
worked flawlessly (well.. almost -- for some reason, under
some circumstances, linux starts broadcasting certain
packets over all bridges it has.. but that's different
issue/topic).  Worked up until I tried it on production,
which is different from the test setup by the fact that
for external interface, we have an old 11Mbps wifi card,
instead of a real ethernet NIC.

And I learned the hard way that bridging does not really
work with wifi cards (it works with some, and even that
requires.. some tweaking and additional software).

I tried to set up the mac address on the guest-gateway
to be the same as the one on wifi, but that obviously
didn't help.

After browsing kernel options (unrelated to this issue),
I noticed a device called "macvlan".  So I wonder if that
can be used in my case, -- just to "move" a wifi interface
to a guest system.

I found very little documentation about macvlan.  The
patchset that introduced it back in 2007 says that macvlan
puts the underlying device into promisc mode (which is where
a wifi driver has problems).

Or maybe there's another solution to this my problem (not
counting getting additional hardware for the wifi link,
which obviously will work; or replacing the wifi card
with something more advanced).

Thank you!

/mjt
