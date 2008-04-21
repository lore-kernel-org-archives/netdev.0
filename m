From: "Kok, Auke" <auke-jan.h.kok@intel.com>
Subject: Re: [BUG REPORT, 2.6.22] e1000: detected tx unit hang
Date: Mon, 21 Apr 2008 14:44:59 -0700
Message-ID: <480D0ADB.9000308@intel.com>
References: <1071646044.20080421225227@3d-io.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: speedy <speedy@3d-io.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:10578 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752814AbYDUVqO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 21 Apr 2008 17:46:14 -0400
In-Reply-To: <1071646044.20080421225227@3d-io.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

[dropped lkml from the Cc]

speedy wrote:
> Hello Linux crew,
> 
>         I've just switched the
> 
>         Ethernet controller: Intel Corporation 82545GM Gigabit Ethernet Controller (rev 01)
> 
>         netword card to an NForce 2 based motherboard and after a day
>         of work it got stuck with "detected tx unit hang" messages
>         showing in the console.
> 
>         The card worked flawlessly under load in a different computer
>         for two years now, under the same/similar Ubuntu operating system.
> 
>         Unfortunaltly, the EEPROM fix from
> 
>         http://e1000.sourceforge.net/doku.php?id=known_issues&DokuWiki=9502f399bc8cae1528c5e85d2bc423f6
> 
>         from is not working/applicable:
> 
>         root@backupserver:~# ./fixeep-82573-dspd.sh eth1
>         No appropriate hardware found for this fixup

correct, that fix is only for very specific adapters which are based on a totally
different chipset than the one you have.

>         root@backupserver:~#
> 
>         /var/log/messages:  http://87.230.23.147/messages.txt
>         /proc/interrupts: http://87.230.23.147/proc_interrupts.txt
>         lspci -vv: http://87.230.23.147/lspcivv.txt
> 
> 
>         If more info is needed, let me know.


basically it's inserted into a new motherboard?

what was the old motherboard?

can you check the BIOS and disable things like "PCI Write combining" or
"Writeback" or any option looking similar to that?

It appears you hit an issue that is exposed by these adapters on some AMD/NVIDIA
chipset-based motherboards. This issue is known and we are investigating this and
have been for a long time. The root cause is still yet unknown however.

For some people disabling TSO helps to relieve the situation. You could give that
a try.

Cheers,

Auke

