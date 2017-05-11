From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH] ip: mpls: fix printing of mpls labels
Date: Thu, 11 May 2017 11:09:41 -0700
Message-ID: <20170511110941.344a3011@xeon-e3>
References: <20170509060413.11596-1-dsahern@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, roopa@cumulusnetworks.com
To: David Ahern <dsahern@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f54.google.com ([74.125.83.54]:33858 "EHLO
        mail-pg0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932347AbdEKSJs (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 11 May 2017 14:09:48 -0400
Received: by mail-pg0-f54.google.com with SMTP id u28so18330926pgn.1
        for <netdev@vger.kernel.org>; Thu, 11 May 2017 11:09:48 -0700 (PDT)
In-Reply-To: <20170509060413.11596-1-dsahern@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon,  8 May 2017 23:04:13 -0700
David Ahern <dsahern@gmail.com> wrote:

> If the kernel returns more labels than iproute2 expects, none of
> the labels are printed and (null) is shown instead:
>     $ ip -f mpls ro ls
>     101 as to (null) via inet 172.16.2.2 dev virt12
>     201 as to 202/203 via inet6 2001:db8:2::2 dev virt12
> 
> Remove the use of MPLS_MAX_LABELS and rely on buffer length that is
> passed to mpls_ntop. With this change ip can print the label stack
> returned by the kernel up to 255 characters (limit is due to size of
> buf passed in) which amounts to 31 labels with a separator.
> 
> With this change the above is:
>     $ ip/ip -f mpls ro ls
>     101 as to 102/103/104/105/106/107/108/109/110 via inet 172.16.2.2 dev virt12
> 
> Signed-off-by: David Ahern <dsahern@gmail.com>

Much better. Applied thanks.
