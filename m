From: Divy Le Ray <divy@chelsio.com>
Subject: Re: Who's allowed to set a skb destructor?
Date: Thu, 05 Jul 2007 04:07:07 -0700
Message-ID: <468CD0DB.8060705@chelsio.com>
References: <468B54A6.5090902@ens-lyon.org> <p733b032mec.fsf@bingen.suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Brice Goglin <Brice.Goglin@ens-lyon.org>, netdev@vger.kernel.org
To: Andi Kleen <andi@firstfloor.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([12.22.49.110]:2983 "EHLO
	stargate.chelsio.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754191AbXGELHY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Jul 2007 07:07:24 -0400
In-Reply-To: <p733b032mec.fsf@bingen.suse.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Andi Kleen wrote:
> Brice Goglin <Brice.Goglin@ens-lyon.org> writes:
>
>   
>> I am trying to understand whether I can setup a skb destructor in my
>> code (which is basically a protocol above dev_queue_xmit() and co). From
>> what I see in many parts in the current kernel code, the "protocol" (I
>> mean, the one who actually creates the skb) may setup a destructor.
>>     
>
> The socket layer generally needs it for its own accounting.
> Unless you never pass it up you can't use it.
>
>   
>> However, I also see some places where some low-level drivers might be
>> using a destructor too , without apparently checking whether an upper
>> layer already uses one. For instance, write_ofld_wr() in cxgb3/sge.c.
>>     
>
> Likely a bug. Normally that should not slip past code review.
>   

Andi,

The destructor method is set and used for skbs originating from the RDMA 
driver sitting above cxgb3.

The patch introducing this code was discussed at the time.
http://marc.info/?l=linux-netdev&m=117029329230969&w=2

Cheers,
Divy
