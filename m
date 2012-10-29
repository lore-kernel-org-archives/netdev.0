From: Javier Domingo <javierdo1@gmail.com>
Subject: Re: Information about napi_struct and net_device
Date: Mon, 29 Oct 2012 18:40:44 +0100
Message-ID: <CALZVapmbFCh4+2FmKxi_RkhNf9m50eAC2q5Tk2etx9C_g7TjcQ@mail.gmail.com>
References: <CALZVap=ybdWdK22LHsfSRu+TVCJnvL95KeChtCdX8DE-C=1gAg@mail.gmail.com>
 <1351478461.4450.8.camel@deadeye.wl.decadent.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qa0-f46.google.com ([209.85.216.46]:58083 "EHLO
	mail-qa0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757271Ab2J2RlG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 29 Oct 2012 13:41:06 -0400
Received: by mail-qa0-f46.google.com with SMTP id c26so1639768qad.19
        for <netdev@vger.kernel.org>; Mon, 29 Oct 2012 10:41:04 -0700 (PDT)
In-Reply-To: <1351478461.4450.8.camel@deadeye.wl.decadent.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I finally found the problem, and I think also the answer.

I am modifying netif_receive_skb(), putting there my own queue. So the
only problem I face now is how may I disable the main netpoll through.

Looking at dev.c file, and knowing that there must be some way the
solution I was looking for, I discovered enqueue_to_backlog function,
that does what I want to do, from a packet, after processing it, be
able to take the napi_struct that was responsible from it.

I if you could tell me if using the method to obtain the napi_struct
from the net_device pointer used in enqueue_to_backlog is ok, it would
be great,

Any way I will continue doing experiments and reading,

Thanks a lot for your help and attention, and for whoever did [1]

Javier Domingo

[1]: http://www.linuxfoundation.org/images/1/1c/Network_data_flow_through_kernel.png

2012/10/29 Ben Hutchings <bhutchings@solarflare.com>:
> On Sat, 2012-10-27 at 18:18 +0200, Javier Domingo wrote:
>> Hello,
>>
>> I am updating a kernel patch from 2.6.23-rc7 to v3.6, using git
>> facilities, and I have found that there have been lots of changes in
>> networking. Now the drivers are all by vendor, and more important,
>> net_device is not used always, as napi_struct took its place.
>>
>> I have asked in #kernel but no one answered me, so I subscribed here.
>> Is there any place I can read about how is it now designed the use of
>> napi_struct and net_device? I have found a presentation[1] about how
>> networking was changing etc, and I wondered if there is anything more
>> precise about how it is actually implemented.
>>
>> I understand a little why napi_struct, but don't really know much
>> about the change,
>>
>> Hope someone can help me,
>
> The initial change to napi_struct is explained in
> <http://lwn.net/Articles/244640/>.
>
> Since then there have been further changes:
>
> - netif_napi_del() has been added.  You must call it to clean up NAPI
> contexts before freeing the associated net device(s).
>
> - Instead of netif_rx_schedule(), netif_rx_complete(), etc. you must use
> napi_schedule(), napi_complete() etc. which just take a napi_struct
> pointer.
>
> Ben.
>
> --
> Ben Hutchings, Staff Engineer, Solarflare
> Not speaking for my employer; that's the marketing department's job.
> They asked us to note that Solarflare product names are trademarked.
>
