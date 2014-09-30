From: Cong Wang <cwang@twopensource.com>
Subject: Re: [PATCH iproute2] iplink: do not require assigning negative
 ifindex at link creation
Date: Tue, 30 Sep 2014 11:26:04 -0700
Message-ID: <CAHA+R7NSDU3PeBeJu0jnsZtdmQE=P6zUBH9jram=3gsVZYzcmw@mail.gmail.com>
References: <87wq8l5ppn.wl%atzm@stratosphere.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>,
	Cong Wang <xiyou.wangcong@gmail.com>,
	Stephen Hemminger <stephen@networkplumber.org>
To: Atzm Watanabe <atzm@stratosphere.co.jp>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f173.google.com ([209.85.212.173]:38395 "EHLO
	mail-wi0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751074AbaI3S0G (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 30 Sep 2014 14:26:06 -0400
Received: by mail-wi0-f173.google.com with SMTP id bs8so5088770wib.6
        for <netdev@vger.kernel.org>; Tue, 30 Sep 2014 11:26:04 -0700 (PDT)
In-Reply-To: <87wq8l5ppn.wl%atzm@stratosphere.co.jp>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Sep 30, 2014 at 4:10 AM, Atzm Watanabe <atzm@stratosphere.co.jp> wrote:
> Since commit 3c682146aeff, iplink requires assigning negative
> ifindex (-1) to the kernel when creating interface without
> specifying index.
>
> Cc: Cong Wang <xiyou.wangcong@gmail.com>
> Signed-off-by: Atzm Watanabe <atzm@stratosphere.co.jp>
> ---
>  ip/iplink.c | 5 ++++-
>  1 file changed, 4 insertions(+), 1 deletion(-)
>
> diff --git a/ip/iplink.c b/ip/iplink.c
> index cb9c870..de6b2a9 100644
> --- a/ip/iplink.c
> +++ b/ip/iplink.c
> @@ -689,7 +689,10 @@ static int iplink_modify(int cmd, unsigned int flags, int argc, char **argv)
>                         addattr_l(&req.n, sizeof(req), IFLA_LINK, &ifindex, 4);
>                 }
>
> -               req.i.ifi_index = index;
> +               if (index <= 0)
> +                       req.i.ifi_index = 0;
> +               else
> +                       req.i.ifi_index = index;

How about checking if it is -1?

if (index == -1)
   req.i.ifi_index = 0;
else
   req.i.ifi_index = index;


Thanks for fixing it.
