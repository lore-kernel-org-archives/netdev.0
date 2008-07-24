From: "Vegard Nossum" <vegard.nossum@gmail.com>
Subject: Re: recent -git: BUG in free_thread_xstate
Date: Thu, 24 Jul 2008 02:02:28 +0200
Message-ID: <19f34abd0807231702u2c82f119pd2c756c96a1766e8@mail.gmail.com>
References: <19f34abd0807231307y191c0ad7tfab4cda57ee88eb@mail.gmail.com>
	 <b647ffbd0807231422w546e59e9p8362ee798b169a25@mail.gmail.com>
	 <b647ffbd0807231435h73740808p76143d3d4457b597@mail.gmail.com>
	 <19f34abd0807231445h79fac5cbwecd0563b74bc18ad@mail.gmail.com>
	 <b647ffbd0807231501va30f6d4kee49d1daa30227fc@mail.gmail.com>
	 <19f34abd0807231505w1a25c2bak329a622f3a287e97@mail.gmail.com>
	 <19f34abd0807231545u5bc8b55fm768527a02268f111@mail.gmail.com>
	 <19f34abd0807231550h4ba88a9qa27b1c9e5afc80cb@mail.gmail.com>
	 <19f34abd0807231620q6d870bc0k74d176c9e5253ff3@mail.gmail.com>
	 <1216857235.15519.189.camel@calx>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: "Dmitry Adamushko" <dmitry.adamushko@gmail.com>,
	"Jeff Garzik" <jgarzik@pobox.com>,
	"Suresh Siddha" <suresh.b.siddha@intel.com>,
	LKML <linux-kernel@vger.kernel.org>,
	"the arch/x86 maintainers" <x86@kernel.org>,
	"Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
	"Ingo Molnar" <mingo@elte.hu>,
	"Peter Zijlstra" <a.p.zijlstra@chello.nl>, netdev@vger.kernel.org,
	"Arnaldo Carvalho de Melo" <acme@redhat.com>
To: "Matt Mackall" <mpm@selenic.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1756590AbYGXACj@vger.kernel.org>
In-Reply-To: <1216857235.15519.189.camel@calx>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Jul 24, 2008 at 1:53 AM, Matt Mackall <mpm@selenic.com> wrote:
>
> On Thu, 2008-07-24 at 01:20 +0200, Vegard Nossum wrote:
>> >> +extern void warn_on_slowpath(const char *file, int line);
>
> Mmm, fun.
>
>> >>  [<c013496f>] warn_on_slowpath+0x4f/0x70
>> >>  [<c0198041>] ? check_bytes_and_report+0x21/0xc0
>> >>  [<c04a8544>] ? __kfree_skb+0x34/0x80
>> >>  [<c0198041>] ? check_bytes_and_report+0x21/0xc0
>> >>  [<c01983ef>] ? check_object+0xdf/0x1f0
>> >>  [<c0198041>] ? check_bytes_and_report+0x21/0xc0
>> >>  [<c04a8544>] ? __kfree_skb+0x34/0x80
>> >>  [<c01983ef>] ? check_object+0xdf/0x1f0
>> >>  [<c04bbafc>] ? find_skb+0x3c/0x80
>> >>  [<c04a9f7e>] skb_copy_and_csum_dev+0xee/0x100
>> >>  [<c03539d7>] rtl8139_start_xmit+0x57/0x130
>> >>  [<c019a84b>] ? __kmalloc_track_caller+0x8b/0x120
>> >>  [<c04bba6e>] netpoll_send_skb+0x14e/0x1a0
>> >>  [<c04bbf54>] netpoll_send_udp+0x1e4/0x210
>
> Trying to warn_on from inside a network driver from inside netpoll may
> cause trouble.

Yeah.. but apparently it was fine? I'll try to disable netconsole and
see if I can still get the crash.

BTW, I posted this earlier (but without all the Ccs, and without my
debugging patch):

=============================================================================
BUG task_struct: Poison overwritten
-----------------------------------------------------------------------------
INFO: 0xf3d00000-0xf3d0006b. First byte 0x1 instead of 0x6b
INFO: Allocated in copy_process+0x68/0x1130 age=4 cpu=0 pid=4338
INFO: Freed in free_task+0x2c/0x30 age=2 cpu=0 pid=4
INFO: Slab 0xc1c25c00 objects=8 used=3 fp=0xf3d00000 flags=0x400020c3
INFO: Object 0xf3d00000 @offset=0 fp=0xf3d03fc0
 Object 0xf3d00000:  01 40 66 00 00 16 ec ee ad b9 00 1c 26 8a 70 f8
 Object 0xf3d00010:  08 00 45 00 00 54 00 00 40 00 40 01 b7 e8 c0 a8
 Object 0xf3d00020:  00 c4 c0 a8 00 ac 08 00 6e c0 df 24 55 33 75 af

And I just realized that c0 a8 00 c4 is my IP address, 192.168.0.196 :-)

So _something_ seems to be up with networking :-)

(And this is in task_struct! Wow...)


Vegard

-- 
"The animistic metaphor of the bug that maliciously sneaked in while
the programmer was not looking is intellectually dishonest as it
disguises that the error is the programmer's own creation."
	-- E. W. Dijkstra, EWD1036
