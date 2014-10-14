From: David Miller <davem@davemloft.net>
Subject: Re: something is wrong in commit 971f10eca1 - tcp: better
 TCP_SKB_CB layout to reduce cache line misses
Date: Tue, 14 Oct 2014 16:47:05 -0400 (EDT)
Message-ID: <20141014.164705.1874094084240216813.davem@davemloft.net>
References: <CAHA+R7N9rNUH4aytFG3YLt8nzpERqmf34FgaWbe5R7P0AaWuZw@mail.gmail.com>
	<20141014.150300.536881166743492994.davem@davemloft.net>
	<CAFrEnehWNzmzZGV-ZGbZF=wJ1q0TjFtB1yG6Dp1yVrJmBj9B7Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: cwang@twopensource.com, kkolasa@winsoft.pl, eric.dumazet@gmail.com,
	netdev@vger.kernel.org
To: edumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:44531 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750866AbaJNUrI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Oct 2014 16:47:08 -0400
In-Reply-To: <CAFrEnehWNzmzZGV-ZGbZF=wJ1q0TjFtB1yG6Dp1yVrJmBj9B7Q@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@gmail.com>
Date: Tue, 14 Oct 2014 13:42:01 -0700

> 2014-10-14 12:03 GMT-07:00 David Miller <davem@davemloft.net>:
> 
>> From: Cong Wang <cwang@twopensource.com>
>> Date: Tue, 14 Oct 2014 11:59:25 -0700
>>
>> > On Tue, Oct 14, 2014 at 6:25 AM, Krzysztof Kolasa <kkolasa@winsoft.pl>
>> wrote:
>> >> W dniu 14.10.2014 o 02:09, Cong Wang pisze:
>> >>
>> >>> On Mon, Oct 13, 2014 at 4:59 PM, Cong Wang <cwang@twopensource.com>
>> wrote:
>> >>>>
>> >>>> Probably not related with this bug, but with regarding to the
>> >>>> offending commit, what's the point of the memmove() in tcp_v4_rcv()
>> >>>> since ip_rcv() already clears IPCB()?
>> >>>
>> >>> Oh, ip options are actually saved in ip_rcv_finish()... Hmm, looks
>> scary
>> >>> to play with variable-length array with memmove()....
>> >>>
>> >> On my other old laptop with 32bit kernel next and graphics card Intel
>> 945GM
>> >> just after the revert commit working OK,
>> >> before, after login to gnome shell in some seconds decorations disappear
>> >>
>> >> 32 bit Ubuntu 12.04.5 LTS, gnome shell, kernel source next 14-10-2014
>> >>
>> >> Can anyone confirm this ?
>> >>
>> >
>> > Sorry, believe it or not, for me it is hard to find a 32bit machine even
>> VM. :)
>> >
>> > Could the attached patch by any chance help? I noticed cookie_v4_check()
>> > still uses IPCB() instead of TCPCB() at TCP layer.
>>
>> Eric, please review.
>>
> 
> For an unknown reason I do not see this patch on my eric.dumazet@gmail.com
> 
> It seems my migration to Trusty was not a good move :(
> 
> Patch looks good, but seems a net-next candidate to me.

I thought it is a potential fix for this corruption report?
