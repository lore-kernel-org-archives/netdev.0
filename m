From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH iproute2/master] tc actions: store and dump correct
 length of user cookies
Date: Tue, 5 Sep 2017 09:27:52 -0700
Message-ID: <20170905092752.6d0e9d4e@xeon-e3>
References: <1504609584-20026-1-git-send-email-simon.horman@netronome.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, oss-drivers@netronome.com,
        Jamal Hadi Salim <jhs@mojatatu.com>
To: Simon Horman <simon.horman@netronome.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f49.google.com ([74.125.83.49]:33352 "EHLO
        mail-pg0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751896AbdIEQ1z (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 5 Sep 2017 12:27:55 -0400
Received: by mail-pg0-f49.google.com with SMTP id t3so10400188pgt.0
        for <netdev@vger.kernel.org>; Tue, 05 Sep 2017 09:27:55 -0700 (PDT)
In-Reply-To: <1504609584-20026-1-git-send-email-simon.horman@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue,  5 Sep 2017 13:06:24 +0200
Simon Horman <simon.horman@netronome.com> wrote:

> Correct two errors which cancel each other out:
> * Do not send twice the length of the actual provided by the user to the kernel
> * Do not dump half the length of the cookie provided by the kernel
> 
> As the cookie is now stored in the kernel at its correct length rather
> than double the that length cookies of up to the maximum size of 16 bytes
> may now be stored rather than a maximum of half that length.
> 
> Output of dump is the same before and after this change,
> but the data stored in the kernel is now exactly the cookie
> rather than the cookie + as many trailing zeros.
> 
> Before:
>  # tc filter add dev eth0 protocol ip parent ffff: \
>        flower ip_proto udp action drop \
>        cookie 0123456789abcdef0123456789abcdef
>  RTNETLINK answers: Invalid argument
> 
> After:
>  # tc filter add dev eth0 protocol ip parent ffff: \
>        flower ip_proto udp action drop \
>        cookie 0123456789abcdef0123456789abcdef
>  # tc filter show dev eth0 ingress
>    eth_type ipv4
>    ip_proto udp
>    not_in_hw
> 	 action order 1: gact action drop
> 	  random type none pass val 0
> 	  index 1 ref 1 bind 1 installed 1 sec used 1 sec
> 	 Action statistics:
> 	 Sent 0 bytes 0 pkt (dropped 0, overlimits 0 requeues 0)
> 	 backlog 0b 0p requeues 0
> 	 cookie len 16 0123456789abcdef0123456789abcdef
> 
> Fixes: fd8b3d2c1b9b ("actions: Add support for user cookies")
> Cc: Jamal Hadi Salim <jhs@mojatatu.com>
> Signed-off-by: Simon Horman <simon.horman@netronome.com>

Applied thanks
