From: Satoshi OSHIMA <satoshi.oshima.fk@hitachi.com>
Subject: Re: [RFC/PATCH 2/3] UDP memory usage accounting: accounting unit
 and variable
Date: Fri, 28 Sep 2007 22:24:43 +0900
Message-ID: <46FD009B.1010904@hitachi.com>
References: <46F3B88D.1030601@hitachi.com> <p734pho9nb9.fsf@bingen.suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, haoki@redhat.com,
	=?windows-1252?Q?=3F=3F=3F?= =?windows-1252?Q?=3F?=
	<yoshfuji@linux-ipv6.org>,
	Yumiko SUGITA <yumiko.sugita.yf@hitachi.com>
To: Andi Kleen <andi@firstfloor.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail9.hitachi.co.jp ([133.145.228.44]:53444 "EHLO
	mail9.hitachi.co.jp" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751929AbXI1NYx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Sep 2007 09:24:53 -0400
Received: from mlsv10.hitachi.co.jp (unknown [133.144.234.166])
	by mail9.hitachi.co.jp (Postfix) with ESMTP id C150537CB4
	for <netdev@vger.kernel.org>; Fri, 28 Sep 2007 22:24:51 +0900 (JST)
In-Reply-To: <p734pho9nb9.fsf@bingen.suse.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

Thank you for your comment.

Andi Kleen wrote:
> Satoshi OSHIMA <satoshi.oshima.fk@hitachi.com> writes:
>
>> This patch introduces global variable for UDP memory accounting.
>> The unit is page.
>
> The global variable doesn't seem to be very MP scalable, especially
> if you change it for each packet. This will be a very hot cache line,
> in the worst case bouncing around a large machine.

I understand what you pointed out. But I think the accounting
method I'm proposing is very similar to TCP accounting and per
socket accounting.
How do you think of it?


> Possible alternatives:
> - Per CPU variables

I'm afraid that sockets and socket buffers are handled on
various CPUs. I mean that socket creation might be done
on CPU-A but socket receiving might be done on CPU-B.

And per CPU variables must be counted up when socket
cap is checked. I'm afraid that per CPU vaiables are
also costly enough.


> - You only change the global on socket creation time (by pre
allocating a large
> amount) or when the system comes under memory pressure.
> - Batching of the global updates for multiple packets [that's a variant
> of the previous one, might be still too costly though]
>
> Also for such variables it's usually good to cache line pad them on SMP
> to avoid false sharing with something else.

I believe that memory usage accounting should be done accurately.
Currently I couldn't see how can we know the accurate memory
accounting only when the system is under memory pressure.

But I revised the patch to avoid some atomic operations.

If I could find the good way to avoid atomic operation more,
I will add it.

Satoshi Oshima
