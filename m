From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH net-next 3/5] netvsc: optimize receive completions
Date: Tue, 25 Jul 2017 14:07:57 -0700
Message-ID: <20170725140757.5c38ccc0@xeon-e3>
References: <20170725200422.13795-1-sthemmin@microsoft.com>
        <20170725200422.13795-4-sthemmin@microsoft.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: devel@linuxdriverproject.org, netdev@vger.kernel.org
To: kys@microsoft.com, haiyangz@microsoft.com, sthemmin@microsoft.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f53.google.com ([74.125.83.53]:36131 "EHLO
        mail-pg0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752251AbdGYVIA (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 25 Jul 2017 17:08:00 -0400
Received: by mail-pg0-f53.google.com with SMTP id 125so75040599pgi.3
        for <netdev@vger.kernel.org>; Tue, 25 Jul 2017 14:08:00 -0700 (PDT)
In-Reply-To: <20170725200422.13795-4-sthemmin@microsoft.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 25 Jul 2017 13:04:20 -0700
Stephen Hemminger <stephen@networkplumber.org> wrote:

> Optimize how receive completion ring are managed.
>    * Allocate only as many slots as needed for all buffers from host
>    * Allocate before setting up sub channel for better error detection
>    * Don't need to keep copy of initial receive section message
>    * Only needt keep the transaction id, status doesn't matter
>    * Precompute the watermark for when receive flushing is needed
>    * Replace division with conditional test
>    * Replace atomic per-device variable with per-channel check.
>    * Handle corner case where receive completion send
>      fails if ring buffer to host is full.
> 
> Signed-off-by: Stephen Hemminger <sthemmin@microsoft.com>

I probably pushed the shrinkage too far for now. Hiayang raised the
point that probably need to keep the status value. I dropped storing
it since it was always SUCCESS unless the host sent a bad packet,
or the system was out of skb's.

Will send V2 that keeps the status value for now.
