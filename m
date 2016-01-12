From: Jiri Olsa <jolsa@redhat.com>
Subject: Re: [PATCH 01/53] perf tools: Add -lutil in python lib list for
 broken python-config
Date: Tue, 12 Jan 2016 10:43:15 +0100
Message-ID: <20160112094315.GB27690@krava.brq.redhat.com>
References: <1452520124-2073-1-git-send-email-wangnan0@huawei.com>
 <1452520124-2073-2-git-send-email-wangnan0@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: acme@kernel.org, linux-kernel@vger.kernel.org, pi3orama@163.com,
	lizefan@huawei.com, netdev@vger.kernel.org, davem@davemloft.net,
	Jiri Olsa <jolsa@kernel.org>,
	Namhyung Kim <namhyung@kernel.org>
To: Wang Nan <wangnan0@huawei.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1452520124-2073-2-git-send-email-wangnan0@huawei.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Jan 11, 2016 at 01:47:52PM +0000, Wang Nan wrote:
> On some system the perf-config is broken, causes link failure like this:

I've never got 0/53 email of this patchset.. is there any?

I was just wondering if there's git tree with patchset,
it'd make it easier for me to review it

thanks,
jirka


> 
>  /usr/lib64/python2.7/config/libpython2.7.a(posixmodule.o): In function `posix_forkpty':
>  /opt/wangnan/yocto-build/tmp-eglibc/work/x86_64-oe-linux/python/2.7.3-r0.3.1/Python-2.7.3/./Modules/posixmodule.c:3816: undefined reference to `forkpty'
>  /usr/lib64/python2.7/config/libpython2.7.a(posixmodule.o): In function `posix_openpty':
>  /opt/wangnan/yocto-build/tmp-eglibc/work/x86_64-oe-linux/python/2.7.3-r0.3.1/Python-2.7.3/./Modules/posixmodule.c:3756: undefined reference to `openpty'
>  collect2: error: ld returned 1 exit status
> make[1]: *** [/home/wangnan/kernel-hydrogen/tools/perf/out/perf] Error 1
> make: *** [all] Error 2
> 
>  $ python-config --libs
>  -lpthread -ldl -lpthread -lutil -lm -lpython2.7
> 
> In this case a '-lutil' should be appended to -lpython2.7.
> 
> (I know we have --start-group and --end-group. I can see them in
> command line of collect2 by strace. However it doesn't work. Seems
> I have a broken environment?)
> 
> Signed-off-by: Wang Nan <wangnan0@huawei.com>
> Cc: Arnaldo Carvalho de Melo <acme@kernel.org>
> Cc: Jiri Olsa <jolsa@kernel.org>
> Cc: Namhyung Kim <namhyung@kernel.org>
> ---
>  tools/perf/config/Makefile | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/tools/perf/config/Makefile b/tools/perf/config/Makefile
> index 254d06e..0793c76 100644
> --- a/tools/perf/config/Makefile
> +++ b/tools/perf/config/Makefile
> @@ -493,7 +493,7 @@ else
>  
>        PYTHON_EMBED_LDOPTS := $(shell $(PYTHON_CONFIG_SQ) --ldflags 2>/dev/null)
>        PYTHON_EMBED_LDFLAGS := $(call strip-libs,$(PYTHON_EMBED_LDOPTS))
> -      PYTHON_EMBED_LIBADD := $(call grep-libs,$(PYTHON_EMBED_LDOPTS))
> +      PYTHON_EMBED_LIBADD := $(call grep-libs,$(PYTHON_EMBED_LDOPTS)) -lutil
>        PYTHON_EMBED_CCOPTS := $(shell $(PYTHON_CONFIG_SQ) --cflags 2>/dev/null)
>        FLAGS_PYTHON_EMBED := $(PYTHON_EMBED_CCOPTS) $(PYTHON_EMBED_LDOPTS)
>  
> -- 
> 1.8.3.4
> 
