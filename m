From: "Benjamin Thery" <ben.thery@gmail.com>
Subject: Re: [RESEND][PATCH 00/11] sysfs tagged directories
Date: Wed, 7 May 2008 15:47:48 +0200
Message-ID: <939d53060805070647h10965232j7e2792708d34ae8@mail.gmail.com>
References: <20080506173030.653828076@theryb.frec.bull.fr>
	 <20080506175331.GA1815@suse.de> <4821AC4A.1010905@fr.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "Greg KH" <gregkh@suse.de>,
	"Benjamin Thery" <benjamin.thery@bull.net>,
	linux-kernel@vger.kernel.org,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	"Tejun Heo" <htejun@gmail.com>, "Al Viro" <viro@ftp.linux.org.uk>,
	"Serge E. Hallyn" <serue@us.ibm.com>,
	"Pavel Emelyanov" <xemul@openvz.org>, netdev@vger.kernel.org
To: "Daniel Lezcano" <dlezcano@fr.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from py-out-1112.google.com ([64.233.166.181]:24703 "EHLO
	py-out-1112.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752786AbYEGNrv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 May 2008 09:47:51 -0400
Received: by py-out-1112.google.com with SMTP id u52so408636pyb.10
        for <netdev@vger.kernel.org>; Wed, 07 May 2008 06:47:49 -0700 (PDT)
In-Reply-To: <4821AC4A.1010905@fr.ibm.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, May 7, 2008 at 3:19 PM, Daniel Lezcano <dlezcano@fr.ibm.com> wrote:
> Greg KH wrote:
>
> > On Tue, May 06, 2008 at 07:30:30PM +0200, Benjamin Thery wrote:
> >
> > > This is still the same port of Eric Biederman's patchset to implement
> > > tagged directories in sysfs that was discussed a few days ago.
> > >
> > > This time it applies on top of 2.6.26-rc1, which includes a fix from
> Daniel Lezcano to fix net device renaming
> > > for sysfs (and of course all the network namespaces stuff that was
> committed in net-2.6.26).
> > >
> > > This patchset still contains the patch from Serge Hallyn that implements
> > > tagging for user namespaces.
> > >
> > > It also contains a patch from Daniel Lezcano which allows to have net
> devices with the same name in two different network namespaces.
> > >
> >
> > Does this all work properly with both CONFIG_SYSFS_DEPRECATED enabled
> > and disabled?
> >
> > Can you show some outputs of 'tree' in both cases on the /sys/class/net/
> > directory?
> >
> > thanks,
> >
> > greg k-h
> >
>
>  Here is the output from an ls -l of /sys/class/net. I tryed with different
> configurations and checked the renamed network devices are propagated to the
> sysfs.

Thanks Daniel.
You covered more cases than I was planning to send :)

Benjamin

