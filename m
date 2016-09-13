From: Michael Ellerman <mpe@ellerman.id.au>
Subject: Re: [PATCH 2/9] selftests: update filesystems Makefile to work under selftests
Date: Tue, 13 Sep 2016 21:56:21 +1000
Message-ID: <87fup4ovx6.fsf@concordia.ellerman.id.au>
References: <cover.1473458697.git.shuahkh@osg.samsung.com> <239195aa67e72b7eb971cdacfc9e338de912524e.1473458697.git.shuahkh@osg.samsung.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Shuah Khan <shuahkh@osg.samsung.com>, linux-doc@vger.kernel.org,
        linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
        linux-kselftest@vger.kernel.org
To: Shuah Khan <shuahkh@osg.samsung.com>, corbet@lwn.net,
        richardcochran@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from ozlabs.org ([103.22.144.67]:41107 "EHLO ozlabs.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750951AbcIML41 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 13 Sep 2016 07:56:27 -0400
In-Reply-To: <239195aa67e72b7eb971cdacfc9e338de912524e.1473458697.git.shuahkh@osg.samsung.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Shuah Khan <shuahkh@osg.samsung.com> writes:

> Update to work under selftests. dnotify_test will not be run as part of
> selftests suite and will not included in install targets. It can be built
> separately for now.
>
> Signed-off-by: Shuah Khan <shuahkh@osg.samsung.com>
> ---
>  tools/testing/selftests/filesystems/Makefile | 10 ++++++----
>  1 file changed, 6 insertions(+), 4 deletions(-)
>
> diff --git a/tools/testing/selftests/filesystems/Makefile b/tools/testing/selftests/filesystems/Makefile
> index 883010c..f1dce5c 100644
> --- a/tools/testing/selftests/filesystems/Makefile
> +++ b/tools/testing/selftests/filesystems/Makefile
> @@ -1,5 +1,7 @@
> -# List of programs to build
> -hostprogs-y := dnotify_test
> +TEST_PROGS := dnotify_test
> +all: $(TEST_PROGS)
>  
> -# Tell kbuild to always build the programs
> -always := $(hostprogs-y)
> +include ../lib.mk
> +
> +clean:
> +	rm -fr dnotify_test

That's a complete rewrite of the Makefile, so I don't think there's any
value in bringing its content across from Documentation.

Better IMHO would be to squash this with the previous patch, so we get a
working test under selftests in a single commit.

cheers
