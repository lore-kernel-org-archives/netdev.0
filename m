From: "Pekka Enberg" <penberg@cs.helsinki.fi>
Subject: Re: [bug, netconsole, SLUB] BUG skbuff_head_cache: Poison overwritten
Date: Fri, 18 Jul 2008 12:02:26 +0300
Message-ID: <84144f020807180202l6c703234ic3a2b57e73a1d89a@mail.gmail.com>
References: <20080717214222.GA29449@elte.hu>
	 <20080718054626.GA3338@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "Ingo Molnar" <mingo@elte.hu>, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, "Vegard Nossum" <vegard.nossum@gmail.com>,
	"Rafael J. Wysocki" <rjw@sisk.pl>
To: "Evgeniy Polyakov" <johnpol@2ka.mipt.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rv-out-0506.google.com ([209.85.198.239]:35602 "EHLO
	rv-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753795AbYGRJC0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Jul 2008 05:02:26 -0400
Received: by rv-out-0506.google.com with SMTP id k40so255021rvb.1
        for <netdev@vger.kernel.org>; Fri, 18 Jul 2008 02:02:26 -0700 (PDT)
In-Reply-To: <20080718054626.GA3338@2ka.mipt.ru>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Evgeniy,

On Fri, Jul 18, 2008 at 8:46 AM, Evgeniy Polyakov <johnpol@2ka.mipt.ru> wrote:
> Hi Ingo.
>
> On Thu, Jul 17, 2008 at 11:42:22PM +0200, Ingo Molnar (mingo@elte.hu) wrote:
>> Pid: 5098, comm: gdm-binary Not tainted 2.6.26-tip #3094
>>  [<c0186f99>] print_trailer+0xa9/0xf0
>>  [<c018707b>] check_bytes_and_report+0x9b/0xc0
>>  [<c01874ae>] check_object+0x19e/0x1e0
>>  [<c0187ef1>] __slab_alloc+0x371/0x4e0
>>  [<c0188552>] kmem_cache_alloc+0xb2/0xc0
>>  [<c06732dc>] ? __alloc_skb+0x2c/0x110
>
> Out of curiosity, why does it scream at allocation time?

Because it's checking for use-after-free errors. The object is
poisoned with POISON_FREE when it's free'd and we verify the poison
values at allocation time.

On Fri, Jul 18, 2008 at 8:46 AM, Evgeniy Polyakov <johnpol@2ka.mipt.ru> wrote:
> Does SLUB have a debug check at freeing time? If so, how does it work
> and why didn't it caught use after free there?

You can't detect use after free before the object is actually free'd ;-)

                                      Pekka
