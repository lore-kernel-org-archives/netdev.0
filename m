From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: 4.4-rc7 failure report
Date: Tue, 29 Dec 2015 20:16:12 -0800
Message-ID: <20151230041611.GA9209@ast-mbp.thefacebook.com>
References: <5681AF69.4040204@redhat.com>
 <5681B594.70304@iogearbox.net>
 <5681E154.7040101@redhat.com>
 <20151230034300.GA8670@ast-mbp.thefacebook.com>
 <5683531F.9000704@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Daniel Borkmann <daniel@iogearbox.net>,
	David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>
To: Doug Ledford <dledford@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f52.google.com ([209.85.220.52]:34447 "EHLO
	mail-pa0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753247AbbL3EQP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Dec 2015 23:16:15 -0500
Received: by mail-pa0-f52.google.com with SMTP id uo6so111075221pac.1
        for <netdev@vger.kernel.org>; Tue, 29 Dec 2015 20:16:15 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <5683531F.9000704@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Dec 29, 2015 at 10:44:31PM -0500, Doug Ledford wrote:
> On 12/29/2015 10:43 PM, Alexei Starovoitov wrote:
> > On Mon, Dec 28, 2015 at 08:26:44PM -0500, Doug Ledford wrote:
> >> On 12/28/2015 05:20 PM, Daniel Borkmann wrote:
> >>> On 12/28/2015 10:53 PM, Doug Ledford wrote:
> >>>> The 4.4-rc7 kernel is failing for me.  In my case, all of my vlan
> >>>> interfaces are failing to obtain a dhcp address using dhclient.  I've
> >>>> tried a hand built 4.4-rc7, and the Fedora rawhide 4.4-rc7 kernel, both
> >>>> failed.  I've tried NetworkManager and the old SysV network service,
> >>>> both fail.  I tried a working dhclient from rhel7 on the Fedora rawhide
> >>>> install and it failed too.  Running tcpdump on the interface shows the
> >>>> dhcp request going out, and a dhcp response coming back in.  Running
> >>>> strace on dhclient shows that it writes the dhcp request, but it never
> >>>> recvs a dhcp response.  If I manually bring the interface up with a
> >>>> static IP address then I'm able to run typical IP traffic across the
> >>>> link (aka, ping).  It would seem that when dhclient registers a packet
> >>>> filter on the socket, that filter is preventing it from ever getting the
> >>>> dhcp response.  The same dhclient works on any non-vlan interfaces in
> >>>> the system, so the filter must work for non-vlan interfaces.  Aside from
> >>>> the fact that the interface is a vlan, we also use a priority egress map
> >>>> on the interface, and we use PFC flow control.  Let me know if you need
> >>>> anymore to debug the issue, or email me off list and I can get you
> >>>> logins to my reproducer machines.
> >>>
> >>> When you say 4.4-rc7 kernel is failing for you, what latest kernel version
> >>> was working, where the socket filter was properly receiving the response on
> >>> your vlan iface?
> >>
> >> v4.3 final works.  I haven't bisected where in the 4.4 series it quits
> >> working.  I can do that tomorrow.
> > 
> > I've tried to reproduce, but cannot seem to make dnsmasq work properly
> > over vlan, so bisect would be great.
> > 
> 
> Yeah, I've been working on it.  Issues with available machines that
> reproduce combined with what hardware they have and whether or not that
> hardware works at various steps in the bisection :-/

I've looked through all bpf related commits between v4.3..HEAD and don't see
anything suspicious. Could it be that your setup exploited a bug that was fixed by 
28f9ee22bcdd ("vlan: Do not put vlan headers back on bridge and macvlan ports")

Could you also provide more details on vlan+dhcp setup to help narrow it
down if bisect is taking too long.
