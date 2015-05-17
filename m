From: roopa <roopa@cumulusnetworks.com>
Subject: Re: [PATCH net v2] switchdev: don't abort hardware ipv4 fib offload
 on failure to program fib entry in hardware
Date: Sun, 17 May 2015 16:41:58 -0700
Message-ID: <55592746.6020902@cumulusnetworks.com>
References: <1431834402-4031-1-git-send-email-roopa@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: davem@davemloft.net, sfeldma@gmail.com, john.fastabend@gmail.com,
	jiri@resnulli.us
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f181.google.com ([209.85.192.181]:36022 "EHLO
	mail-pd0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750770AbbEQXmA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 17 May 2015 19:42:00 -0400
Received: by pdfh10 with SMTP id h10so122993773pdf.3
        for <netdev@vger.kernel.org>; Sun, 17 May 2015 16:42:00 -0700 (PDT)
In-Reply-To: <1431834402-4031-1-git-send-email-roopa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 5/16/15, 8:46 PM, Roopa Prabhu wrote:
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
> ---
> RFC to v1:
>    - rebase to net
>    - remove fib_offload_disabled flag and all associated code as suggested by
>      scott feldman
>
> (This patch is currently against net. If there is any reason to move it to
> net-next, I can respin)
>
>
pls ignore, i will be resending v2 with missing switchdev.h cleanups.
