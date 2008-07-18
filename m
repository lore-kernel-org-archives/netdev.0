From: Christoph Lameter <cl@linux-foundation.org>
Subject: Re: [bug, netconsole, SLUB] BUG skbuff_head_cache: Poison overwritten
Date: Fri, 18 Jul 2008 08:54:56 -0500
Message-ID: <4880A0B0.9060007@linux-foundation.org>
References: <20080717214222.GA29449@elte.hu>	 <Pine.LNX.4.64.0807181149460.3852@sbz-30.cs.Helsinki.FI>	 <20080718091146.GQ6875@elte.hu> <84144f020807180216mfd5e803o8f3f1a94b2db1a74@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Ingo Molnar <mingo@elte.hu>, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, Vegard Nossum <vegard.nossum@gmail.com>,
	"Rafael J. Wysocki" <rjw@sisk.pl>, davem@davemloft.net,
	johnpol@2ka.mipt.ru
To: Pekka Enberg <penberg@cs.helsinki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:59450 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756161AbYGRN43 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Jul 2008 09:56:29 -0400
In-Reply-To: <84144f020807180216mfd5e803o8f3f1a94b2db1a74@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Pekka Enberg wrote:
> On Fri, Jul 18, 2008 at 12:11 PM, Ingo Molnar <mingo@elte.hu> wrote:
>> * Pekka J Enberg <penberg@cs.helsinki.fi> wrote:
>>
>>>>   Object 0xf658ae70:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
>>> It's bit unfortunate that we don't see full dump of the corruption
>>> here because SLUB limits the output to 128 bytes. Ingo, you might want
>>> to try this patch so that we can see all of it:
>> ok, applied this as a debug special to tip/out-of-tree - future
>> incidents should have the full object dump.
>>
>> would makes sense for upstream too i think, or increase the limit to 4K
>> or so. (which is still fair to be dumped into a syslog)
> 
> SLUB already limits object sizes to less than PAGE_SIZE so the patch
> should be fine. Christoph, are you okay with this going upstream?

I am fine with the patch. Just be aware that we are going to be shoveling a lot of stuff into the log. The object size can be greater than 4k for non kmalloc slab caches. True in general object sizes are <4k.


