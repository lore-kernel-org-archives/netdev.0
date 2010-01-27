From: Jesse Brandeburg <jesse.brandeburg@gmail.com>
Subject: Re: [Bugme-new] [Bug 14748] New: e1000e NIC not working after reboot
Date: Tue, 26 Jan 2010 16:40:59 -0800
Message-ID: <4807377b1001261640w624491b2s86242fac068641d3@mail.gmail.com>
References: <bug-14748-10286@http.bugzilla.kernel.org/>
	 <20091207135028.0c33a4f4.akpm@linux-foundation.org>
	 <alpine.WNT.2.00.0912071354481.2420@jbrandeb-mobl2.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: "Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"Allan, Bruce W" <bruce.w.allan@intel.com>,
	"Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>,
	"Ronciak, John" <john.ronciak@intel.com>,
	"bugzilla-daemon@bugzilla.kernel.org"
	<bugzilla-daemon@bugzilla.kernel.org>,
	"bugme-daemon@bugzilla.kernel.org" <bugme-daemon@bugzilla.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"e1000-devel@lists.sourceforge.net"
	<e1000-devel@lists.sourceforge.net>,
	Andrew Morton <akpm@linux-foundation.org>
To: "Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	"macieks@freesco.pl" <macieks@freesco.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f176.google.com ([209.85.211.176]:44467 "EHLO
	mail-yw0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754115Ab0A0AlA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Jan 2010 19:41:00 -0500
Received: by ywh6 with SMTP id 6so4591457ywh.4
        for <netdev@vger.kernel.org>; Tue, 26 Jan 2010 16:41:00 -0800 (PST)
In-Reply-To: <alpine.WNT.2.00.0912071354481.2420@jbrandeb-mobl2.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Dec 7, 2009 at 2:01 PM, Brandeburg, Jesse
<jesse.brandeburg@intel.com> wrote:
> On Mon, 7 Dec 2009, Andrew Morton wrote:
>> > When I power up my system the NIC is working properly.
>> > After every reboot the NIC is not working. I mean the eth0 is created, but
>> > neither dhcpcd gets IP nor static setup helps
>
> We have a userspace tool called ethregs downloadable from
> http://downloads.sourceforge.net/project/e1000/Register%20Dump%20Tool/1.7.2/ethregs-1.7.2.tar.gz?use_mirror=iweb
>
> if it is not too much trouble can you build this tool and run it before
> (when the port is working) and after (when the link didn't come up)
>
> you can attach them to the bug, and reply to this thread would be best.

I've looked at the ethregs dumps, the good news is it looks like the
hardware succeeds to self-init, but on the ethregs-fails.txt did you
load the driver?  it appears you did not, or at least didn't do
# ip link set eth0 up
# ethregs > regs.txt

also looked at the lspci -vvv information and in both cases MSI was
enabled, but in the fails case the value in the data field for the MSI
vector is different, which seems a a little strange but I'm not sure
if it is responsible for failure

if the driver was loaded, and failed dhcp, what happens when you run
ethtool -t eth0 offline?

when the driver is loaded, and the dhcp fails, can you assign an
address manually (and bring the interface up) and have it work?

one more thing to note please, can you send cat /proc/interrupts from
10 seconds apart when the driver is loaded and the port is UP, but not
working.  dhcpcd or dhclient both have a tendency to put the port DOWN
after they fail to get address, so thats why you may need to do # ip
link command above before gathering /proc/interrupts.

is your bios up to date?

Thanks, sorry for the delay, lets see if we can figure out what is up.

Jesse
