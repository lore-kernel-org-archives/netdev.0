From: Marc Haber <mh+netdev@zugschlus.de>
Subject: After a while of system running no incoming UDP any more?
Date: Mon, 24 Jul 2017 14:09:01 +0200
Message-ID: <20170724120901.6bpcieyvn5nccm2l@torres.zugschlus.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from torres.zugschlus.de ([85.214.131.164]:34402 "EHLO
        torres.zugschlus.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753162AbdGXMqJ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 24 Jul 2017 08:46:09 -0400
Received: from mh by torres.zugschlus.de with local (Exim 4.89)
        (envelope-from <mh+netdev@zugschlus.de>)
        id 1dZcAX-0005ct-BH
        for netdev@vger.kernel.org; Mon, 24 Jul 2017 14:09:01 +0200
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

I am running ~ 50 servers, most of them as KVM guests, some of them as
Xen guests, and even less of them on hardware, and have recently updated
to Debian stretch. I usually use kernels locally built from the latest
vanille stable release.

Roughly since the upgrade to Debian stretch and kernel 4.12, some of my
systems have begun to not forward UDP packets (such as incoming DNS
replies) to the user space. When this happens, I see the packet coming
in on tcpdump -p, but the application never sees it and eventuelly times
out. An strace on the process sees the process waiting on the select()
syscall and nothing happens when the system receives the UDP packet. I
do also see the same phenomenon with ntp. A reboot always fixes the
issue. 

Runnign wireshark on a pcap file obtained on an affected systems does
show all checksums to be in order. Both IPv4 and IPv6 are affected, and
in the DNS case, switching dig/drill or even the system resolver to TCP
also fixes the issue.

This happens only after the system has been running for a few days, and
I have seen this happen on both KVM and Xen guests, but not (yet) on
real hardware. In my zoo of servers, this happens - over the entire
sample - about twice a week, often enough to be annoying and seldomly
enough to make debugging really difficult since you'll never know in
advance which system will have the issue for the next time.

I have therefore been reluctant to downgrade kernel or system since that
would mean days of work. Bisecting is probably out of the question since
you'll never know when "git bisect good" is a sufficiently safe
assumption.

Before I begin running older kernels on productive systems, I would like
to ask wether there have been recent changes in the 4.11 => 4.12
development cycle that might cause an issue like that.

Since I have never seen the issue on stretch systems when they were
still running 4.11.8 (the latest 4.11 kernel that I had deployed before
switching over to 4.12), I do really suspect the kernel, and I do also
suspect that network interface offloading is probably not the culprit.

On the KVM guests, I use virtio-net, and I had that one high on my list
until one of the two Xen guests that doesn't show any network modules
loaded has been showing the phenomenon as well.

That Xen guest outputs the following to lshw -C network:

that doesn't show any network modules loaded has been showing the
phenomenon as well.

That Xen guest outputs the following to lshw -C network:

  *-network
       description: Ethernet interface
       physical id: 1
       logical name: eth0
       serial: 0e:06:5f:74:48:97
       capabilities: ethernet physical
       configuration: broadcast=yes driver=vif ip=<redacted> link=yes multicast=yes

So I assume that this one is not using virtio-net, so virtio-net seems
safe as well.

Any idea what might be happening here and what else I could try?

Greetings
Marc

-- 
-----------------------------------------------------------------------------
Marc Haber         | "I don't trust Computers. They | Mailadresse im Header
Leimen, Germany    |  lose things."    Winona Ryder | Fon: *49 6224 1600402
Nordisch by Nature |  How to make an American Quilt | Fax: *49 6224 1600421
