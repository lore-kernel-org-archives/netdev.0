From: Simon Horman <simon.horman@netronome.com>
Subject: Re: [PATCH] ip: mpls: fix printing of mpls labels
Date: Wed, 10 May 2017 12:02:52 +0200
Message-ID: <20170510100250.GA32206@vergenet.net>
References: <20170509060413.11596-1-dsahern@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: stephen@networkplumber.org, netdev@vger.kernel.org,
        roopa@cumulusnetworks.com
To: David Ahern <dsahern@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f181.google.com ([209.85.220.181]:36301 "EHLO
        mail-qk0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751936AbdEJKCz (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 10 May 2017 06:02:55 -0400
Received: by mail-qk0-f181.google.com with SMTP id u75so23467293qka.3
        for <netdev@vger.kernel.org>; Wed, 10 May 2017 03:02:55 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20170509060413.11596-1-dsahern@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, May 08, 2017 at 11:04:13PM -0700, David Ahern wrote:
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

Reviewed-by: Simon Horman <simon.horman@netronome.com>
