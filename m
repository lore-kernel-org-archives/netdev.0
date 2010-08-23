From: Akinobu Mita <akinobu.mita@gmail.com>
Subject: Re: [PATCH] mlx4: use bitmap library
Date: Mon, 23 Aug 2010 13:21:55 +0900
Message-ID: <AANLkTinNf1vsQqR34Qeh4jO-xt7m1wYWGC9-dA6mU+__@mail.gmail.com>
References: <1282382688-5786-1-git-send-email-akinobu.mita@gmail.com>
	<20100822.205231.116364886.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: netdev@vger.kernel.org, rolandd@cisco.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qw0-f46.google.com ([209.85.216.46]:54720 "EHLO
	mail-qw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751577Ab0HWEV4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Aug 2010 00:21:56 -0400
Received: by qwh6 with SMTP id 6so4767488qwh.19
        for <netdev@vger.kernel.org>; Sun, 22 Aug 2010 21:21:55 -0700 (PDT)
In-Reply-To: <20100822.205231.116364886.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2010/8/23 David Miller <davem@davemloft.net>:
> From: Akinobu Mita <akinobu.mita@gmail.com>
> Date: Sat, 21 Aug 2010 18:24:48 +0900
>
>> Use bitmap_set() and bitmap_clear()
>>
>> Signed-off-by: Akinobu Mita <akinobu.mita@gmail.com>
>
> Unlike loops calling set_bit() and clear_bit(), bitmap_set() and
> bitmap_clear() are not atomic.
>
> Are you sure this is ok here?
>

I think this ok. Because the bitmap region is searched by
bitmap_find_next_zero_area() which cannot be atomic and
setting and clearing the bitmap region is protected by bitmap->lock
(except for initialization of the bitmap in mlx4_bitmap_init).

This change should be done when I submitted commit
43ff8b60853793fb0155b3e465739d2170c3aa2f ("mlx4: use
bitmap_find_next_zero_area")
at the same time.

I'll recheck this is ok and update the commit message for this change,
then resubmit the patch.
