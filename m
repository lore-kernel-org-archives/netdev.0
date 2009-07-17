From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [Bugme-new] [Bug 13553] New: When NETCONSOLE is enabled
	inkernel, computer crashes after 120seconds (approx)
Date: Fri, 17 Jul 2009 10:15:52 -0400
Message-ID: <20090717141552.GA3532@localhost.localdomain>
References: <3D5DEACBE93549EBB6594E165A92758F@delorimier>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andrew Morton <akpm@linux-foundation.org>, netdev@vger.kernel.org,
	bugzilla-daemon@bugzilla.kernel.org,
	bugme-daemon@bugzilla.kernel.org
To: David Hill <hilld@binarystorm.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:44660 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S964818AbZGQOQE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Jul 2009 10:16:04 -0400
Content-Disposition: inline
In-Reply-To: <3D5DEACBE93549EBB6594E165A92758F@delorimier>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jul 17, 2009 at 01:55:44AM -0400, David Hill wrote:
> Hi back,
> Look at bug 13219.  I'm not sure the bug is related to NETCONSOLE.
> It may be with the NIC drivers or the tools miidiag/ethtool or anything  
> else.
> The behavior of the system is random.
>
> I attached the NMI stack trace ... but for the kdump, I need to read a 
> bit more about it and think I'll need to patch the kernel... will I ?
>
> Thanks again,
>
> Dave
>
Neither of the logs you attached in the associated bugs seem to have the NMI
lockup backtrace included.  As for a kdump, you won't need to patch the kernel,
no, but depending on what kernel you're using, you may need to build the kernel
with CONFIG_CRASH and CONFIG_KEXEC turned on.

Neil

