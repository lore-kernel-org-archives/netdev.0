From: Roopa Prabhu <roopa@cumulusnetworks.com>
Subject: Re: iproute2 mpls max labels
Date: Thu, 21 Jul 2016 11:53:26 -0700
Message-ID: <57911A26.3080203@cumulusnetworks.com>
References: <578A7BF0.2020107@nordu.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Robert Shearman <rshearma@brocade.com>,
	"ebiederm@xmission.com" <ebiederm@xmission.com>
To: Magnus Bergroth <bergroth@nordu.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f171.google.com ([209.85.192.171]:35681 "EHLO
	mail-pf0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751858AbcGUSx2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Jul 2016 14:53:28 -0400
Received: by mail-pf0-f171.google.com with SMTP id x72so32949446pfd.2
        for <netdev@vger.kernel.org>; Thu, 21 Jul 2016 11:53:27 -0700 (PDT)
In-Reply-To: <578A7BF0.2020107@nordu.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 7/16/16, 11:24 AM, Magnus Bergroth wrote:
> Wanted to use more than the default maximum of 8 mpls labels. Max labels
> seems to be hardcode to 8 in two places.
>
> --- iproute2-4.6.0/lib/utils.c    2016-05-18 20:56:02.000000000 +0200
> +++ iproute2-4.6.0-bergroth/lib/utils.c    2016-07-16 20:12:10.714958071
> +0200
> @@ -476,7 +476,7 @@
>          addr->bytelen = 4;
>          addr->bitlen = 20;
>          /* How many bytes do I need? */
> -        for (i = 0; i < 8; i++) {
> +        for (i = 0; i < MPLS_MAX_LABELS; i++) {
>              if (ntohl(addr->data[i]) & MPLS_LS_S_MASK) {
>                  addr->bytelen = (i + 1)*4;
>                  break;
>
>
> --- iproute2-4.6.0/include/utils.h    2016-05-18 20:56:02.000000000 +0200
> +++ iproute2-4.6.0-bergroth/include/utils.h    2016-07-15
> 11:55:57.297681742 +0200
> @@ -54,6 +54,9 @@
>  #define NEXT_ARG_FWD() do { argv++; argc--; } while(0)
>  #define PREV_ARG() do { argv--; argc++; } while(0)
>
> +/* Maximum number of labels the mpls helpers support */
> +#define MPLS_MAX_LABELS 8
> +
>  typedef struct
>  {
>      __u16 flags;
> @@ -61,7 +64,7 @@
>      __s16 bitlen;
>      /* These next two fields match rtvia */
>      __u16 family;
> -    __u32 data[8];
> +    __u32 data[MPLS_MAX_LABELS];
>  } inet_prefix;
>
>  #define PREFIXLEN_SPECIFIED 1
> @@ -88,9 +91,6 @@
>  # define AF_MPLS 28
>  #endif
>
> -/* Maximum number of labels the mpls helpers support */
> -#define MPLS_MAX_LABELS 8
> -
>  __u32 get_addr32(const char *name);
>  int get_addr_1(inet_prefix *dst, const char *arg, int family);
>  int get_prefix_1(inet_prefix *dst, char *arg, int family);
>
>
I did not realize it is hardcoded to 8 in iproute2. Because kernel has a hard coded limit of
2.
I think we need to fix it in a few places:
a) we should move the kernel #define to a uapi header file which iproute2 can use
b) there has been a general ask to bump the kernel MAX_LABELS from 2 and I don't see
a problem with it yet. so, we could bump it to 8.

Were you planning to post patches for one or both of the above ?.

I can post them too. Let me know.

Thanks,
Roopa
