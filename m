From: Kevin Groeneveld <kgroeneveld@gmail.com>
Subject: Re: [PATCH] ppp: add 64 bit stats
Date: Tue, 24 Jul 2012 22:27:03 -0400
Message-ID: <CABF+-6Wpn8yEvru1FDsaFbXYZ7tyeQqqbEU2VY8hLKvmXXFBXA@mail.gmail.com>
References: <1342988397-3077-1-git-send-email-kgroeneveld@gmail.com>
	<1343020585.2626.10054.camel@edumazet-glaptop>
	<CABF+-6WHqzXhvv9etdAqsamZirbWxWJEsnU-CQ1H8tvynCTOZA@mail.gmail.com>
	<1343059184.2626.11027.camel@edumazet-glaptop>
	<CABF+-6Vko_T2RCsk1KVouB8a+8Ms_aLEoA-Xet1nxB8bnZAxMA@mail.gmail.com>
	<1343110954.2626.11040.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vb0-f46.google.com ([209.85.212.46]:60192 "EHLO
	mail-vb0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753823Ab2GYC1E (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Jul 2012 22:27:04 -0400
Received: by vbbff1 with SMTP id ff1so189571vbb.19
        for <netdev@vger.kernel.org>; Tue, 24 Jul 2012 19:27:03 -0700 (PDT)
In-Reply-To: <1343110954.2626.11040.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jul 24, 2012 at 2:22 AM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> On Mon, 2012-07-23 at 21:53 -0400, Kevin Groeneveld wrote:
>> On Mon, Jul 23, 2012 at 11:59 AM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
>> >> Would proper synchronization in this case just be wrapping the updates
>> >> in a spin_lock/spin_unlock?
>> >
>> > Would be fine (if the proper BH safe variant is used), or you could also
>> > use atomic64_t.
>>
>> Which would you recommend, spin locks or atomic64_t?
>>
>> atomic64_t seems like it would be simpler.
>
> Simpler but a bit more expensive when two counters are changed at the
> same time.
>
> (two atomic ops instead of a single one for the spinlock)

After looking at the existing ppp code more I wonder if I would even
need to add my own spinlocks.  It seems the only spots I am updating
the 64 bit stats are already protected by either ppp->wlock or
ppp->rlock spinlocks.  If I used two separate u64_stats_sync
structures, one for tx stats and one for rx stats, wouldn't the
existing spinlocks be enough?
