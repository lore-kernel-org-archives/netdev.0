From: Andrew Morton <akpm@osdl.org>
Subject: Re: [Bugme-new] [Bug 7137] New: modprobe eth modules random loading
 order
Date: Sat, 9 Sep 2006 22:26:37 -0700
Message-ID: <20060909222637.a87d7b43.akpm@osdl.org>
References: <200609100437.k8A4b7n6032559@fire-2.osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, c.gm@usa.net, stable@kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:47527 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S932308AbWIJF1N (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 10 Sep 2006 01:27:13 -0400
To: "bugme-daemon@kernel-bugs.osdl.org"
	<bugme-daemon@bugzilla.kernel.org>
In-Reply-To: <200609100437.k8A4b7n6032559@fire-2.osdl.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, 9 Sep 2006 21:37:07 -0700
bugme-daemon@bugzilla.kernel.org wrote:

> http://bugzilla.kernel.org/show_bug.cgi?id=7137
> 
>            Summary: modprobe eth modules random loading order
>     Kernel Version: 2.6.17.x
>             Status: NEW
>           Severity: high
>              Owner: acme@conectiva.com.br
>          Submitter: c.gm@usa.net
> 
> 
> Most recent kernel where this bug did not occur:2.6.17.13
> Distribution: Crux
> 
> Hardware Environment: All our P4 and PIII Servers
> 
> Software Environment: Not software dependable
> Problem Description:
> When upgrade to 2.6.17.11 then our servers with multiple NIC's changed the 
> order it was loaded.
> We use modules for NIC's in kernel config.
> modprobe.conf are set up as this example.
> 
> alias eth0 e100
> alias eth1 8139too
> 
> Efter upgrade to 2.6.17.11 the NIC which is first loaded is 8139too (Realtek) 
> which then get eth0 
> and second is the e100 (INTEL) eth1
> 
> Kernel 2.6.17.8 and erlier was loaded in the order of modprobe.conf settings.
> 
> After upgrade to 2.6.17.13 then the load order of eth modules have change 
> again, and still dont folow the modprobe.conf setting.
> 
> Efter upgrade to 2.6.17.13 the NIC which now is loaded  first is the e100 eth0
> (INTEL) and second is 8139too (Realtek) eht1
> 
> I have the same problem with 3com and realtek or 3com and Intel NIC's
> it change the load order and don't folow the modprobe.conf settings.
> 
> Steps to reproduce:
> Use to different NIC's and use 2.6.17.8 and config the driver as module in 
> kernel config. use modprobe.conf and config as I have describe.
> Change then to 2.6.7.11.
> 
> And then use 2.6.7.13 and see how the the NIC driver are loaded.
> 
> It seams to work ok with 3com and tulip based (D-LINK 4-port NIC_s) in the same 
> machine. In this case the NIC is loaded in the same order for all kernel 
> versions.
> 
> - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
> I asume, when using modules for NIC's drives should be loaded as ethX using the 
> setting in modprobe.conf.
> 
> It is really important the eth0 is loaded as it is configured in modprobe.conf 
> and not as the kernel find it in slot ID order.
> 
> This strange behavior cause a lot of reconfiguring then we use very complex 
> IPTEBLES rules. Iptable syntax for in/out NIC "-o -i" whill then not be correct.
> 
> And because:
> Using two different NIC one 1 Gbs and 100 Mbs. The 1 Gbs NIC should then be 
> assined the eth0 which is used for primary heavy load and the 100 Mbs is used 
> for maintenance.
> 
> ------- You are receiving this mail because: -------
> You are on the CC list for the bug, or are watching someone who is.

argh.  Can annyone think what might have caused this?
