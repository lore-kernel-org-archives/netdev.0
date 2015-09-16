From: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Subject: Re: [linux-next] oops in ip_route_input_noref
Date: Thu, 17 Sep 2015 08:47:38 +0900
Message-ID: <20150916234738.GA592@swordfish>
References: <20150916092447.GA945@swordfish>
 <55F9578C.40209@ericsson.com>
 <55F9699E.5080807@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Richard Alpe <richard.alpe@ericsson.com>,
	Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>,
	"David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: David Ahern <dsa@cumulusnetworks.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <55F9699E.5080807@cumulusnetworks.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On (09/16/15 07:07), David Ahern wrote:
> Hi Sergey:
> 

Hi,

sorry for long reply. Baremetal. So grabbing the backtrace is
a bit complicated. But it looks very close to what Richard Alpe
has posted.

in IRQ

RIP is at ip_route_input_noref

[    0.877597]  [<ffffffff8158e13c>] arp_process+0x39c/0x690
[    0.877597]  [<ffffffff8158e57e>] arp_rcv+0x13e/0x170


	-ss


> Is this with KVM or baremetal?
> 
> -----8<-----
> thanks for the analysis
> 
> >>addr2line -e vmlinux -i 0xffffffff8146c0b1
> >>net/ipv4/route.c:1815
> >>net/ipv4/route.c:1905
> >>
> >>
> >>which seems to be this line ip_route_input_noref()->ip_route_input_slow():
> >>...
> >>1813         rth->rt_is_input = 1;
> >>1814         if (res.table)
> >>1815                 rth->rt_table_id = res.table->tb_id;
> >>1816
> >>...
> >>
> >>
> >>added by b7503e0cdb5dbec5d201aa69d8888c14679b5ae8
> >>
> >>     net: Add FIB table id to rtable
> >>
> >>     Add the FIB table id to rtable to make the information available for
> >>     IPv4 as it is for IPv6.
> >>
> >>
> >>	-ss
> 
> Hi Richard:
> 
> >I to get an Oops in ip_route_input_noref(). It happens occasionally during bootup.
> >KVM environment using virtio driver. Let me know if you need any additional info or
> >if you want me to try to bisect it.
> >
> >Starting network...
> >...
> >[    0.877040] BUG: unable to handle kernel NULL pointer dereference at 0000000000000056
> >[    0.877597] IP: [<ffffffff8155b5e2>] ip_route_input_noref+0x1a2/0xb00
> 
> Can you send me your kernel config and qemu command line? KVM with virtio
> networking is a primary test vehicle, and I did not encounter this at all.
> 
> Thanks,
> David
> 
> 
