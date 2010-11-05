From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: OOM when adding ipv6 route:  How to make available more
 per-cpu memory?
Date: Fri, 05 Nov 2010 23:11:43 +0100
Message-ID: <1288995103.2665.653.camel@edumazet-laptop>
References: <4CD43C87.5040403@candelatech.com>
	 <1288980361.2882.1070.camel@edumazet-laptop>
	 <4CD449A5.5070305@candelatech.com>
	 <1288988403.2665.268.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: NetDev <netdev@vger.kernel.org>,
	linux-kernel <linux-kernel@vger.kernel.org>,
	Tejun Heo <tj@kernel.org>
To: Ben Greear <greearb@candelatech.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:48092 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752641Ab0KEWLt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 5 Nov 2010 18:11:49 -0400
In-Reply-To: <1288988403.2665.268.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le vendredi 05 novembre 2010 =C3=A0 21:20 +0100, Eric Dumazet a =C3=A9c=
rit :
> Your vmalloc space is very fragmented. pcpu_get_vm_areas() want
> hugepages (4MB on your machine, 2MB on mine because I have
> CONFIG_HIGHMEM64G=3Dy)

Well, this is wrong. We use normal (4KB) pages, unfortunately.

I have a NUMA machine, with two nodes, so pcpu_get_vm_areas() allocates
two zones, one for each node, with a 'known' offset between them.
Then, 4KB pages are allocated to populate the zone when needed.

# grep pcpu_get_vm_areas /proc/vmallocinfo=20
0xffffe8ffa0400000-0xffffe8ffa0600000 2097152 pcpu_get_vm_areas+0x0/0x7=
40 vmalloc
0xffffe8ffffc00000-0xffffe8ffffe00000 2097152 pcpu_get_vm_areas+0x0/0x7=
40 vmalloc

BTW, we dont have the number of pages currently allocated in each
'vmalloc' zone, and/or node information.

Tejun, do you have plans to use hugepages eventually ?
(and fallback to 4KB pages, but most percpu data are allocated right
after boot)

Thanks


