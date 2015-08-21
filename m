From: Akshat Kakkar <akshat.1984@gmail.com>
Subject: Re: Bug in tc of iproute2 ? Deleting single filter, deletes all the
 filters (apart from hashtable 800::) ...
Date: Fri, 21 Aug 2015 12:38:13 +0530
Message-ID: <CAA5aLPiBCGUUoQD+7U-j+EW_uiUOvm1TAD8nd481Fuk7RnnhEw@mail.gmail.com>
References: <CAA5aLPhvdcYS4R_Ke0-JOgZTgiL0XpaQYwBopjPD1rvahyVonw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f52.google.com ([209.85.218.52]:32965 "EHLO
	mail-oi0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750798AbbHUHIO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Aug 2015 03:08:14 -0400
Received: by oio137 with SMTP id 137so37095160oio.0
        for <netdev@vger.kernel.org>; Fri, 21 Aug 2015 00:08:13 -0700 (PDT)
In-Reply-To: <CAA5aLPhvdcYS4R_Ke0-JOgZTgiL0XpaQYwBopjPD1rvahyVonw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I actually posted this on lartc first. But then it was suggested to
post it over here as you guys might be able to guide better.

Please help ...

On Fri, Aug 21, 2015 at 10:38 AM, Akshat Kakkar <akshat.1984@gmail.com> wrote:
> When I am trying to  delete a single tc filter, it deleting all the
> filters with the same priority/preference. i.e. it is ignoring the
> handle specified.
>
> But, When I am deleting in hashtable 800: it is deleting only the
> specified filter.
>
> For example, following set of commands  create a hashtable 15: and add
> 2 filters to it.
>
> tc filter add dev eth0 parent 1:0 prio 5 handle 15: protocol ip u32 divisor 256
> tc filter add dev eth0 protocol ip parent 1: prio 5 handle 15:2:2 u32
> ht 15:2: match ip src 10.0.0.2 flowid 1:10
> tc filter add dev eth0 protocol ip parent 1: prio 5 handle 15:2:3 u32
> ht 15:2: match ip src 10.0.0.3 flowid 1:10
>
> Now following command DELETES ALL THE FILTERS, though it should only
> delete FILTER 15:2:3 !
> tc filter del dev eth0 protocol ip parent 1: prio 5 handle 15:2:3 u32
>
> O/p of tc filter show eth0 is this case is blank. As all filters are deleted.
>
>
> However, similar commands when executed for hashtable 800: is deleting
> only the specified filter
> tc filter add dev eth0 protocol ip parent 1: prio 5 handle 800:0:2 u32
> ht 800:0: match ip src 10.0.0.2 flowid 1:10
> tc filter add dev eth0 protocol ip parent 1: prio 5 handle 800:0:3 u32
> ht 800:0: match ip src 10.0.0.3 flowid 1:10
>
> tc filter del dev eth0 protocol ip parent 1: prio 5 handle 800:0:2 u32
>
> Above mentioned command only deletes single filter.
> O/p of tc filter show eth0 is 2nd case is
>
> filter parent 1: protocol ip pref 5 u32
> filter parent 1: protocol ip pref 5 u32 fh 800: ht divisor 1
> filter parent 1: protocol ip pref 5 u32 fh 800::3 order 3 key ht 800
> bkt 0 flowid 1:10
>   match 0a000003/ffffffff at 12
