From: Dmitry Popov <dp@highloadlab.com>
Subject: Re: [PATCH 5/5] tcp: ipv4 listen state scaled
Date: Wed, 27 Oct 2010 20:44:30 +0400
Message-ID: <AANLkTikqr7R32verQVSf1uKM507Z6W-o_J7FRNjXKvKP@mail.gmail.com>
References: <AANLkTikRsOevLBHn0xb0S_YvfPMWpAdw373bxQUc+xbV@mail.gmail.com>
	<20101027150434.GA13121@ms2.inr.ac.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: netdev@vger.kernel.org
To: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gx0-f174.google.com ([209.85.161.174]:56414 "EHLO
	mail-gx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751023Ab0J0Qog (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Oct 2010 12:44:36 -0400
Received: by gxk23 with SMTP id 23so542681gxk.19
        for <netdev@vger.kernel.org>; Wed, 27 Oct 2010 09:44:35 -0700 (PDT)
In-Reply-To: <20101027150434.GA13121@ms2.inr.ac.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Oct 27, 2010 at 7:04 PM, Alexey Kuznetsov <kuznet@ms2.inr.ac.ru> wrote:
> Hello!
>
> It looks like there is at least one hole here.
>
> You take lock, check syn table and drop lock in tcp_v4_hnd_req().
> Then you immediately enter tcp_v4_conn_request() and grab lock again.
> Oops, in the tiny hole while lock was dropped the request can be already
> created (even funnier, the whole socket can be already created and even accepted).
> So, if you drop lock, you have to restart the whole tcp_v4_rcv_listen()
> (which seems to be impossible without additional tricks)
>
> Alexey
>

Hello, Alexey!

Yes, it may happen, but I don't see any problem. On 2 same SYN-packets
we will add 2 requests to syn table. Yes, it's not so good, but
nothing criminal, no?

Regards,
Dmitry.
