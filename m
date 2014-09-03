From: Vadim Kochan <vadim4j@gmail.com>
Subject: Re: iproute2 util: Change signature of rtnl dump filters to use
 struct params
Date: Wed, 3 Sep 2014 10:32:47 +0300
Message-ID: <CAMw6YJL46LTiKC_mVSNGxqmXOfhwvEFFrLpOPLZHgrYEep5T2w@mail.gmail.com>
References: <CAMw6YJJq1MP+r6=8KrhBi9bPUS8E1JJjb3qOjbjVf4Ano0AVsA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qc0-f173.google.com ([209.85.216.173]:38000 "EHLO
	mail-qc0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753283AbaICHcs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Sep 2014 03:32:48 -0400
Received: by mail-qc0-f173.google.com with SMTP id w7so8150288qcr.18
        for <netdev@vger.kernel.org>; Wed, 03 Sep 2014 00:32:47 -0700 (PDT)
In-Reply-To: <CAMw6YJJq1MP+r6=8KrhBi9bPUS8E1JJjb3qOjbjVf4Ano0AVsA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Sorry, this it not patch for probably applying, it was get into
patchwork queue after I copy pasted
here the diff, this is only for discussing.

Regards,

On Wed, Sep 3, 2014 at 2:46 AM, Vadim Kochan <vadim4j@gmail.com> wrote:
> Hi all,
>
> I am thinking about to make some refactoring and change the signature
> of all rtnl dump filters to form:
>
> diff --git a/include/libnetlink.h b/include/libnetlink.h
> index fe7d5d3..9514e67 100644
> --- a/include/libnetlink.h
> +++ b/include/libnetlink.h
> @@ -39,8 +39,14 @@ extern int rtnl_dump_request(struct rtnl_handle
> *rth, int type, void *req,
>                              int len)
>         __attribute__((warn_unused_result));
>
> -typedef int (*rtnl_filter_t)(const struct sockaddr_nl *,
> -                            struct nlmsghdr *n, void *);
> +struct nl_param
> +{
> +       struct sockaddr_nl *who;
> +       struct nlmsghdr *n;
> +       void *arg;
> +};
> +
> +typedef int (*rtnl_filter_t)(struct nl_param *p);
>
>  struct rtnl_dump_filter_arg
>  {
>
> What do you think?
>
> Regards,
