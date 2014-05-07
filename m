From: David Vrabel <david.vrabel@citrix.com>
Subject: Re: [Xen-devel] [3.15-rc3] Bisected: xen-netback mangles packets
 between two guests on a bridge since merge of "TX grant mapping with SKBTX_DEV_ZEROCOPY
 instead of copy" series.
Date: Wed, 7 May 2014 09:16:57 +0100
Message-ID: <5369EBF9.20304@citrix.com>
References: <395225650.20140430124506@eikelenboom.it>	<536162D3.5080307@citrix.com>	<94755525.20140501002553@eikelenboom.it>	<53624E25.8040404@citrix.com>	<1810270947.20140501155911@eikelenboom.it>	<53626C39.3030304@citrix.com>	<928229683.20140501193936@eikelenboom.it>	<198418193.20140501213951@eikelenboom.it>	<5363A508.1000602@citrix.com>	<653156457.20140502160632@eikelenboom.it>	<5363AFED.5080601@citrix.com>	<1399044073.29914.237.camel@edumazet-glaptop2.roam.corp.google.com>	<5363B929.1000502@citrix.com>	<35970097.20140502182818@eikelenboom.it>	<5363CBB0.6050804@citrix.com>	<15602339.20140505121912@eikelenboom.it>	<536916E9.7010509@crc.id.au>	<53691848.5010809@citrix.com>	<437888929.20140506193723@eikelenboom.it> <536924DC.9080606@crc.id.au>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Ian Campbell <Ian.Campbell@citrix.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	<netdev@vger.kernel.org>, <xen-devel@lists.xen.org>,
	"David S. Miller" <davem@davemloft.net>
To: Steven Haigh <netwiz@crc.id.au>,
	Sander Eikelenboom <linux@eikelenboom.it>,
	Zoltan Kiss <zoltan.kiss@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.citrix.com ([66.165.176.89]:33948 "EHLO SMTP.CITRIX.COM"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751838AbaEGIRA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 7 May 2014 04:17:00 -0400
In-Reply-To: <536924DC.9080606@crc.id.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 06/05/14 19:07, Steven Haigh wrote:
> On 07/05/14 03:37, Sander Eikelenboom wrote:
>>
>> Tuesday, May 6, 2014, 7:13:44 PM, you wrote:
>>
>>> On 06/05/14 18:07, Steven Haigh wrote:
>>>> On a related note, I'm seeing this on an Arch Linux DomU and kernel
>>>> 3.14.2. Its running aria2c bit torrent client.
>>>>
>>>> The Dom0 is EL6 with Xen 4.2.4 / 3.14.2 kernel.
>>>>
>>>> I also lodged this on the Arch bug tracker:
>>>>       https://bugs.archlinux.org/task/40244
>>>>
>>>> In a nutshell, I see:
>>>> [ 7432.398096] xen_netfront: xennet: skb rides the rocket: 19 slots
>>>> [ 7434.270870] xen_netfront: xennet: skb rides the rocket: 19 slots
>>>> [ 7434.782199] xen_netfront: xennet: skb rides the rocket: 19 slots
>>>> [ 7435.184794] xen_netfront: xennet: skb rides the rocket: 19 slots
>>>> [ 7437.530677] xen_netfront: xennet: skb rides the rocket: 19 slots
>>>> [ 7437.973905] xen_netfront: xennet: skb rides the rocket: 19 slots
>>>> [ 7438.383947] xen_netfront: xennet: skb rides the rocket: 19 slots
>>
>>> Can you also see packet corruption? You can find a testfile generator in 
>>> Sander's mail, downloading from an Apache server with wget seems to be OK.
>>
>> The corruption shouldn't be there since he is running 3.14.2 which is fine.
>>
>> And note that the corruption with 3.15 only seems to occur in traffic between 
>> guests  and not between dom0 and guest. The bit torrent traffic is probably 
>> inet <-> dom0 <-> guest, so shouldn't be affected, even with 3.15.
> 
> Well, I'm trying to get a test together - although I don't have webdav
> anywhere... I was going to try it via FTP, however I'm hitting another
> MMU bug in Xen:
> 	https://bugs.archlinux.org/task/38596
> 
> This references:
> 	https://lkml.org/lkml/2014/1/23/596
> 
> It says that should be fixed in 3.15-rc3 (if I understand properly) -
> but I'm also hitting that on 3.14.2. Did these changes get ported back
> to the 3.14 tree?

This is fixed by 29c7787075 (mm: use paravirt friendly ops for NUMA
hinting ptes) which is tagged for stable but hasn't yet been picked up
for 3.14.y.

You can also work around it by disabling CONFIG_NUMA_BALANCING which
doesn't work with Xen PV guests anyway.

David
