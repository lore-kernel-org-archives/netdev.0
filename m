From: =?ISO-8859-1?Q?Nicolas_de_Peslo=FCan?=
	<nicolas.2p.debian@gmail.com>
Subject: Re: bonding can't change to another slave if you ifdown the active
 slave
Date: Sat, 05 Mar 2011 14:49:55 +0100
Message-ID: <4D723F83.7080309@gmail.com>
References: <4D704B35.20700@gmail.com> <20110305025332.GR11864@gospo.rdu.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Andy Gospodarek <andy@greyhouse.net>, netdev@vger.kernel.org,
	bonding-devel@lists.sourceforge.net, Linda Wang <lwang@redhat.com>
To: Weiping Pan <panweiping3@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:48950 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750853Ab1CENt7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 5 Mar 2011 08:49:59 -0500
Received: by wyg36 with SMTP id 36so2989542wyg.19
        for <netdev@vger.kernel.org>; Sat, 05 Mar 2011 05:49:58 -0800 (PST)
In-Reply-To: <20110305025332.GR11864@gospo.rdu.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 05/03/2011 03:53, Andy Gospodarek a =E9crit :
> On Fri, Mar 04, 2011 at 10:15:17AM +0800, Weiping Pan wrote:
>> Hi,
>>
>> I'm doing some Linux bonding driver test, and I find a problem in
>> balance-rr mode.
>> That's it can't change to another slave if you ifdown the active sla=
ve.
>> Any comments are warmly welcomed!
>>
>> regards
>> Weiping Pan
>>
>> My host is Fedora 14, and I install VirtualBox (4.0.2), and enable 4
>> nics for the guest system.
>
> Does this mean you are passing 4 NICs from your host to your guest
> (maybe via direct pci-device assignment to the guest) or are you
> creating 4 virtual devices on the host that are in a bridge group on =
the
> host?

VirtualBox does not allow assignment of pci-device to the guest. The ne=
twork interfaces on the guest=20
are pure virtual one, with several modes available. In order to help yo=
u trouble shooting this=20
problem, we need to know the mode form each of the virtual interfaces. =
Possible modes are NAT,=20
bridged, internal-network, and host-only-network.

Please provide the output of the following command:

VBoxManage showvminfo <your-vm-uuid> | grep ^NIC

To display your vm uuid, use the following command:

VBoxManage list vms

>
> [...]
>> [root@localhost ~]# ifconfig eth7 down
>
> This is not a great way to test link failure with bonding.  The best =
way
> is to actually pull the cable so the interface is truly down.

To virtually plug or unplug the cable from a virtual interface, use the=
 following command, replacing=20
the # with the interface number (from 1 to 8):

VBoxManage controlvm setlinkstate# on
VBoxManage controlvm setlinkstate# off

	Nicolas.
