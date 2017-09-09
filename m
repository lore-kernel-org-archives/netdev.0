From: Roopa Prabhu <roopa@cumulusnetworks.com>
Subject: Re: [PATCH iproute2 3/3] bridge: request vlans along with link information
Date: Sat, 9 Sep 2017 09:24:31 -0700
Message-ID: <CAJieiUhT75fM3LuhNW32QkbJA9TO5dHwb_G-aRD2H70jF-FG2A@mail.gmail.com>
References: <1504907543-14394-1-git-send-email-mrv@mojatatu.com> <1504907543-14394-4-git-send-email-mrv@mojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: "stephen@networkplumber.org" <stephen@networkplumber.org>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        Jamal Hadi Salim <jhs@mojatatu.com>
To: Roman Mashak <mrv@mojatatu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f49.google.com ([209.85.218.49]:34070 "EHLO
        mail-oi0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1757555AbdIIQYc (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 9 Sep 2017 12:24:32 -0400
Received: by mail-oi0-f49.google.com with SMTP id l74so24187348oih.1
        for <netdev@vger.kernel.org>; Sat, 09 Sep 2017 09:24:32 -0700 (PDT)
In-Reply-To: <1504907543-14394-4-git-send-email-mrv@mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Sep 8, 2017 at 2:52 PM, Roman Mashak <mrv@mojatatu.com> wrote:
> Signed-off-by: Roman Mashak <mrv@mojatatu.com>
> ---
>  bridge/link.c | 16 +++++++++++++---
>  1 file changed, 13 insertions(+), 3 deletions(-)
>
> diff --git a/bridge/link.c b/bridge/link.c
> index 60200f1..9e4206f 100644
> --- a/bridge/link.c
> +++ b/bridge/link.c
> @@ -461,9 +461,19 @@ static int brlink_show(int argc, char **argv)
>                 }
>         }
>
> -       if (rtnl_wilddump_request(&rth, PF_BRIDGE, RTM_GETLINK) < 0) {
> -               perror("Cannon send dump request");
> -               exit(1);
> +       if (show_details) {
> +               if (rtnl_wilddump_req_filter(&rth, PF_BRIDGE, RTM_GETLINK,
> +                                            (compress_vlans ?
> +                                             RTEXT_FILTER_BRVLAN_COMPRESSED :
> +                                             RTEXT_FILTER_BRVLAN)) < 0) {
> +                       perror("Cannon send dump request");
> +                       exit(1);
> +               }

vlan information is already available with `bridge vlan show`. any
specific reason why you want it in
the link dump output ?

The problem is this might just make the link dump larger and also add
too much clutter into the regular link dump output. iproute2 detailed
dump is already a bit hard to interpret. And without compression by
default, vlan info can just take over the link dump output. It will be
hard to look for other link attributes after that :). We deploy with
thousands of vlans and without compression even bridge vlan default
output is already hard to interpret.

Can you please paste a sample default detailed output with your patch
with a few hundred vlans ?
