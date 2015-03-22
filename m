From: Mahesh Bandewar <maheshb@google.com>
Subject: Re: [PATCH net-next v2 0/4] bonding work-queues, try_rtnl() & notifications
Date: Sat, 21 Mar 2015 19:04:16 -0700
Message-ID: <CAF2d9jhng-A=sYzhy=KX0xMVFDj+jF9W7mkkZYyaLncvgv=ZTQ@mail.gmail.com>
References: <1426916355-18289-1-git-send-email-maheshb@google.com> <20150321.181700.1162404019090592599.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: j.vosburgh@gmail.com, andy@greyhouse.net, vfalico@gmail.com,
	nikolay@redhat.com,
	=?UTF-8?Q?Maciej_=C5=BBenczykowski?= <maze@google.com>,
	linux-netdev <netdev@vger.kernel.org>,
	Eric Dumazet <edumazet@google.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f49.google.com ([209.85.218.49]:33737 "EHLO
	mail-oi0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751463AbbCVCEh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 21 Mar 2015 22:04:37 -0400
Received: by oifl3 with SMTP id l3so87613736oif.0
        for <netdev@vger.kernel.org>; Sat, 21 Mar 2015 19:04:36 -0700 (PDT)
In-Reply-To: <20150321.181700.1162404019090592599.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Mar 21, 2015 at 3:17 PM, David Miller <davem@davemloft.net> wrote:
>
> From: Mahesh Bandewar <maheshb@google.com>
> Date: Fri, 20 Mar 2015 22:39:15 -0700
>
> > This patch series tries to address the issue discovered in various work-
> > queues and the way these handlers deal with the RTNL. Especially for
> > notification handling. If RTNL can not be acquired, these handlers ignore
> > sending notifications and just re-arm the timer. This could be very
> > problematic if the re-arm timer has larger value (e.g. in minutes).
>
> I already made it very clear how I want this kind of problem solved.
>
> Make the person holding the RTNL semaphore do the notification work
> for you.
>
> All of this deferral stuff is error prone and sloppy.

I think you missed my earlier reply to your message. In summary, the
notification deferral is 1ms which should not cause any trashing; more
over with that suggested approach the rtnl-owner will have to do your
job and will be subjected to the latencies which may be undesirable.

OTOH this patch series is not adding any new deferral work, but just
making it bug-free.

Thanks,
--mahesh..
