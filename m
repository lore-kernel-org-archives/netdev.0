From: "Pekka Enberg" <penberg@cs.helsinki.fi>
Subject: Re: [bug, netconsole, SLUB] BUG skbuff_head_cache: Poison overwritten
Date: Fri, 18 Jul 2008 17:44:44 +0300
Message-ID: <84144f020807180744w40677f6dm790d2caee3ca0d15@mail.gmail.com>
References: <20080717214222.GA29449@elte.hu>
	 <20080718054626.GA3338@2ka.mipt.ru>
	 <84144f020807180202l6c703234ic3a2b57e73a1d89a@mail.gmail.com>
	 <20080718101624.GA7107@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "Ingo Molnar" <mingo@elte.hu>, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, "Vegard Nossum" <vegard.nossum@gmail.com>,
	"Rafael J. Wysocki" <rjw@sisk.pl>,
	"Christoph Lameter" <cl@linux-foundation.org>
To: "Evgeniy Polyakov" <johnpol@2ka.mipt.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rv-out-0506.google.com ([209.85.198.226]:52405 "EHLO
	rv-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755615AbYGROop (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Jul 2008 10:44:45 -0400
Received: by rv-out-0506.google.com with SMTP id k40so344374rvb.1
        for <netdev@vger.kernel.org>; Fri, 18 Jul 2008 07:44:44 -0700 (PDT)
In-Reply-To: <20080718101624.GA7107@2ka.mipt.ru>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Evgeniy,

On Fri, Jul 18, 2008 at 12:02:26PM +0300, Pekka Enberg
(penberg@cs.helsinki.fi) wrote:
>> > Out of curiosity, why does it scream at allocation time?
>>
>> Because it's checking for use-after-free errors. The object is
>> poisoned with POISON_FREE when it's free'd and we verify the poison
>> values at allocation time.

On Fri, Jul 18, 2008 at 1:16 PM, Evgeniy Polyakov <johnpol@2ka.mipt.ru> wrote:
> Does it also scream on double free event? Just to closer guilty
> circles... 0x9c offset is somewhere at the very end of the skbuff
> structure, likely skb->users.

Yeah. See the free_debug_processing() function in mm/slub.c for
details (the on_freelist() part). However, if you look at slab_free()
you can see that in the SLUB fast-path we don't do any of these
debugging checks. So you can end up with slab corruption without a
nice error message.

                                  Pekka
