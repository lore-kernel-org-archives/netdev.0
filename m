From: Scott Feldman <sfeldma@gmail.com>
Subject: Re: [PATCH net-next 3/3 v3] iproute2: add support to print 'linkdown'
 nexthop flag
Date: Wed, 10 Jun 2015 20:02:26 -0700
Message-ID: <CAE4R7bDAN-2bsmDUApKjej6fhtd9XGB7VfywH1mkrZ3r-kiM-A@mail.gmail.com>
References: <1433990233-958-1-git-send-email-gospo@cumulusnetworks.com> <1433990233-958-4-git-send-email-gospo@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Netdev <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>, ddutt@cumulusnetworks.com,
	Alexander Duyck <alexander.duyck@gmail.com>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	"stephen@networkplumber.org" <stephen@networkplumber.org>
To: Andy Gospodarek <gospo@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qg0-f43.google.com ([209.85.192.43]:33505 "EHLO
	mail-qg0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751606AbbFKDCr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Jun 2015 23:02:47 -0400
Received: by qgfa66 with SMTP id a66so21968624qgf.0
        for <netdev@vger.kernel.org>; Wed, 10 Jun 2015 20:02:47 -0700 (PDT)
In-Reply-To: <1433990233-958-4-git-send-email-gospo@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jun 10, 2015 at 7:37 PM, Andy Gospodarek
<gospo@cumulusnetworks.com> wrote:
> Signed-off-by: Andy Gospodaerk <gospo@cumulusnetworks.com>
> Signed-off-by: Dinesh Dutt <ddutt@cumulusnetworks.com>
>
> ---
>  ip/iproute.c | 4 ++++
>  1 file changed, 4 insertions(+)
>
> diff --git a/ip/iproute.c b/ip/iproute.c
> index 3795baf..3369c49 100644
> --- a/ip/iproute.c
> +++ b/ip/iproute.c
> @@ -451,6 +451,8 @@ int print_route(const struct sockaddr_nl *who, struct nlmsghdr *n, void *arg)
>                 fprintf(fp, "offload ");
>         if (r->rtm_flags & RTM_F_NOTIFY)
>                 fprintf(fp, "notify ");
> +       if (r->rtm_flags & RTNH_F_LINKDOWN)
> +               fprintf(fp, "linkdown ");

This seems confusing for ECMP case where only some nexthop devs are
RTNH_F_LINKDOWN?   Why mark entire route "linkdown" when it still has
viable nexthop devs for ECMP?


>         if (tb[RTA_MARK]) {
>                 unsigned int mark = *(unsigned int*)RTA_DATA(tb[RTA_MARK]);
>                 if (mark) {
> @@ -670,6 +672,8 @@ int print_route(const struct sockaddr_nl *who, struct nlmsghdr *n, void *arg)
>                                 fprintf(fp, " onlink");
>                         if (nh->rtnh_flags & RTNH_F_PERVASIVE)
>                                 fprintf(fp, " pervasive");
> +                       if (nh->rtnh_flags & RTNH_F_LINKDOWN)
> +                               fprintf(fp, " linkdown");
>                         len -= NLMSG_ALIGN(nh->rtnh_len);
>                         nh = RTNH_NEXT(nh);
>                 }
> --
> 1.9.3
>