>
> ----- Original Message ----- From: "David Hill" <hilld@binarystorm.net>
> To: "Neil Horman" <nhorman@tuxdriver.com>; "Andrew Morton"  
> <akpm@linux-foundation.org>
> Cc: <netdev@vger.kernel.org>; <bugzilla-daemon@bugzilla.kernel.org>;  
> <bugme-daemon@bugzilla.kernel.org>
> Sent: Thursday, July 16, 2009 1:42 AM
> Subject: Re: [Bugme-new] [Bug 13553] New: When NETCONSOLE is enabled  
> inkernel, computer crashes after 120seconds (approx)
>
>
>> Will try that in the next few days... sorry for the delay.  I was on  
>> vacation for the last 2 weeks and thus, out of town :D
>>
>>
>>
>> ----- Original Message ----- From: "Neil Horman" 
>> <nhorman@tuxdriver.com>
>> To: "Andrew Morton" <akpm@linux-foundation.org>
>> Cc: <netdev@vger.kernel.org>; <bugzilla-daemon@bugzilla.kernel.org>;  
>> <bugme-daemon@bugzilla.kernel.org>; <hilld@binarystorm.net>
>> Sent: Tuesday, June 23, 2009 9:05 PM
>> Subject: Re: [Bugme-new] [Bug 13553] New: When NETCONSOLE is enabled  
>> inkernel, computer crashes after 120seconds (approx)
>>
>>
>>> On Tue, Jun 23, 2009 at 02:07:43PM -0700, Andrew Morton wrote:
>>>>
>>>> (switched to email.  Please respond via emailed reply-to-all, not 
>>>> via the
>>>> bugzilla web interface).
>>>>
>>>> On Wed, 17 Jun 2009 01:55:54 GMT
>>>> bugzilla-daemon@bugzilla.kernel.org wrote:
>>>>
>>>> > http://bugzilla.kernel.org/show_bug.cgi?id=13553
>>>> >
>>>> >            Summary: When NETCONSOLE is enabled in kernel, 
>>>> computer > crashes
>>>> >                     after 120seconds (approx)
>>>> >            Product: Networking
>>>> >            Version: 2.5
>>>> >     Kernel Version: 2.6.29.4, 2.6.30
>>>> >           Platform: All
>>>> >         OS/Version: Linux
>>>> >               Tree: Mainline
>>>> >             Status: NEW
>>>> >           Severity: high
>>>> >           Priority: P1
>>>> >          Component: Other
>>>> >         AssignedTo: acme@ghostprotocols.net
>>>> >         ReportedBy: hilld@binarystorm.net
>>>> >         Regression: No
>>>> >
>>>> >
>>>>
>>>> > 00:00.0 Host bridge: Intel Corporation 440GX - 82443GX Host bridge
>>>> > 00:01.0 PCI bridge: Intel Corporation 440GX - 82443GX AGP bridge
>>>> > 00:07.0 ISA bridge: Intel Corporation 82371AB/EB/MB PIIX4 ISA (rev 02)
>>>> > 00:07.1 IDE interface: Intel Corporation 82371AB/EB/MB PIIX4 IDE 
>>>> (rev > 01)
>>>> > 00:07.2 USB Controller: Intel Corporation 82371AB/EB/MB PIIX4 USB 
>>>> (rev > 01)
>>>> > 00:07.3 Bridge: Intel Corporation 82371AB/EB/MB PIIX4 ACPI (rev 02)
>>>> > 00:0b.0 SCSI storage controller: Adaptec AIC-7896U2/7897U2
>>>> > 00:0b.1 SCSI storage controller: Adaptec AIC-7896U2/7897U2
>>>> > 00:0d.0 Ethernet controller: Intel Corporation 82557/8/9/0/1 
>>>> Ethernet > Pro 100
>>>> > (rev 08)
>>>> > 00:12.0 Ethernet controller: Realtek Semiconductor Co., Ltd.
>>>> > RTL-8139/8139C/8139C+ (rev 10)
>>>> > 01:00.0 VGA compatible controller: ATI Technologies Inc Rage 128 
>>>> RL/VR > AGP
>>>> >
>>>> > ------- Comment #2 From David Hill 2009-06-17 02:55:56 (-) > 
>>>> [reply] -------
>>>> >
>>>> > With NETCONSOLE enabled, if I type:
>>>> > ethtool -s eth1 speed 100 duplex full autoneg on
>>>> >
>>>> > the computer freezes with kernel 2.6.29.4 and 2.6.30...
>>>> >
>>>> > I can reproduce it anytime you want.
>>>> >
>>>>
>>>> Interesting.  I wonder what the significance is of the 120 seconds.  I
>>>> see no such timers in e100.c.  Does the networking core have timers on
>>>> such intervals?
>>>>
>>> My guess is the 120 seconds has less to do with the driver, and more 
>>> to do with
>>> some other periodic event in the kernel that triggers a message 
>>> getting written
>>> to the console, which in turn triggers whatever deadlock it is thats  
>>> getting hit
>>> here.  I imagine we could diagnose it pretty quick if a stack trace 
>>> or vmcore
>>> could be captured on this.  David, can you enable the NMI watchdog on 
>>> this
>>> system to trigger a panic on the system after a deadlock?  Then if 
>>> you could
>>> enable a second serial console, or setup kdump to capture a vmcore on 
>>> this
>>> system, we should be able to  figure out whats going on.  My guess is 
>>> that in
>>> the e100 driver we're taking a lock in the ethtool set path, then calling
>>> printk, which winds up recursing into the driver, trying to take the 
>>> same lock
>>> again.  A stack trace will tell us for certain.
>>>
>>> Regards
>>> Neil
>>>
>>>> --
>>>> To unsubscribe from this list: send the line "unsubscribe netdev" in
>>>> the body of a message to majordomo@vger.kernel.org
>>>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>>>>
>>>
>>> -- 
>>> This message has been scanned for viruses and
>>> dangerous content by MailScanner, and is
>>> believed to be clean.
>>>
>>>
>>>
>>
>
> -- 
> This message has been scanned for viruses and
> dangerous content by MailScanner, and is
> believed to be clean.
>
>
