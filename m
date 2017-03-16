From: Jakub Sitnicki <jkbs@redhat.com>
Subject: Re: [PATCH] [PATCH net] net: Do not hold the reference for the same sk_rx_dst.
Date: Thu, 16 Mar 2017 11:01:12 +0100
Message-ID: <87h92tv8uv.fsf@redhat.com>
References: <1489651711-4105-1-git-send-email-kaiwen.xu@hulu.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Kevin Xu <kaiwen.xu@hulu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f43.google.com ([74.125.82.43]:33828 "EHLO
        mail-wm0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751141AbdCPKB1 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 16 Mar 2017 06:01:27 -0400
Received: by mail-wm0-f43.google.com with SMTP id 196so2406538wmm.1
        for <netdev@vger.kernel.org>; Thu, 16 Mar 2017 03:01:16 -0700 (PDT)
In-reply-to: <1489651711-4105-1-git-send-email-kaiwen.xu@hulu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Mar 16, 2017 at 08:08 AM GMT, Kevin Xu wrote:
> In some rare cases, inet_sk_rx_dst_set() may be called multiple times
> on the same dst, causing reference count leakage. Eventually, it
> prevents net_device to be destroyed. The bug then manifested as
>
> unregister_netdevice: waiting for lo to become free. Usage count = 1
>
> in the kernel log, preventing new network namespace creation.
>
> The patch works around the issue by checking whether the socket already
> has the same dst set.
>
> Signed-off-by: Kevin Xu <kaiwen.xu@hulu.com>
> ---

FWIW, with this patch applied I'm still sometimes seeing:

[  125.928095] unregister_netdevice: waiting for lo to become free. Usage count = 1

-Jakub
