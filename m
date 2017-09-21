From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH iproute2 v3] ip: ip_print: if no json obj is initialized
 default fp is stdout
Date: Wed, 20 Sep 2017 19:22:09 -0700
Message-ID: <20170920192209.76b03142@xeon-e3>
References: <20170921012356.46451-1-julien@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, roopa@cumulusnetworks.com,
        nikolay@cumulusnetworks.com, dsa@cumulusnetworks.com
To: Julien Fortin <julien@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f54.google.com ([74.125.83.54]:45052 "EHLO
        mail-pg0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751095AbdIUCWM (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 20 Sep 2017 22:22:12 -0400
Received: by mail-pg0-f54.google.com with SMTP id j16so2748174pga.1
        for <netdev@vger.kernel.org>; Wed, 20 Sep 2017 19:22:12 -0700 (PDT)
In-Reply-To: <20170921012356.46451-1-julien@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 20 Sep 2017 18:23:56 -0700
Julien Fortin <julien@cumulusnetworks.com> wrote:

> From: Julien Fortin <julien@cumulusnetworks.com>
> 
> The ip monitor didn't call `new_json_obj` (even for in non json context),
> so the static FILE* _fp variable wasn't initialized, thus raising a
> SIGSEGV in ipaddress.c. This patch should fix this issue for good, new
> paths won't have to call `new_json_obj`.
> 
> $ ip -t mon label link
>         fmt=fmt@entry=0x45460d "%d: ", value=<optimized out>) at ip_print.c:132
>         #3  0x000000000040ccd2 in print_int (value=<optimized out>, fmt=0x45460d "%d: ", key=0x4545fc "ifindex", t=PRINT_ANY) at ip_common.h:189
>         #4  print_linkinfo (who=<optimized out>, n=0x7fffffffa380, arg=0x7ffff77a82a0 <_IO_2_1_stdout_>) at ipaddress.c:1107
>         #5  0x0000000000422e13 in accept_msg (who=0x7fffffff8320, ctrl=0x7fffffff8310, n=0x7fffffffa380, arg=0x7ffff77a82a0 <_IO_2_1_stdout_>) at ipmonitor.c:89
>         #6  0x000000000044c58f in rtnl_listen (rtnl=0x672160 <rth>, handler=handler@entry=0x422c70 <accept_msg>, jarg=0x7ffff77a82a0 <_IO_2_1_stdout_>)
>             at libnetlink.c:761
>             #7  0x00000000004233db in do_ipmonitor (argc=<optimized out>, argv=0x7fffffffe5a0) at ipmonitor.c:310
>             #8  0x0000000000408f74 in do_cmd (argv0=0x7fffffffe7f5 "mon", argc=3, argv=0x7fffffffe588) at ip.c:116
>             #9  0x0000000000408a94 in main (argc=4, argv=0x7fffffffe580) at ip.c:311
>     
> Traceback can be seen when running the following command in a new terminal.
> $ ip link add dev br0 type bridge
> 
> Fixes: 6377572f ("ip: ip_print: add new API to print JSON or regular format output")
> Reported-by: David Ahern <dsa@cumulusnetworks.com>
> Reviewed-by: David Ahern <dsa@cumulusnetworks.com>
> Signed-off-by: Julien Fortin <julien@cumulusnetworks.com>

This is getting way more complex than it needs to be.

new_json_obj is always called with fp == stdout.
There is no reason to have the _fp at all!
Please rework new_json_obj to take only one argument.
