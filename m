From: Roman Mashak <mrv@mojatatu.com>
Subject: Re: [PATCH iproute2 v2 1/1] vxlan: Add support for modifying vxlan device attributes
Date: Sun, 07 May 2017 10:40:29 -0400
Message-ID: <85shkgd92a.fsf@mojatatu.com>
References: <1494095863-21916-1-git-send-email-girish.moodalbail@oracle.com>
        <1494095863-21916-2-git-send-email-girish.moodalbail@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <stephen@networkplumber.org>, <netdev@vger.kernel.org>
To: Girish Moodalbail <girish.moodalbail@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f65.google.com ([209.85.214.65]:36200 "EHLO
        mail-it0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754429AbdEGVkA (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 7 May 2017 17:40:00 -0400
Received: by mail-it0-f65.google.com with SMTP id x188so5730665itb.3
        for <netdev@vger.kernel.org>; Sun, 07 May 2017 14:40:00 -0700 (PDT)
In-Reply-To: <1494095863-21916-2-git-send-email-girish.moodalbail@oracle.com>
        (Girish Moodalbail's message of "Sat, 6 May 2017 11:37:43 -0700")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Girish Moodalbail <girish.moodalbail@oracle.com> writes:


[...]

>  ip/iplink_vxlan.c | 251 +++++++++++++++++++++++++++++++-----------------------
>  1 file changed, 143 insertions(+), 108 deletions(-)
>
> diff --git a/ip/iplink_vxlan.c b/ip/iplink_vxlan.c
> index b4ebb13..2bd619d 100644
> --- a/ip/iplink_vxlan.c
> +++ b/ip/iplink_vxlan.c
> @@ -21,6 +21,8 @@
>  #include "utils.h"
>  #include "ip_common.h"
>  
> +#define VXLAN_ATTRSET(attrs, type) (((attrs) & (1L << (type))) != 0)

I think you can drop '!= 0' part in the macro.

[...]

>  
> +static void check_duparg(__u64 *attrs, int type, const char *key,
> +			 const char *argv)
> +{
> +	if (!VXLAN_ATTRSET(*attrs, type)) {
> +		*attrs |= (1L << type);
> +		return;
> +	}
> +	duparg2(key, argv);
> +}

[...]
