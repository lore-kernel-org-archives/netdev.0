From: Anand Kumria <wildfire@progsoc.uts.edu.au>
Subject: link-local address via ifconfig
Date: Sat, 3 Jun 2006 12:57:43 +1000
Message-ID: <20060603025743.GL549@progsoc.uts.edu.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-owner@vger.kernel.org>
Received: from incubus.progsoc.uts.edu.au ([138.25.6.7]:8922 "EHLO
	incubus.progsoc.uts.edu.au") by vger.kernel.org with ESMTP
	id S1751104AbWFCC5l (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 2 Jun 2006 22:57:41 -0400
Received: from wildfire by incubus.progsoc.uts.edu.au with local (Exim 4.50)
	id 1FmMKd-0008JO-IK
	for netdev@vger.kernel.org; Sat, 03 Jun 2006 12:57:43 +1000
To: netdev@vger.kernel.org
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

There are plenty of people who still use ifconfig to list the addresses
assigned to their network interfaces (I know, ifconfig is broken) and
who then parse the output.

However the kernel puts link-local scoped address first if the address
list of an interface, so an interface like:

eve:[~]% ip addr show wlan0
3: wlan0: <BROADCAST,MULTICAST,UP> mtu 1500 qdisc pfifo_fast qlen 1000
    link/ether 00:12:f0:03:d9:e7 brd ff:ff:ff:ff:ff:ff
    inet 169.254.182.108/16 brd 169.254.255.255 scope link wlan0
    inet 192.168.2.2/24 brd 192.168.2.255 scope global wlan0
    inet6 fe80::212:f0ff:fe03:d9e7/64 scope link
       valid_lft forever preferred_lft forever

appears as:
eve:[~]% ifconfig wlan0
wlan0     Link encap:Ethernet  HWaddr 00:12:F0:03:D9:E7
          inet addr:169.254.182.108  Bcast:169.254.255.255 Mask:255.255.0.0
          inet6 addr: fe80::212:f0ff:fe03:d9e7/64 Scope:Link
          UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
	  [... elided ...]

Is there any reason to put the link-local address first in the list?

I've had a number of bugreports (or outright panic attacks) where the 
problem turned out to be that ifconfig was reporting the link-local 
address first, rather than the global/site one.

Thanks,
Anand

-- 
 `When any government, or any church for that matter, undertakes to say to
  its subjects, "This you may not read, this you must not see, this you are
  forbidden to know," the end result is tyranny and oppression no matter how
  holy the motives' -- Robert A Heinlein, "If this goes on --"
