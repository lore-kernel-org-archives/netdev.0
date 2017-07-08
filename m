From: Lorenzo Colitti <lorenzo@google.com>
Subject: Re: [PATCH iproute2] ip: change flag names to an array
Date: Sat, 8 Jul 2017 15:08:12 +0900
Message-ID: <CAKD1Yr1tPL3_30jLJA-E4h05X2A85d=UOLmsGo+atWMResK7cA@mail.gmail.com>
References: <20170707153941.5427-1-stephen@networkplumber.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vk0-f53.google.com ([209.85.213.53]:33703 "EHLO
        mail-vk0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751002AbdGHGIe (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 8 Jul 2017 02:08:34 -0400
Received: by mail-vk0-f53.google.com with SMTP id r126so27482089vkg.0
        for <netdev@vger.kernel.org>; Fri, 07 Jul 2017 23:08:33 -0700 (PDT)
In-Reply-To: <20170707153941.5427-1-stephen@networkplumber.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Jul 8, 2017 at 12:39 AM, Stephen Hemminger
<stephen@networkplumber.org> wrote:
> For the most of the address flags, use a table of bit values rather
> than open coding every value.  This allows for easier inevitable
> expansion of flags.

Thanks for doing this.

> +static unsigned int get_ifa_flag_mask(const char *name)
> +{
> +       unsigned int i;
> +
> +       for (i = 0; i < ARRAY_SIZE(ifa_flag_names); i++) {
> +               if (!strcmp(name, ifa_flag_names[i]))
> +                       return 1u << i;
> +       }
> +       return 0;
> +}

It looks like the user can specify things such as "-deprecated".
Perhaps that sort of thing can be handled by this function too?
Instead of returning an unsigned int, this function could be void and
take a flag value and a mask as output parameters. If the flag name
starts with "-" it would set the value to 0, and if it doesn't it
would set the value to 1.

Otherwise, some of the -<flag> parameters will either need to be
special cased or cease to be supported. Specifically, I see this one:

> -               } else if (strcmp(*argv, "-tentative") == 0) {
> -                       filter.flags &= ~IFA_F_TENTATIVE;
> -                       filter.flagmask |= IFA_F_TENTATIVE;

this one:

> -               } else if (strcmp(*argv, "-deprecated") == 0) {
> -                       filter.flags &= ~IFA_F_DEPRECATED;
> -                       filter.flagmask |= IFA_F_DEPRECATED;

and this one:

> -               } else if (strcmp(*argv, "-dadfailed") == 0) {
> -                       filter.flags &= ~IFA_F_DADFAILED;
> -                       filter.flagmask |= IFA_F_DADFAILED;
