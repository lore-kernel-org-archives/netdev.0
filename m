From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: 2.6.22-rc4-mm2: Assigning IP address fails
Date: Thu, 7 Jun 2007 15:06:53 -0700
Message-ID: <20070607150653.b83bfc0f.akpm@linux-foundation.org>
References: <20070606220313.8f7c1fab.akpm@linux-foundation.org>
	<20070607214609.GB8204@nineveh.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, linux-net@vger.kernel.org,
	netdev@vger.kernel.org, Herbert Xu <herbert@gondor.apana.org.au>
To: jfannin@gmail.com (Joseph Fannin)
Return-path: <linux-net-owner@vger.kernel.org>
In-Reply-To: <20070607214609.GB8204@nineveh.local>
Sender: linux-net-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 7 Jun 2007 17:46:09 -0400
jfannin@gmail.com (Joseph Fannin) wrote:

> On Wed, Jun 06, 2007 at 10:03:13PM -0700, Andrew Morton wrote:
> >
> > ftp://ftp.kernel.org/pub/linux/kernel/people/akpm/patches/2.6/2.6.22-rc4/2.6.22-rc4-mm2/
> 
>     I'm not able to bring an ethernet interface down and back up again
> with this if avahi-autoipd is installed on my Ubuntu boxes.  I've seen
> it on three different computers with different NIC hardware.
> 
>     I've worked out an easy way to reproduce it without
> avahi-autoipd.  Starting with eth0 up (address assigned by DHCP):
> 
>   # ifdown eth0
>   < dhclient makes the normal noise about releasing the address >
>   # ip addr add 169.254.255.67/16 brd 169.254.255.255 label eth0:avahi scope link dev eth0
>   # ip addr del 169.154.255.67/16 brd 169.254.255.255 label eth0:avahi scope link dev eth0
>   # ifup eth0
>   SIOCSIFADDR: No buffer space available    < -- first sign of trouble HERE
>   < dhclient copyright boilerplate >
>   Listening on LPF/eth0/<MAC addr>
>   Sending on   LPF/eth0/<MAC addr>
>   Sending on   Socket/fallback
>   DHCPDISCOVER on eth0 to 255.255.255.255 port 67 interval 5
>   DHCPOFFER from < DHCP server >
>   DHCPREQUEST on eth0 to 255.255.255.255 port 67
>   DHCPACK from  < DHCP server >
>   SIOCSIFADDR: No buffer space available
>   SIOCSIFNETMASK: Cannot assign requested address
>   SIOCSIFBRDADDR: Cannot assign requested address
>   SIOCADDRTL No such process
>   bound to < IP address > -- renewal in XXXX seconds
>   #
> 
>     At this point, the interface is up, but has no address assigned.
> Manually assigning one with ifconfig fails:
> 
>   # ifconfig eth0 netmask 255.255.255.0 172.16.0.1
>   SIOCSIFNETMASK: Cannot assign requested address
>   SIOCSIFADDR: No buffer space available
>   #
> 
> ... and a reboot is the only way I've been able to get the interface
> to work again.
> 
>     The last kernels I tried were 2.6.22-rc3 and *I think*
> 2.6.22-rc1-mm1, neither of which had this problem.  I will test
> 2.6.22-rc4 and 2.6.22-rc3-mm1 later, but I'm out of time today.
> 
>     I've attached my .config .

Yep, thanks - Miles has reported the same thing.
