From: "Hugo Santos" <hugosantos@gmail.com>
Subject: Re: /proc/sys/net/ipv[46]/conf/ issue unsolved
Date: Tue, 13 Feb 2007 20:18:23 +0000
Message-ID: <9c46321e0702131218u62288405n23a6e96dc0f4c48c@mail.gmail.com>
References: <200702131529.04708.hasso@estpak.ee>
	 <20070213185820.GB25362@hmsreliant.homelinux.net>
	 <9c46321e0702131124q33b4e263ybc38555cf1544769@mail.gmail.com>
	 <20070213194538.GF25362@hmsreliant.homelinux.net>
	 <9c46321e0702131149j4b9b642cvfe397d5bd2a30038@mail.gmail.com>
	 <20070213201006.GG25362@hmsreliant.homelinux.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "Hasso Tepper" <hasso@estpak.ee>, netdev@vger.kernel.org
To: "Neil Horman" <nhorman@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.174]:34818 "EHLO
	ug-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750948AbXBMUSa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Feb 2007 15:18:30 -0500
Received: by ug-out-1314.google.com with SMTP id 44so341624uga
        for <netdev@vger.kernel.org>; Tue, 13 Feb 2007 12:18:24 -0800 (PST)
In-Reply-To: <20070213201006.GG25362@hmsreliant.homelinux.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 2/13/07, Neil Horman <nhorman@tuxdriver.com> wrote:
> 1) Kernel network driver X detects that it has hardware to drive, and
> consequently calls register_netdev.  This creates the network interface and
> registers all the appropriate proc and sysfs files, which are now accessible in
> user space.

The problem is that in the IPv6 case, the sysfs files are _not_
registered in this step but only after the interface is set up (in
fact after the first proper address is added to the interface, which
generally would be the link local address).

> As has been seen, one place to fix this is by adding logic to the ifup scripts
> for the appropriate protocol to issue sysctl -w commands to set configs prior to
> issuing the ifconfig up or ip link up commands.

  Due to the previous point, this wouldn't work. I believe the proper
solution is to init the ipv6 dev on interface creation (and thus
trigger the adding of the sysfs files) and not when the first address
is added to the interface.

  There might be issues with this solution (known internal races,
module unloading issues, etc), that's why i asked previously if there
were any known ones.

  Hugo
