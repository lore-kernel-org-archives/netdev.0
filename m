From: Jakub Sitnicki <jkbs@redhat.com>
Subject: Re: [PATCH iproute2] Enable use of extra debugging information
Date: Wed, 22 Jun 2016 10:36:39 +0200
Message-ID: <87oa6tmxgo.fsf@frog.home>
References: <1466551629-7921-1-git-send-email-dsa@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: netdev@vger.kernel.org, stephen@networkplumber.org
To: David Ahern <dsa@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f176.google.com ([209.85.220.176]:36453 "EHLO
	mail-qk0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751543AbcFVMhi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Jun 2016 08:37:38 -0400
Received: by mail-qk0-f176.google.com with SMTP id p10so62077648qke.3
        for <netdev@vger.kernel.org>; Wed, 22 Jun 2016 05:37:09 -0700 (PDT)
In-reply-to: <1466551629-7921-1-git-send-email-dsa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi David,

On Wed, Jun 22, 2016 at 01:27 AM CEST, David Ahern <dsa@cumulusnetworks.com> wrote:
> Add -g flag to builds if DEBUG parameter is set. Improves
> debugging with gdb.
>
> Signed-off-by: David Ahern <dsa@cumulusnetworks.com>
> ---
>  Makefile | 4 ++++
>  1 file changed, 4 insertions(+)
>
> diff --git a/Makefile b/Makefile
> index 15c81ecfdca3..8e006759079d 100644
> --- a/Makefile
> +++ b/Makefile
> @@ -39,7 +39,11 @@ HOSTCC = gcc
>  DEFINES += -D_GNU_SOURCE
>  # Turn on transparent support for LFS
>  DEFINES += -D_FILE_OFFSET_BITS=64 -D_LARGEFILE_SOURCE -D_LARGEFILE64_SOURCE
> +ifdef DEBUG
> +CCOPTS = -g
> +else
>  CCOPTS = -O2
> +endif
>  WFLAGS := -Wall -Wstrict-prototypes  -Wmissing-prototypes
>  WFLAGS += -Wmissing-declarations -Wold-style-definition -Wformat=2

This implies a change of optimization level to -O0 when building with
DEBUG set, doesn't it? Was it intentional?

Perhaps it would be less surprising to explicitly set -O0, if that was
your intention. Just a thought.

Thanks,
Jakub
