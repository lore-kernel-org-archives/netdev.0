From: Scott Feldman <sfeldma@gmail.com>
Subject: Re: [PATCH net v2] switchdev: don't abort hardware ipv4 fib offload
 on failure to program fib entry in hardware
Date: Sun, 17 May 2015 22:11:30 -0700
Message-ID: <CAE4R7bAE_qV2ZrbUYQeU9auythE_ZEmiSkigPm=0XZnS5v-gxQ@mail.gmail.com>
References: <1431906125-13808-1-git-send-email-roopa@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "David S. Miller" <davem@davemloft.net>,
	john fastabend <john.fastabend@gmail.com>,
	=?UTF-8?B?SmnFmcOtIFDDrXJrbw==?= <jiri@resnulli.us>,
	Netdev <netdev@vger.kernel.org>
To: Roopa Prabhu <roopa@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qg0-f46.google.com ([209.85.192.46]:34568 "EHLO
	mail-qg0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750878AbbERFLb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 May 2015 01:11:31 -0400
Received: by qgfa7 with SMTP id a7so30152867qgf.1
        for <netdev@vger.kernel.org>; Sun, 17 May 2015 22:11:31 -0700 (PDT)
In-Reply-To: <1431906125-13808-1-git-send-email-roopa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, May 17, 2015 at 4:42 PM, Roopa Prabhu <roopa@cumulusnetworks.com> wrote:
> From: Roopa Prabhu <roopa@cumulusnetworks.com>
>
> This patch removes the calls to netdev_switch_fib_ipv4_abort when
> there is an error in programming fib entry in hardware.
>
> On most systems where you can offload routes to hardware,
> doing routing in software is not an option (the cpu limitations
> make routing impossible in software).
>
> I understand that this was added to keep the first fib offload support
> simple.
>
> As discussed in the RFC patch, available options:
> a) Fail fib entry add on hardware offload failure on switch devices, and
> return appropriate error to the user by default (this patch)
> b) make the behaviour in a) conditional on a global flag/sysctl (a per fib
> entry flag will not work because by default user/routing-daemons dont care
> if they are hardware offloaded)
> c) for users/routing-daemons interested in controlling hardware
> offload behaviour there is always the per fib entry flag RTNH_F_OFFLOAD
>
> Considering the characteristics of the systems that support fib offloads,
> this patch implements a). Also making a) the default will enable easier/faster
> migration of existing routing apps to switch devices.
>
> Signed-off-by: Roopa Prabhu <roopa@cumulusnetworks.com>

Acked-by: Scott Feldman <sfeldma@gmail.com>
