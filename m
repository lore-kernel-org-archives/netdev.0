From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
Subject: Re: [PATCH net] bridge: start hello_timer when enabling KERNEL_STP in
 br_stp_start
Date: Fri, 19 May 2017 17:45:38 +0300
Message-ID: <cf69d5e5-1acf-2ed4-b6cc-fdb1236e7a66@cumulusnetworks.com>
References: <6e78bfea3969ca1a937b37e28e796a3047b82615.1495203629.git.lucien.xin@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, cera@cera.cz
To: Xin Long <lucien.xin@gmail.com>,
        network dev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f181.google.com ([209.85.128.181]:34549 "EHLO
        mail-wr0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751049AbdESOp4 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 19 May 2017 10:45:56 -0400
Received: by mail-wr0-f181.google.com with SMTP id l9so18627054wre.1
        for <netdev@vger.kernel.org>; Fri, 19 May 2017 07:45:55 -0700 (PDT)
In-Reply-To: <6e78bfea3969ca1a937b37e28e796a3047b82615.1495203629.git.lucien.xin@gmail.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 5/19/17 5:20 PM, Xin Long wrote:
> Since commit 76b91c32dd86 ("bridge: stp: when using userspace stp stop
> kernel hello and hold timers"), bridge would not start hello_timer if
> stp_enabled is not KERNEL_STP when br_dev_open.
> 
> The problem is even if users set stp_enabled with KERNEL_STP later,
> the timer will still not be started. It causes that KERNEL_STP can
> not really work. Users have to re-ifup the bridge to avoid this.
> 
> This patch is to fix it by starting br->hello_timer when enabling
> KERNEL_STP in br_stp_start.
> 
> As an improvement, it's also to start hello_timer again only when
> br->stp_enabled is KERNEL_STP in br_hello_timer_expired, there is
> no reason to start the timer again when it's NO_STP.
> 
> Fixes: 76b91c32dd86 ("bridge: stp: when using userspace stp stop kernel hello and hold timers")
> Reported-by: Haidong Li <haili@redhat.com>
> Signed-off-by: Xin Long <lucien.xin@gmail.com>
> ---
>   net/bridge/br_stp_if.c    | 1 +
>   net/bridge/br_stp_timer.c | 2 +-
>   2 files changed, 2 insertions(+), 1 deletion(-)
> 

This doesn't make much sense to me, how do you change from USER_STP to
KERNEL_STP without first going through NO_STP ?

If you go through NO_STP then all will be fine because br_stp_stop will restart
the timers if the previous val was USER_STP.
