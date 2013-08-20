From: Nikolay Aleksandrov <nikolay@redhat.com>
Subject: Re: bonding + arp monitoring fails if interface is a vlan
Date: Tue, 20 Aug 2013 12:11:34 +0200
Message-ID: <521340D6.5080108@redhat.com>
References: <20130801121142.GA444@www.manty.net> <51FB9EE5.3040907@redhat.com> <CAJk_L2FJyD2X7EPztiVWLBD4NDR_VOehdFEeV+nq7a+sO9+_wA@mail.gmail.com> <CAJk_L2FU6GcHUoC+UdNJoULN9KewoUQAMhapC0k3RcTqNOymnw@mail.gmail.com> <51FF7DC6.7080602@redhat.com> <CAJk_L2FTs0bX_s+ChKY9ZvZqVTagE=LQZpwV48b1RFhgtMsd8w@mail.gmail.com> <5201F99D.2060809@redhat.com> <CAJk_L2FuxrZrgg6_95Ww_0nVaE8Ff=1fmsUk+ghxCQ=LPyVzaQ@mail.gmail.com> <CAJk_L2Ep-HoROtyThk26t8x3HQFy9+5-7k-e4G15Nm_F0KxV-A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: Santiago Garcia Mantinan <manty@manty.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:22955 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750913Ab3HTKPk (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 20 Aug 2013 06:15:40 -0400
In-Reply-To: <CAJk_L2Ep-HoROtyThk26t8x3HQFy9+5-7k-e4G15Nm_F0KxV-A@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/20/2013 10:05 AM, Santiago Garcia Mantinan wrote:
> Hi!
> 
> Sorry it took me so long to reply back. I've been doing more tests on
> xor mode and I see that arp monitoring is not working at all. I
> haven't found any doc that says which modes should be compatible with
> arp monitoring, maybe xor mode shouldn't be used at all.
> 
> My last setup is a Linux with a couple of vlans both interfaces
> (eth2.1001 and eth2.1002) with IP 192.168.1.1 (no bonding at all) and
> another Linux machine with a 3.11-rc3 with Nicolay's arp fix for
> bonding and a bond configured like this:
> 
> iface bond0 inet static
>         address 192.168.1.2
>         netmask 255.255.255.0
>         bond-slaves eth0.1001 eth0.1002 eth1.1001 eth1.1002
>         bond-mode balance-xor
>         bond-arp_validate 0
>         bond-arp_interval 2000
>         bond-arp_ip_target 192.168.1.1
> 
> A silly switch connects the couple of ethernets of the machine with
> the bond to the interface of the not bonded machine.
> 
> What I saw was that the bonded machine didn't detect the ifconfig down
> of the interfaces of the not bonded machine at all. That drove me to
> the hypothesis that the bonded machine was considering its own traffic
> (there was no traffic but the arp requests of the bonding) as
> indication that the link was ok.
> 
> To test the hypothesis, when the not bonded machine (192.168.1.1)
> which is the target for arp requests was unplugged and the bonding was
> seeing all interfaces up (not detecting that the other machine was not
> responding) I unplugged one of the bonded interfaces and all 4 slaves
> went to down, then if I replugged it all 4 would go up.
> 
> Maybe this is something to be expected due to arp monitoring not
> working with balance-xor, but I haven't found any doc saying this.
> 
> If you need the debug info for this I can send it, but the events show
> nothing, as there are no event saying that link is lost or anything
> :-(
> 
> Regards.
> 
Hi,
This setup works for me, what might be wrong with your setup is that you connect
all 4 ports to a "dumb" switch, and you have the same vlans over the real
devices that are connected so they see each other's packets and the port's
last_rx gets updated so they stay up.
I tried your setup with a "smart" switch so the ports couldn't see each other
and only the one that saw 192.168.1.1 was up, and the moment 192.168.1.1 went
down - the port went down in the bonding.

Cheers,
 Nik
