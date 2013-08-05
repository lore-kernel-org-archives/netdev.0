From: Nikolay Aleksandrov <nikolay@redhat.com>
Subject: Re: bonding + arp monitoring fails if interface is a vlan
Date: Mon, 05 Aug 2013 12:26:14 +0200
Message-ID: <51FF7DC6.7080602@redhat.com>
References: <20130801121142.GA444@www.manty.net> <51FB9EE5.3040907@redhat.com> <CAJk_L2FJyD2X7EPztiVWLBD4NDR_VOehdFEeV+nq7a+sO9+_wA@mail.gmail.com> <CAJk_L2FU6GcHUoC+UdNJoULN9KewoUQAMhapC0k3RcTqNOymnw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: Santiago Garcia Mantinan <manty@manty.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:52893 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752156Ab3HEKpw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 5 Aug 2013 06:45:52 -0400
In-Reply-To: <CAJk_L2FU6GcHUoC+UdNJoULN9KewoUQAMhapC0k3RcTqNOymnw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/05/2013 12:26 PM, Santiago Garcia Mantinan wrote:
> 2013/8/4 Santiago Garcia Mantinan <manty@manty.net>:
>> 2013/8/2 Nikolay Aleksandrov <nikolay@redhat.com>:
>>> I believe that it is because dev_trans_start() returns 0 for 8021q devices and
>>> so the calculations if the slave has transmitted are wrong, and the flip-flop
>>> happens.
>>> Please try the attached patch, it should resolve your issue (basically it gets
>>> the dev_trans_start of the vlan's underlying device if a vlan is found).
>>
>> Thanks, patched and compiling, I'll try today with my laptops and
>> tomorrow at the lab I had setup and then at the original machine.
>>
>> I'll let you know how things go.
> 
> Ok, initial tests seem to show that a bonding defined like I had on my
> very basic setup that I sent to the list is now working.
> 
> What doesn't seem to be working is if I set it up using bonding under
> the vlans and then doing a bond of those, I mean:
> 
> iface bond0 inet manual
>         bond-slaves eth0
>         bond-mode 802.3ad
>         bond-miimon 100
> ...
> iface bond2 inet static
>         address 192.168.1.2
>         netmask 255.255.255.0
>         bond-slaves bond0.1001 bond0.1002
>         bond-mode active-backup
>         bond-arp_validate 0
>         bond-arp_interval 2000
>         bond-arp_ip_target 192.168.1.1
> ...
> 
> Should this bond of bonds work?
> 
No, because we take the first non-vlan's interface trans_start after the patch
which in this case is a bonding interface which also doesn't update its
trans_start, i.e. bond over bond (or over vlans over bond) with arp monitoring
shouldn't work.

> I'm doing more tests to make sure that the basic eth0.1001 and
> eth0.1002 works 100% after finding that the bond of bonds wasn't
> working ok, just in case the basic was also failing, but at least the
> double bond is failing and basic bond seems to work ok.
> 
> Regards.
> 
