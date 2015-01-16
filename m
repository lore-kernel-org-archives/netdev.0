From: Shuah Khan <shuahkh@osg.samsung.com>
Subject: Re: [PATCH 6/6] selftests: Set CC using CROSS_COMPILE once in lib.mk
Date: Fri, 16 Jan 2015 09:37:04 -0700
Message-ID: <54B93E30.3060002@osg.samsung.com>
References: <1420794375-31881-1-git-send-email-mpe@ellerman.id.au> <1420794375-31881-6-git-send-email-mpe@ellerman.id.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 8bit
Cc: mmarek@suse.cz, gregkh@linuxfoundation.org,
	akpm@linux-foundation.org, rostedt@goodmis.org, mingo@redhat.com,
	davem@davemloft.net, keescook@chromium.org, tranmanphong@gmail.com,
	cov@codeaurora.org, dh.herrmann@gmail.com, hughd@google.com,
	bobby.prani@gmail.com, serge.hallyn@ubuntu.com,
	ebiederm@xmission.com, tim.bird@sonymobile.com,
	josh@joshtriplett.org, koct9i@gmail.com,
	linux-kbuild@vger.kernel.org, linux-api@vger.kernel.org,
	netdev@vger.kernel.org
To: Michael Ellerman <mpe@ellerman.id.au>, linux-kernel@vger.kernel.org
Return-path: <linux-kbuild-owner@vger.kernel.org>
In-Reply-To: <1420794375-31881-6-git-send-email-mpe@ellerman.id.au>
Sender: linux-kbuild-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 01/09/2015 02:06 AM, Michael Ellerman wrote:

Missing commit log. Please make sure your future include
a meaningful commit log that describes what the patch does.

> Signed-off-by: Michael Ellerman <mpe@ellerman.id.au>
> ---
>  tools/testing/selftests/efivarfs/Makefile | 1 -
>  tools/testing/selftests/exec/Makefile     | 1 -
>  tools/testing/selftests/kcmp/Makefile     | 1 -
>  tools/testing/selftests/lib.mk            | 6 ++++++
>  tools/testing/selftests/net/Makefile      | 1 -
>  tools/testing/selftests/powerpc/Makefile  | 3 +--
>  tools/testing/selftests/size/Makefile     | 2 --
>  tools/testing/selftests/vm/Makefile       | 1 -
>  8 files changed, 7 insertions(+), 9 deletions(-)
> 
> diff --git a/tools/testing/selftests/efivarfs/Makefile b/tools/testing/selftests/efivarfs/Makefile
> index 3052d0bda24b..d683486a859b 100644
> --- a/tools/testing/selftests/efivarfs/Makefile
> +++ b/tools/testing/selftests/efivarfs/Makefile
> @@ -1,4 +1,3 @@
> -CC = $(CROSS_COMPILE)gcc
>  CFLAGS = -Wall
>  
>  test_objs = open-unlink create-read
> diff --git a/tools/testing/selftests/exec/Makefile b/tools/testing/selftests/exec/Makefile
> index 886cabe307b1..4edb7d0da29b 100644
> --- a/tools/testing/selftests/exec/Makefile
> +++ b/tools/testing/selftests/exec/Makefile
> @@ -1,4 +1,3 @@
> -CC = $(CROSS_COMPILE)gcc
>  CFLAGS = -Wall
>  BINARIES = execveat
>  DEPS = execveat.symlink execveat.denatured script subdir
> diff --git a/tools/testing/selftests/kcmp/Makefile b/tools/testing/selftests/kcmp/Makefile
> index 0eecd183058c..2ae7450a9a89 100644
> --- a/tools/testing/selftests/kcmp/Makefile
> +++ b/tools/testing/selftests/kcmp/Makefile
> @@ -1,4 +1,3 @@
> -CC := $(CROSS_COMPILE)$(CC)
>  CFLAGS += -I../../../../usr/include/
>  
>  all: kcmp_test
> diff --git a/tools/testing/selftests/lib.mk b/tools/testing/selftests/lib.mk
> index 7bd3dabe2846..abae16396c43 100644
> --- a/tools/testing/selftests/lib.mk
> +++ b/tools/testing/selftests/lib.mk
> @@ -1,3 +1,9 @@
> +# When we're called from kbuild $(CC) already contains $(CROSS_COMPILE), so
> +# here we need to use "cc", otherwise we'll get $(CROSS_COMPILE) twice. The
> +# only downside is it breaks someone overriding $(CC), but that's probably OK,
> +# they can probably cope by changing their path.

I don't want to see the compiles broken and users needing to
work-around. Pleas find a way to not break the compiles.

thanks,
-- Shuah

-- 
Shuah Khan
Sr. Linux Kernel Developer
Open Source Innovation Group
Samsung Research America (Silicon Valley)
shuahkh@osg.samsung.com | (970) 217-8978
