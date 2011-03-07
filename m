From: =?ISO-8859-1?Q?Nicolas_de_Peslo=FCan?=
	<nicolas.2p.debian@gmail.com>
Subject: Re: bonding can't change to another slave if you ifdown the active
 slave
Date: Mon, 07 Mar 2011 22:15:02 +0100
Message-ID: <4D754AD6.30901@gmail.com>
References: <4D704B35.20700@gmail.com> <20110305025332.GR11864@gospo.rdu.redhat.com> <4D723F83.7080309@gmail.com> <4D744D57.9050908@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Andy Gospodarek <andy@greyhouse.net>, netdev@vger.kernel.org,
	bonding-devel@lists.sourceforge.net, Linda Wang <lwang@redhat.com>
To: Weiping Pan <panweiping3@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:44481 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753215Ab1CGVPF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Mar 2011 16:15:05 -0500
Received: by wyg36 with SMTP id 36so4595260wyg.19
        for <netdev@vger.kernel.org>; Mon, 07 Mar 2011 13:15:04 -0800 (PST)
In-Reply-To: <4D744D57.9050908@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 07/03/2011 04:13, Weiping Pan a =E9crit :
> On 03/05/2011 09:49 PM, Nicolas de Peslo=FCan wrote:
>> Le 05/03/2011 03:53, Andy Gospodarek a =E9crit :
>>> On Fri, Mar 04, 2011 at 10:15:17AM +0800, Weiping Pan wrote:
>>>> Hi,
>>>>
>>>> I'm doing some Linux bonding driver test, and I find a problem in
>>>> balance-rr mode.
>>>> That's it can't change to another slave if you ifdown the active s=
lave.
>>>> Any comments are warmly welcomed!
>>>>
>>>> regards
>>>> Weiping Pan
>>>>
>>>> My host is Fedora 14, and I install VirtualBox (4.0.2), and enable=
 4
>>>> nics for the guest system.
>>>
>>> Does this mean you are passing 4 NICs from your host to your guest
>>> (maybe via direct pci-device assignment to the guest) or are you
>>> creating 4 virtual devices on the host that are in a bridge group o=
n the
>>> host?
>>
>> VirtualBox does not allow assignment of pci-device to the guest. The
>> network interfaces on the guest are pure virtual one, with several
>> modes available. In order to help you trouble shooting this problem,
>> we need to know the mode form each of the virtual interfaces. Possib=
le
>> modes are NAT, bridged, internal-network, and host-only-network.
>>
>> Please provide the output of the following command:
>>
>> VBoxManage showvminfo <your-vm-uuid> | grep ^NIC
>>
>> To display your vm uuid, use the following command:
>>
>> VBoxManage list vms
> [root@localhost ~]# VBoxManage showvminfo
> 67b83c47-0ee2-46bc-b0ff-e0eb43edc1c2 |grep ^NIC
> NIC 1: MAC: 0800270481A8, Attachment: Bridged Interface 'eth0', Cable
> connected: on, Trace: off (file: none), Type: 82540EM, Reported speed=
: 0
> Mbps, Boot priority: 0
> NIC 2: MAC: 08002778F641, Attachment: Bridged Interface 'eth0', Cable
> connected: on, Trace: off (file: none), Type: 82540EM, Reported speed=
: 0
> Mbps, Boot priority: 0
> NIC 3: MAC: 080027C408BA, Attachment: Bridged Interface 'eth0', Cable
> connected: on, Trace: off (file: none), Type: 82540EM, Reported speed=
: 0
> Mbps, Boot priority: 0
> NIC 4: MAC: 080027DB339A, Attachment: Bridged Interface 'eth0', Cable
> connected: on, Trace: off (file: none), Type: 82540EM, Reported speed=
: 0
> Mbps, Boot priority: 0
> NIC 5: disabled
> NIC 6: disabled
> NIC 7: disabled
> NIC 8: disabled
>
> And when guest starts, i find that:
> NIC 1: eth7
> NIC 2: eth6
> NIC 3: eth9
> NIC 4: eth8

Would you mind testing with "Host-only Interface 'vboxnet0'", instead o=
f "Bridged Interface 'eth0'"?

All the bonding tests I do use this setup and the link failure detectio=
n work well.

	Nicolas.
