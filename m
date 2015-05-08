From: Jesse Gross <jesse@nicira.com>
Subject: Re: [PATCH] iproute2: GENEVE support
Date: Fri, 8 May 2015 16:27:56 -0700
Message-ID: <CAEP_g=_-3K7O3MA=nCBjO7PZUGAj0HQd8=YchQ89jq-U3mUwtg@mail.gmail.com>
References: <1431105657-25492-1-git-send-email-linville@tuxdriver.com> <1431106028-5643-1-git-send-email-linville@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	Andy Zhou <azhou@nicira.com>,
	Stephen Hemminger <stephen@networkplumber.org>,
	Alexander Duyck <alexander.h.duyck@redhat.com>
To: "John W. Linville" <linville@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog123.obsmtp.com ([74.125.149.149]:60583 "HELO
	na3sys009aog123.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1751307AbbEHX2R (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 May 2015 19:28:17 -0400
Received: by mail-yh0-f48.google.com with SMTP id b70so23442070yhc.0
        for <netdev@vger.kernel.org>; Fri, 08 May 2015 16:28:16 -0700 (PDT)
In-Reply-To: <1431106028-5643-1-git-send-email-linville@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, May 8, 2015 at 10:27 AM, John W. Linville
<linville@tuxdriver.com> wrote:
> diff --git a/ip/iplink_geneve.c b/ip/iplink_geneve.c
> new file mode 100644
> index 000000000000..74703e1ee156
> --- /dev/null
> +++ b/ip/iplink_geneve.c
> +static int geneve_parse_opt(struct link_util *lu, int argc, char **argv,
> +                         struct nlmsghdr *n)
> +{
[...]
> +               } else if (!matches(*argv, "remote")) {
> +                       NEXT_ARG();
> +                       if (!inet_get_addr(*argv, &daddr, &daddr6)) {
> +                               fprintf(stderr, "Invalid address \"%s\"\n", *argv);
> +                               return -1;
> +                       }
> +                       if (IN_MULTICAST(ntohl(daddr)))
> +                               invarg("invalid remote address", *argv);

We should probably validate the no multicast check in the kernel as
well since it won't do the right thing anyways.

[...]
> +       if (!daddr) {
> +               fprintf(stderr, "geneve: remove link partner not specified\n");
> +               return -1;
> +       }
> +       if (memcmp(&daddr6, &in6addr_any, sizeof(daddr6)) != 0) {
> +               fprintf(stderr, "geneve: remove link over IPv6 not supported\n");
> +               return -1;
> +       }

Two typos in the above strings - "remove" instead of "remote".
