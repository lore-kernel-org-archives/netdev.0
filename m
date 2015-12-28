From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: 4.4-rc7 failure report
Date: Mon, 28 Dec 2015 23:20:04 +0100
Message-ID: <5681B594.70304@iogearbox.net>
References: <5681AF69.4040204@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	David Miller <davem@redhat.com>,
	netdev <netdev@vger.kernel.org>
To: Doug Ledford <dledford@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:39915 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752566AbbL1WUN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 28 Dec 2015 17:20:13 -0500
In-Reply-To: <5681AF69.4040204@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/28/2015 10:53 PM, Doug Ledford wrote:
> The 4.4-rc7 kernel is failing for me.  In my case, all of my vlan
> interfaces are failing to obtain a dhcp address using dhclient.  I've
> tried a hand built 4.4-rc7, and the Fedora rawhide 4.4-rc7 kernel, both
> failed.  I've tried NetworkManager and the old SysV network service,
> both fail.  I tried a working dhclient from rhel7 on the Fedora rawhide
> install and it failed too.  Running tcpdump on the interface shows the
> dhcp request going out, and a dhcp response coming back in.  Running
> strace on dhclient shows that it writes the dhcp request, but it never
> recvs a dhcp response.  If I manually bring the interface up with a
> static IP address then I'm able to run typical IP traffic across the
> link (aka, ping).  It would seem that when dhclient registers a packet
> filter on the socket, that filter is preventing it from ever getting the
> dhcp response.  The same dhclient works on any non-vlan interfaces in
> the system, so the filter must work for non-vlan interfaces.  Aside from
> the fact that the interface is a vlan, we also use a priority egress map
> on the interface, and we use PFC flow control.  Let me know if you need
> anymore to debug the issue, or email me off list and I can get you
> logins to my reproducer machines.

When you say 4.4-rc7 kernel is failing for you, what latest kernel version
was working, where the socket filter was properly receiving the response on
your vlan iface? Are you reasonably sure that the skb is dropped at the BPF
filter attached to the dhcp's packet socket? Can you dump the BPF code of
the filter? Are there any vlan offloading settings the filter is not taking
into account (in the sense of classic BPF extensions, tcpdump/libpcap finally
managed to cope with this)?
