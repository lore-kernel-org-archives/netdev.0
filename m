From: David Hill <hilld@binarystorm.net>
Subject: Re: [Bugme-new] [Bug 13553] New: When NETCONSOLE is enabled inkernel,
 computer crashes after 120seconds (approx)
Date: Thu, 16 Jul 2009 01:42:27 -0400
Message-ID: <0164924B246D494C87B1674186574373@delorimier>
References: <bug-13553-10286@http.bugzilla.kernel.org/>
 <20090623140743.2b38ff6c.akpm@linux-foundation.org>
 <20090624010501.GB27384@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; format=flowed; charset=iso-8859-1; reply-type=original
Content-Transfer-Encoding: 7BIT
Cc: netdev@vger.kernel.org, bugzilla-daemon@bugzilla.kernel.org,
	bugme-daemon@bugzilla.kernel.org
To: Neil Horman <nhorman@tuxdriver.com>,
	Andrew Morton <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relais.videotron.ca ([24.201.245.36]:23127 "EHLO
	relais.videotron.ca" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757487AbZGPFmU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Jul 2009 01:42:20 -0400
Received: from wolfe ([66.131.88.45]) by VL-MH-MR002.ip.videotron.ca
 (Sun Java(tm) System Messaging Server 6.3-4.01 (built Aug  3 2007; 32bit))
 with ESMTP id <0KMV00I4B16JXC40@VL-MH-MR002.ip.videotron.ca> for
 netdev@vger.kernel.org; Thu, 16 Jul 2009 01:42:20 -0400 (EDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Will try that in the next few days... sorry for the delay.  I was on 
vacation for the last 2 weeks and thus, out of town :D



----- Original Message ----- 
From: "Neil Horman" <nhorman@tuxdriver.com>
To: "Andrew Morton" <akpm@linux-foundation.org>
Cc: <netdev@vger.kernel.org>; <bugzilla-daemon@bugzilla.kernel.org>; 
<bugme-daemon@bugzilla.kernel.org>; <hilld@binarystorm.net>
Sent: Tuesday, June 23, 2009 9:05 PM
Subject: Re: [Bugme-new] [Bug 13553] New: When NETCONSOLE is enabled 
inkernel, computer crashes after 120seconds (approx)


> On Tue, Jun 23, 2009 at 02:07:43PM -0700, Andrew Morton wrote:
>>
>> (switched to email.  Please respond via emailed reply-to-all, not via the
>> bugzilla web interface).
>>
>> On Wed, 17 Jun 2009 01:55:54 GMT
>> bugzilla-daemon@bugzilla.kernel.org wrote:
>>
>> > http://bugzilla.kernel.org/show_bug.cgi?id=13553
>> >
>> >            Summary: When NETCONSOLE is enabled in kernel, computer 
>> > crashes
>> >                     after 120seconds (approx)
>> >            Product: Networking
>> >            Version: 2.5
>> >     Kernel Version: 2.6.29.4, 2.6.30
>> >           Platform: All
>> >         OS/Version: Linux
>> >               Tree: Mainline
>> >             Status: NEW
>> >           Severity: high
>> >           Priority: P1
>> >          Component: Other
>> >         AssignedTo: acme@ghostprotocols.net
>> >         ReportedBy: hilld@binarystorm.net
>> >         Regression: No
>> >
>> >
>>
>> > 00:00.0 Host bridge: Intel Corporation 440GX - 82443GX Host bridge
>> > 00:01.0 PCI bridge: Intel Corporation 440GX - 82443GX AGP bridge
>> > 00:07.0 ISA bridge: Intel Corporation 82371AB/EB/MB PIIX4 ISA (rev 02)
>> > 00:07.1 IDE interface: Intel Corporation 82371AB/EB/MB PIIX4 IDE (rev 
>> > 01)
>> > 00:07.2 USB Controller: Intel Corporation 82371AB/EB/MB PIIX4 USB (rev 
>> > 01)
>> > 00:07.3 Bridge: Intel Corporation 82371AB/EB/MB PIIX4 ACPI (rev 02)
>> > 00:0b.0 SCSI storage controller: Adaptec AIC-7896U2/7897U2
>> > 00:0b.1 SCSI storage controller: Adaptec AIC-7896U2/7897U2
>> > 00:0d.0 Ethernet controller: Intel Corporation 82557/8/9/0/1 Ethernet 
>> > Pro 100
>> > (rev 08)
>> > 00:12.0 Ethernet controller: Realtek Semiconductor Co., Ltd.
>> > RTL-8139/8139C/8139C+ (rev 10)
>> > 01:00.0 VGA compatible controller: ATI Technologies Inc Rage 128 RL/VR 
>> > AGP
>> >
>> > ------- Comment #2 From David Hill 2009-06-17 02:55:56 (-) 
>> > [reply] -------
>> >
>> > With NETCONSOLE enabled, if I type:
>> > ethtool -s eth1 speed 100 duplex full autoneg on
>> >
>> > the computer freezes with kernel 2.6.29.4 and 2.6.30...
>> >
>> > I can reproduce it anytime you want.
>> >
>>
>> Interesting.  I wonder what the significance is of the 120 seconds.  I
>> see no such timers in e100.c.  Does the networking core have timers on
>> such intervals?
>>
> My guess is the 120 seconds has less to do with the driver, and more to do 
> with
> some other periodic event in the kernel that triggers a message getting 
> written
> to the console, which in turn triggers whatever deadlock it is thats 
> getting hit
> here.  I imagine we could diagnose it pretty quick if a stack trace or 
> vmcore
> could be captured on this.  David, can you enable the NMI watchdog on this
> system to trigger a panic on the system after a deadlock?  Then if you 
> could
> enable a second serial console, or setup kdump to capture a vmcore on this
> system, we should be able to  figure out whats going on.  My guess is that 
> in
> the e100 driver we're taking a lock in the ethtool set path, then calling
> printk, which winds up recursing into the driver, trying to take the same 
> lock
> again.  A stack trace will tell us for certain.
>
> Regards
> Neil
>
>> --
>> To unsubscribe from this list: send the line "unsubscribe netdev" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>>
>
> -- 
> This message has been scanned for viruses and
> dangerous content by MailScanner, and is
> believed to be clean.
>
>
> 

-- 
This message has been scanned for viruses and
dangerous content by MailScanner, and is
believed to be clean.

