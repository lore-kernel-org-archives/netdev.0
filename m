From: Ganesh Venkatesan <ganesh.venkatesan@gmail.com>
Subject: Re: Fw: [Bugme-new] [Bug 4441] New: unregister_netdevice Prompt and system shell lookup when trying to shutdown vlan
Date: Mon, 4 Apr 2005 08:59:02 -0700
Message-ID: <5fc59ff3050404085928b37e57@mail.gmail.com>
References: <20050404041822.2ea0c16a.akpm@osdl.org>
	 <425160D1.6060701@candelatech.com>
Reply-To: Ganesh Venkatesan <ganesh.venkatesan@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Andrew Morton <akpm@osdl.org>, netdev@oss.sgi.com, dcmwai@pl.jaring.my
Return-path: <netdev-bounce@oss.sgi.com>
To: Ben Greear <greearb@candelatech.com>
In-Reply-To: <425160D1.6060701@candelatech.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

I have seen a similar issue without the VLAN module. I was using IPv4.
Happens with 10/100 and 1GbE drivers on Itanium and AMD Opteron
systems. Kernel used was RHEL4 (2.6.9-5.ELsmp).

ganesh.

On Apr 4, 2005 8:44 AM, Ben Greear <greearb@candelatech.com> wrote:
> Andrew Morton wrote:
> >
> > Begin forwarded message:
> >
> > Date: Mon, 4 Apr 2005 04:15:25 -0700
> > From: bugme-daemon@osdl.org
> > To: bugme-new@lists.osdl.org
> > Subject: [Bugme-new] [Bug 4441] New: unregister_netdevice Prompt and system shell lookup when trying to shutdown vlan
> >
> >
> > http://bugme.osdl.org/show_bug.cgi?id=4441
> >
> >            Summary: unregister_netdevice Prompt and system shell lookup when
> >                     trying to shutdown vlan
> >     Kernel Version: 2.6.11-gentoo-r4 i686
> >             Status: NEW
> >           Severity: high
> >              Owner: acme@conectiva.com.br
> >          Submitter: dcmwai@pl.jaring.my
> >
> >
> > Distribution:
> > Gentoo, FC2, FC3
> >
> > Hardware Environment:
> > Pentium 4 3.0E,
> > Intel SE7210TP1-E Server Entry Board
> > 512 MB DDR Ram
> > 2x Intel(r) PRO/1000 Dual Port Adapters
> >
> > Software Environment:
> > Portage 2.0.51.19 (default-linux/x86/2005.0, gcc-3.3.5, glibc-2.3.4.20041102-r1)
> > Fc2 and Fc2 original kernel.
> >
> > Problem Description:
> > When Shutdown a Vlan using this command
> > vconfig rem eth4.1001
> > The interface will be down (using ifconfig)
> > However the following error will be prompt on the screen and the log leaving the
> > shell to be not responding.
> >
> > Even if "ifconfig eth4.1001 down" is run before "vconfig rem" sill the problem
> > will be there.
> > The only way I tested on solve this problem is to shutdown the interface totally.
> > ifconfig eth4 down
> >
> > Then the vlan can be removed correctly.
> >
> > This problem don't happen on the following "special Condition"
> > 1) On another motherboard (Gigabyte GA-81PE1000-G) same NIC on Fc3
> > 1) On eth0
> >
> >
> > Steps to reproduce:
> > 1. get a vlan supported NIC, emerge vconfig
> > 2. ifconfig ethx 0.0.0.0
> > 3. create a vlan using "vconfig add ethx nnnn"
> > 4. ifconfig ethx.nnnn aaa.bbb.ccc.ddd
> > 5. remove the vlan using "vconfig rem ethx.nnnn"
> > 6. Wait for the error like the below.
> > * Motherboard and NIC seem to be a Problem in my case.
> >
> > unregister_netdevice: waiting for ethx.nnnn to become free. Usage count = 6
> 
> In the past, IPv6 has often been the problem here.  Are you using IPv6?
> 
> What is the hardware/driver for eth4?
> 
> Thanks,
> Ben
> 
> >
> > I've also open a bug in Gentoo
> > http://bugs.gentoo.org/show_bug.cgi?id=87495
> >
> > ------- You are receiving this mail because: -------
> > You are on the CC list for the bug, or are watching someone who is.
> >
> 
> --
> Ben Greear <greearb@candelatech.com>
> Candela Technologies Inc  http://www.candelatech.com
> 
>
