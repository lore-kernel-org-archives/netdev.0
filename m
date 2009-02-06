From: Robert Hancock <hancockrwd@gmail.com>
Subject: Re: Regression on VIA C3 motherboard, commit: 66f2173e2
Date: Thu, 05 Feb 2009 18:33:11 -0600
Message-ID: <498B8547.1010803@gmail.com>
References: <498A93E5.2080509@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-kernel <linux-kernel@vger.kernel.org>, len.brown@intel.com,
	NetDev <netdev@vger.kernel.org>
To: Ben Greear <greearb@candelatech.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from yx-out-2324.google.com ([74.125.44.28]:11592 "EHLO
	yx-out-2324.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754058AbZBFAdQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Feb 2009 19:33:16 -0500
In-Reply-To: <498A93E5.2080509@candelatech.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ben Greear wrote:
> I have a via motherboard with C3 processor and some real-tek NICs.  I 
> noticed
> when using the top-of-tree that performance on it sucked (30Mbps v/s 54Mbps
> network throughput in one pertinent test).
> 
> After several hours of bisecting, I see this as the culprit:
> 
> 7b37b5fd9ba32c0c5afc3537eed7e7466f2173e2 is first bad commit
> commit 7b37b5fd9ba32c0c5afc3537eed7e7466f2173e2
> Author: Len Brown <len.brown@intel.com>
> Date:   Tue Dec 23 01:47:42 2008 -0500
> 
>    ACPI: disable MPS when NO APIC-table found
>      When ACPI is asked to find an MADT (APIC table)
>    and fails, then ACPI expects to run in PIC mode.
>      However, if an MP Table is was found, IRQs will be
>    registered as if an IOAPIC is being used, even
>    though ACPI is configuring interrupt links links for PIC mode.
>      In this scenario, disable MPS so that IRQs
>    are registered in PIC mode, consistent with ACPI.
>      http://bugzilla.kernel.org/show_bug.cgi?id=12257
>      Signed-off-by: Len Brown <len.brown@intel.com>
> 
> :040000 040000 86ce74daee3a9fe6ff21ef7f8fb364af23ec0c1e 
> 364933dfec0df34e63b1aeff6aff4092d421886b M      arch
> 
> 
> In addition, I see this warning in my logs, which is likely the symptom:
> 
> ACPI Exception (tbxface-0627): AE_NO_ACPI_TABLES, While loading 
> namespace from ACPI tables ]
> ACPI: Unable to load the System Description Tables

You're getting this on boot:

ACPI Error (tbxfroot-0218): A valid RSDP was not found [20080926]

That essentially means ACPI isn't working at all, I think. Did previous 
kernels produce this error? Do you have ACPI disabled in the BIOS or 
something?
