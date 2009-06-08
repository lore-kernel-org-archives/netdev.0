From: Vegard Nossum <vegard.nossum@gmail.com>
Subject: Re: net: uninitialized loopback addr leaks to userspace
Date: Mon, 8 Jun 2009 12:00:47 +0200
Message-ID: <19f34abd0906080300w796c6b65o6b537064cac917b0@mail.gmail.com>
References: <19f34abd0905301323k1498ca3fv31b271de65d60afc@mail.gmail.com>
	 <1244408607.9064.8.camel@Maple>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>,
	Ingo Molnar <mingo@elte.hu>,
	Pekka Enberg <penberg@cs.helsinki.fi>,
	LKML <linux-kernel@vger.kernel.org>
To: John Dykstra <john.dykstra1@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f213.google.com ([209.85.218.213]:47441 "EHLO
	mail-bw0-f213.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752575AbZFHKAq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Jun 2009 06:00:46 -0400
In-Reply-To: <1244408607.9064.8.camel@Maple>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2009/6/7 John Dykstra <john.dykstra1@gmail.com>:
> On Sat, 2009-05-30 at 22:23 +0200, Vegard Nossum wrote:
>> It seems that loopback's hardware address is never initialized by the
>> kernel. So if userspace attempts to read this address before it has
>> been set, the kernel will return some uninitialized data (only 6
>> bytes, though).
>
> Thank you for the report, Vegard.
>
> I've been unable to reproduce the problem you describe, using
> 2.6-30-rc8, this test program and a couple of kernel builds for system
> load:
[...]
> ------------------------------------------------------------------
>
> Looking at the kernel code, it appears that all bytes of struct
> net_device, including the L2 address, are initialized to zeros at
> interface creation time.
>
> Can you spot a difference between your test procedures and mine that
> would enable me to reproduce the problem?

Hi,

I just tried your test program on a linux-next kernel, it works beautifully :-)

(I made one change: The stack grows downwards on x86, so I think you
should put child_stack + 16386 as the stack to clone()?)

As I wrote in reply to Stephen Hemminger, this problem seems to be
caused by a particular patch in linux-next:

commit f001fde5eadd915f4858d22ed70d7040f48767cf
Author: Jiri Pirko <jpirko@redhat.com>
Date:   Tue May 5 02:48:28 2009 +0000

   net: introduce a list of device addresses dev_addr_list (v6)

Thanks for testing.


Vegard

-- 
"The animistic metaphor of the bug that maliciously sneaked in while
the programmer was not looking is intellectually dishonest as it
disguises that the error is the programmer's own creation."
	-- E. W. Dijkstra, EWD1036
