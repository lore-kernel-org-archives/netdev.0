From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [Bugme-new] [Bug 8042] New: Cisco VPN Client cannot connect
 using TCP with Intel 82573L NIC
Date: Mon, 19 Feb 2007 22:27:38 -0800
Message-ID: <20070219222738.b9df3608.akpm@linux-foundation.org>
References: <200702192355.l1JNtJrA017088@fire-2.osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "bugme-daemon@kernel-bugs.osdl.org"
	<bugme-daemon@bugzilla.kernel.org>, johnf@dsl.ca
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.24]:51116 "EHLO smtp.osdl.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932840AbXBTG1s (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 20 Feb 2007 01:27:48 -0500
In-Reply-To: <200702192355.l1JNtJrA017088@fire-2.osdl.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 19 Feb 2007 15:55:19 -0800 bugme-daemon@bugzilla.kernel.org wrote:

> http://bugzilla.kernel.org/show_bug.cgi?id=8042
> 
>            Summary: Cisco VPN Client cannot connect using TCP with Intel
>                     82573L NIC
>     Kernel Version: 2.6.18.6
>             Status: NEW
>           Severity: normal
>              Owner: shemminger@osdl.org
>          Submitter: johnf@dsl.ca
> 
> 
> Most recent kernel where this bug did *NOT* occur: -
> Distribution: Ubuntu, Debian
> Hardware Environment: Lenovo Thinkpad T60p
> Software Environment: -
> Problem Description:
> 
> I have an issue with the cisco vpn client
> (vpnclient-linux-x86_64-4.8.00.0490-k9.tar.gz) that appears to be related to
> packet fragmentation and the e1000 driver (hardware is 82573L, I don't believe
> that this issue affects earlier chips).
> 
> When I try to connect to a VPN using Cisco's TCP tunneling feature I experience
> an issue where I am unable to connect to the vpn concentrator.
> 
> If I recompile the e1000 module, setting the option:
> 
> CONFIG_E1000_DISABLE_PACKET_SPLIT=y
> 
> then I am able to connect without issue.
> 
> I have experience this problem with the following kernels:
> 
> ubuntu edgy 2.6.16-11-generic
> debian sid  2.6.18-4-686 (Based on 2.6.18.6 w/hand picked later patches)
> kernel.org  2.6.18.6
> 
> There was a perhaps related bug resolved for udp recently, see this changelog entry:
> 
> http://www.kernel.org/git/?p=linux/kernel/git/torvalds/linux-2.6.git;a=commit;h=753eab76a3337863a0d86ce045fa4eb6c3cbeef9
> 
> You can also see some discussion surrounding the issue (I had initially believe
> it related to another issue with the 82573L), starting from this comment:
> 
> http://bugzilla.kernel.org/show_bug.cgi?id=6929#c9
> 
> Please let me know if there is anything else I can do to better explain the problem.
> 
> Steps to reproduce:
> 
> It's not possible to reproduce this issue without:
> 
>  - A 82573L chip based network card
>  - A Cisco VPN Concentrator you can access using TCP tunneling
>  - The cisco vpn client ()
> 
> I have all of these, and would be more than pleased to reproduce the problem,
> provide packet captures, etc... If you want to reproduce the problem yourself,
> and have the above equipment, try to open a TCP encapsulated connection to the
> VPN Concentrator, you should not be able to unless you have compiled e1000 with
>  CONFIG_E1000_DISABLE_PACKET_SPLIT=y.
> 
> ------- You are receiving this mail because: -------
> You are on the CC list for the bug, or are watching someone who is.
