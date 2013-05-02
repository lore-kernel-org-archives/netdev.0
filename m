From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: [GIT] Networking
Date: Thu, 2 May 2013 11:52:15 -0700
Message-ID: <CA+55aFy04mY5g-Aics9dcGpv6zgn2bu4iQ-_ifE5hun_t4E54Q@mail.gmail.com>
References: <20130501.164755.1859264969403837546.davem@davemloft.net>
	<CA+55aFzsvyQLLKbuETBqfhpgkSaXH9cvT0O-cQ-mTTXXxcMqwg@mail.gmail.com>
	<1367512467.4000.7.camel@dcbw.foobar.com>
	<1367519066.7757.19.camel@dcbw.foobar.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
	hayeswang <hayeswang@realtek.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Network Development <netdev@vger.kernel.org>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
To: Dan Williams <dcbw@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ve0-f182.google.com ([209.85.128.182]:35171 "EHLO
	mail-ve0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1761716Ab3EBSwQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 May 2013 14:52:16 -0400
In-Reply-To: <1367519066.7757.19.camel@dcbw.foobar.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, May 2, 2013 at 11:24 AM, Dan Williams <dcbw@redhat.com> wrote:
>
> One more question Linus; what version of NetworkManager,

    NetworkManager-0.9.8.1-1.git20130327.fc18.x86_64

> and can you
> grab some syslog 'daemon' facility logs grepped for "
> NetworkManger" | "eth0"?

Here's the NetworkManager part of /var/log/messages from a bad boot:

  NetworkManager[540]: <info> WEXT support is enabled
  NetworkManager[540]: <info> VPN: loaded org.freedesktop.NetworkManager.openvpn
  NetworkManager[540]: <info> VPN: loaded org.freedesktop.NetworkManager.vpnc
  NetworkManager[540]: <info> VPN: loaded
org.freedesktop.NetworkManager.openconnect
  NetworkManager[540]: <info> VPN: loaded org.freedesktop.NetworkManager.pptp
  NetworkManager[540]:    ifcfg-rh: Acquired D-Bus service com.redhat.ifcfgrh1
  NetworkManager[540]: <info> Loaded plugin ifcfg-rh: (c) 2007 - 2010
Red Hat, Inc.  To report bugs please use the NetworkManager mailing
list.
  NetworkManager[540]: <info> Loaded plugin keyfile: (c) 2007 - 2010
Red Hat, Inc.  To report bugs please use the NetworkManager mailing
list.
  NetworkManager[540]:    ifcfg-rh: parsing
/etc/sysconfig/network-scripts/ifcfg-lo ...
  NetworkManager[540]:    ifcfg-rh: parsing
/etc/sysconfig/network-scripts/ifcfg-eth0 ...
  NetworkManager[540]:    ifcfg-rh:     read connection 'System eth0'
  NetworkManager[540]: <info> monitoring kernel firmware directory
'/lib/firmware'.
  NetworkManager[540]: <info> WiFi enabled by radio killswitch;
enabled by state file
  NetworkManager[540]: <info> WWAN enabled by radio killswitch;
enabled by state file
  NetworkManager[540]: <info> WiMAX enabled by radio killswitch;
enabled by state file
  NetworkManager[540]: <info> Networking is enabled by state file
  NetworkManager[540]: <warn> failed to allocate link cache: (-10)
Operation not supported
  NetworkManager[540]: <info> (eth0): carrier is OFF
  NetworkManager[540]: <info> (eth0): new Ethernet device (driver:
'r8169' ifindex: 2)
  NetworkManager[540]: <info> (eth0): exported as
/org/freedesktop/NetworkManager/Devices/0
  NetworkManager[540]: <info> (eth0): device state change: unmanaged
-> unavailable (reason 'managed') [10 20 2]
  NetworkManager[540]: <info> (eth0): bringing up device.
  NetworkManager[540]: <info> (eth0): preparing device.
  NetworkManager[540]: <info> (eth0): deactivating device (reason 'managed') [2]
  NetworkManager[540]: <warn> /sys/devices/virtual/net/lo: couldn't
determine device driver; ignoring...
  NetworkManager[540]: <warn> /sys/devices/virtual/net/lo: couldn't
determine device driver; ignoring...
  NetworkManager[540]: <info> (eth0): carrier now ON (device state 20)

and that's all it says. hHere's a good boot:

  NetworkManager[547]: <info> NetworkManager (version
0.9.8.1-1.git20130327.fc18) is starting...
  NetworkManager[547]: <info> Read config file
/etc/NetworkManager/NetworkManager.conf
  NetworkManager[547]: <info> WEXT support is enabled
  NetworkManager[547]: <info> VPN: loaded org.freedesktop.NetworkManager.openvpn
  NetworkManager[547]: <info> VPN: loaded org.freedesktop.NetworkManager.vpnc
  NetworkManager[547]: <info> VPN: loaded
org.freedesktop.NetworkManager.openconnect
  NetworkManager[547]: <info> VPN: loaded org.freedesktop.NetworkManager.pptp
  NetworkManager[547]:    ifcfg-rh: Acquired D-Bus service com.redhat.ifcfgrh1
  NetworkManager[547]: <info> Loaded plugin ifcfg-rh: (c) 2007 - 2010
Red Hat, Inc.  To report bugs please use the NetworkManager mailing
list.
  NetworkManager[547]: <info> Loaded plugin keyfile: (c) 2007 - 2010
Red Hat, Inc.  To report bugs please use the NetworkManager mailing
list.
  NetworkManager[547]:    ifcfg-rh: parsing
/etc/sysconfig/network-scripts/ifcfg-lo ...
  NetworkManager[547]:    ifcfg-rh: parsing
/etc/sysconfig/network-scripts/ifcfg-eth0 ...
  NetworkManager[547]:    ifcfg-rh:     read connection 'System eth0'
  NetworkManager[547]: <info> monitoring kernel firmware directory
'/lib/firmware'.
  NetworkManager[547]: <info> WiFi enabled by radio killswitch;
enabled by state file
  NetworkManager[547]: <info> WWAN enabled by radio killswitch;
enabled by state file
  NetworkManager[547]: <info> WiMAX enabled by radio killswitch;
enabled by state file
  NetworkManager[547]: <info> Networking is enabled by state file
  NetworkManager[547]: <warn> failed to allocate link cache: (-10)
Operation not supported
  NetworkManager[547]: <info> (eth0): carrier is OFF
  NetworkManager[547]: <info> (eth0): new Ethernet device (driver:
'r8169' ifindex: 2)
  NetworkManager[547]: <info> (eth0): exported as
/org/freedesktop/NetworkManager/Devices/0
  NetworkManager[547]: <info> (eth0): device state change: unmanaged
-> unavailable (reason 'managed') [10 20 2]
  NetworkManager[547]: <info> (eth0): bringing up device.
  NetworkManager[547]: <info> (eth0): preparing device.
  NetworkManager[547]: <info> (eth0): deactivating device (reason 'managed') [2]
  NetworkManager[547]: <warn> /sys/devices/virtual/net/lo: couldn't
determine device driver; ignoring...
  NetworkManager[547]: <warn> /sys/devices/virtual/net/lo: couldn't
determine device driver; ignoring...
  NetworkManager[547]: <info> (eth0): carrier now ON (device state 20)
  NetworkManager[547]: <info> (eth0): device state change: unavailable
-> disconnected (reason 'carrier-changed') [20 30 40]
  NetworkManager[547]: <info> Auto-activating connection 'System eth0'.
  NetworkManager[547]: <info> Activation (eth0) starting connection
'System eth0'
  NetworkManager[547]: <info> (eth0): device state change:
disconnected -> prepare (reason 'none') [30 40 0]
  NetworkManager[547]: <info> Activation (eth0) Stage 1 of 5 (Device
Prepare) scheduled...
  NetworkManager[547]: <info> Activation (eth0) Stage 1 of 5 (Device
Prepare) started...
  NetworkManager[547]: <info> Activation (eth0) Stage 2 of 5 (Device
Configure) scheduled...
  NetworkManager[547]: <info> Activation (eth0) Stage 1 of 5 (Device
Prepare) complete.
  NetworkManager[547]: <info> Activation (eth0) Stage 2 of 5 (Device
Configure) starting...
  NetworkManager[547]: <info> (eth0): device state change: prepare ->
config (reason 'none') [40 50 0]
  NetworkManager[547]: <info> Activation (eth0) Stage 2 of 5 (Device
Configure) successful.
  NetworkManager[547]: <info> Activation (eth0) Stage 3 of 5 (IP
Configure Start) scheduled.
  NetworkManager[547]: <info> Activation (eth0) Stage 2 of 5 (Device
Configure) complete.
  NetworkManager[547]: <info> Activation (eth0) Stage 3 of 5 (IP
Configure Start) started...
  NetworkManager[547]: <info> (eth0): device state change: config ->
ip-config (reason 'none') [50 70 0]
  NetworkManager[547]: <info> Activation (eth0) Beginning DHCPv4
transaction (timeout in 45 seconds)
  NetworkManager[547]: <info> dhclient started with pid 910
  NetworkManager[547]: <info> Activation (eth0) Stage 3 of 5 (IP
Configure Start) complete.
  NetworkManager[547]: <info> (eth0): DHCPv4 state changed nbi -> preinit
  NetworkManager[547]: <info> (eth0): DHCPv4 state changed preinit -> reboot
  NetworkManager[547]: <info>   address 192.168.0.52
  NetworkManager[547]: <info>   prefix 24 (255.255.255.0)
  NetworkManager[547]: <info>   gateway 192.168.0.1
  NetworkManager[547]: <info>   nameserver '192.168.0.1'
  NetworkManager[547]: <info> Activation (eth0) Stage 5 of 5 (IPv4
Configure Commit) scheduled...
  NetworkManager[547]: <info> Activation (eth0) Stage 5 of 5 (IPv4
Commit) started...
  NetworkManager[547]: <info> (eth0): device state change: ip-config
-> secondaries (reason 'none') [70 90 0]
  NetworkManager[547]: <info> Activation (eth0) Stage 5 of 5 (IPv4
Commit) complete.
  NetworkManager[547]: <info> (eth0): device state change: secondaries
-> activated (reason 'none') [90 100 0]
  NetworkManager[547]: <info> Policy set 'System eth0' (eth0) as
default for IPv4 routing and DNS.
  NetworkManager[547]: <info> Activation (eth0) successful, device activated.

so apparently NM does see carrier even in the bad state, and it is
just the NM-applet that then says "cable disconnected". Who knows what
goes through NM-applets tiny little mind? Not me.

Anyway, they seem to be identical (apart from the pid change, of
course) up until the good case says

  NetworkManager[540]: <info> (eth0): device state change: unavailable
-> disconnected (reason 'carrier-changed') [20 30 40]

and with a bad kernel, that just never happens. Don't ask me why.  In
both cases, the preceding kernel messages were

  r8169 0000:01:00.0 eth0: link up
  IPv6: ADDRCONF(NETDEV_CHANGE): eth0: link becomes ready

but for some reason in the bad case NM just doesn't react past the
"carrier now ON" part.

                    Linus