>
>  1) CONFIG_SYSFS_DEPRECATED && CONFIG_SYS && CONFIG_NET_NS
>  =========================================================
>
>  Outside a namespace:
>  --------------------
>
>  qemu:~> ip l
>  1: lo: <LOOPBACK,UP,10000> mtu 16436 qdisc noqueue
>     link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
>  2: eth0: <BROADCAST,MULTICAST,UP,10000> mtu 1500 qdisc pfifo_fast qlen 1000
>     link/ether 52:54:00:12:34:56 brd ff:ff:ff:ff:ff:ff
>  3: dummy0: <BROADCAST,NOARP> mtu 1500 qdisc noop
>     link/ether 1e:43:9e:1f:1f:55 brd ff:ff:ff:ff:ff:ff
>  4: br0: <BROADCAST,MULTICAST,UP,10000> mtu 1500 qdisc noqueue
>     link/ether 52:54:00:12:34:56 brd ff:ff:ff:ff:ff:ff
>  16: veth1: <BROADCAST,MULTICAST,PROMISC> mtu 1500 qdisc pfifo_fast qlen
> 1000
>     link/ether 8e:94:e6:72:63:cf brd ff:ff:ff:ff:ff:ff
>
>  qemu:~/lxc> ll /sys/class/net/
>  total 0
>  drwxr-xr-x 5 root root 0 2008-05-07 15:24 br0
>  drwxr-xr-x 3 root root 0 2008-05-07 13:16 dummy0
>  drwxr-xr-x 4 root root 0 2008-05-07 15:24 eth0
>  drwxr-xr-x 3 root root 0 2008-05-07 13:16 lo
>  drwxr-xr-x 4 root root 0 2008-05-07 15:26 veth1
>
>
>  Inside the namespace:
>  ----------------------
>
>  qemu:~> ip l
>  14: lo: <LOOPBACK,UP,10000> mtu 16436 qdisc noqueue
>     link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
>  15: veth2: <BROADCAST,MULTICAST,UP,10000> mtu 1500 qdisc pfifo_fast qlen
> 1000
>     link/ether 46:85:e5:76:90:05 brd ff:ff:ff:ff:ff:ff
>
>  virtnode:~lxc # ll /sys/class/net/
>  total 0
>  drwxr-xr-x 3 root root 0 May  7 15:28 lo
>  drwxr-xr-x 3 root root 0 May  7 15:26 veth2
>
>  2) CONFIG_SYSFS && CONFIG_NET_NS
>  ================================
>
>
>  Outside the namespace:
>  ----------------------
>
>  qemu:~> ip l
>  1: lo: <LOOPBACK,UP,10000> mtu 16436 qdisc noqueue
>     link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
>  2: eth0: <BROADCAST,MULTICAST,UP,10000> mtu 1500 qdisc pfifo_fast qlen 1000
>     link/ether 52:54:00:12:34:56 brd ff:ff:ff:ff:ff:ff
>  3: dummy0: <BROADCAST,NOARP> mtu 1500 qdisc noop
>     link/ether 72:16:3d:88:11:70 brd ff:ff:ff:ff:ff:ff
>  4: br0: <BROADCAST,MULTICAST,UP,10000> mtu 1500 qdisc noqueue
>     link/ether 52:54:00:12:34:56 brd ff:ff:ff:ff:ff:ff
>  13: veth1: <BROADCAST,MULTICAST,PROMISC> mtu 1500 qdisc pfifo_fast qlen
> 1000
>     link/ether aa:6f:e8:dd:b8:ba brd ff:ff:ff:ff:ff:ff
>
>   * Content of /sys/class/net:
>
>  qemu:~/lxc> ll /sys/class/net/
>  total 0
>  lrwxrwxrwx 1 root root 0 2008-05-07 14:31 br0 ->
> ../../devices/virtual/net/br0
>  lrwxrwxrwx 1 root root 0 2008-05-07 14:28 dummy0 ->
> ../../devices/virtual/net/dummy0
>  lrwxrwxrwx 1 root root 0 2008-05-07 14:28 eth0 ->
> ../../devices/pci0000:00/0000:00:03.0/net/eth0
>  lrwxrwxrwx 1 root root 0 2008-05-07 14:28 lo ->
> ../../devices/virtual/net/lo
>  lrwxrwxrwx 1 root root 0 2008-05-07 14:35 veth1 ->
> ../../devices/virtual/net/veth1
>
>  Inside the namespace:
>  ----------------------
>
>  qemu:~> ip l
>  11: lo: <LOOPBACK,UP,10000> mtu 16436 qdisc noqueue
>     link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
>  12: veth2: <BROADCAST,MULTICAST,UP,10000> mtu 1500 qdisc pfifo_fast qlen
> 1000
>     link/ether ee:c5:a3:7c:58:bd brd ff:ff:ff:ff:ff:ff
>
>  virtnode:~/lxc # ll /sys/class/net/
>  total 0
>  lrwxrwxrwx 1 root root 0 May  7 14:40 lo -> ../../devices/virtual/net/lo
>  lrwxrwxrwx 1 root root 0 May  7 14:40 veth2 ->
> ../../devices/virtual/net/veth2
>
>
>  3) CONFIG_SYSFS
>  ===============
>
>  qemu:~> ip l
>  1: lo: <LOOPBACK,UP,10000> mtu 16436 qdisc noqueue
>     link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
>  2: eth0: <BROADCAST,MULTICAST,UP,10000> mtu 1500 qdisc pfifo_fast qlen 1000
>     link/ether 52:54:00:12:34:56 brd ff:ff:ff:ff:ff:ff
>  3: dummy0: <BROADCAST,NOARP> mtu 1500 qdisc noop
>     link/ether 6e:3a:5f:2f:fa:cb brd ff:ff:ff:ff:ff:ff
>  4: br0: <BROADCAST,MULTICAST,UP,10000> mtu 1500 qdisc noqueue
>     link/ether 52:54:00:12:34:56 brd ff:ff:ff:ff:ff:ff
>
>  qemu:~/lxc> ll /sys/class/net/
>  total 0
>  lrwxrwxrwx 1 root root 0 2008-05-07 15:01 br0 ->
> ../../devices/virtual/net/br0
>  lrwxrwxrwx 1 root root 0 2008-05-07 14:59 dummy0 ->
> ../../devices/virtual/net/dummy0
>  lrwxrwxrwx 1 root root 0 2008-05-07 14:59 eth0 ->
> ../../devices/pci0000:00/0000:00:03.0/net/eth0
>  lrwxrwxrwx 1 root root 0 2008-05-07 14:59 lo ->
> ../../devices/virtual/net/lo
>
>  4) CONFIG_SYSFS_DEPRECATED && CONFIG_SYSFS
>  ==========================================
>
>  qemu:~> ip l
>  1: lo: <LOOPBACK,UP,10000> mtu 16436 qdisc noqueue
>     link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
>  2: eth0: <BROADCAST,MULTICAST,UP,10000> mtu 1500 qdisc pfifo_fast qlen 1000
>     link/ether 52:54:00:12:34:56 brd ff:ff:ff:ff:ff:ff
>  3: dummy0: <BROADCAST,NOARP> mtu 1500 qdisc noop
>     link/ether 16:85:f0:a8:34:44 brd ff:ff:ff:ff:ff:ff
>  4: br0: <BROADCAST,MULTICAST,UP,10000> mtu 1500 qdisc noqueue
>     link/ether 52:54:00:12:34:56 brd ff:ff:ff:ff:ff:ff
>
>  qemu:~> ll /sys/class/net/
>  total 0
>  drwxr-xr-x 5 root root 0 2008-05-07 15:07 br0
>  drwxr-xr-x 3 root root 0 2008-05-07 15:06 dummy0
>  drwxr-xr-x 4 root root 0 2008-05-07 15:07 eth0
>  drwxr-xr-x 3 root root 0 2008-05-07 15:06 lo
>
>
>  --
>  To unsubscribe from this list: send the line "unsubscribe netdev" in
>  the body of a message to majordomo@vger.kernel.org
>  More majordomo info at  http://vger.kernel.org/majordomo-info.html
>
