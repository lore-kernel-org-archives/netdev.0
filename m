From: Steven Rostedt <rostedt@goodmis.org>
Subject: Re: [PATCH v3 05/20] selftests/ftrace: add install target to enable
 test install
Date: Fri, 2 Jan 2015 10:45:26 -0500
Message-ID: <20150102104526.29df5641@gandalf.local.home>
References: <cover.1419387513.git.shuahkh@osg.samsung.com>
	<e84eeeecde70ecb3ab82c5f825fec359f9e967ff.1419387513.git.shuahkh@osg.samsung.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: mmarek@suse.cz, gregkh@linuxfoundation.org,
	akpm@linux-foundation.org, mingo@redhat.com, davem@davemloft.net,
	keescook@chromium.org, tranmanphong@gmail.com, mpe@ellerman.id.au,
	cov@codeaurora.org, dh.herrmann@gmail.com, hughd@google.com,
	bobby.prani@gmail.com, serge.hallyn@ubuntu.com,
	ebiederm@xmission.com, tim.bird@sonymobile.com,
	josh@joshtriplett.org, koct9i@gmail.com,
	linux-kbuild@vger.kernel.org, linux-kernel@vger.kernel.org,
	linux-api@vger.kernel.org, netdev@vger.kernel.org
To: Shuah Khan <shuahkh@osg.samsung.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <e84eeeecde70ecb3ab82c5f825fec359f9e967ff.1419387513.git.shuahkh@osg.samsung.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 24 Dec 2014 09:27:41 -0700
Shuah Khan <shuahkh@osg.samsung.com> wrote:

> Add a new make target to enable installing test. This target
> installs test in the kselftest install location and add to the
> kselftest script to run the test. Install target can be run
> only from top level kernel source directory.
> 
> Signed-off-by: Shuah Khan <shuahkh@osg.samsung.com>
> ---
>  tools/testing/selftests/ftrace/Makefile | 11 ++++++++++-
>  1 file changed, 10 insertions(+), 1 deletion(-)
> 
> diff --git a/tools/testing/selftests/ftrace/Makefile b/tools/testing/selftests/ftrace/Makefile
> index 76cc9f1..7c7cf42 100644
> --- a/tools/testing/selftests/ftrace/Makefile
> +++ b/tools/testing/selftests/ftrace/Makefile
> @@ -1,7 +1,16 @@
> +TEST_STR = /bin/sh ./ftracetest || echo ftrace selftests: [FAIL]

Is it ok that this removes the quotes around the echo string? I don't
see anything wrong about it, but I don't know if there's a shell out
there that will fail due to it.

Other than than,

Acked-by: Steven Rostedt <rostedt@goodmis.org>

-- Steve


> +
>  all:
>  
> +install:
> +ifdef INSTALL_KSFT_PATH
> +	install ./ftracetest $(INSTALL_KSFT_PATH)
> +	@cp -r test.d $(INSTALL_KSFT_PATH)
> +	echo "$(TEST_STR)" >> $(KSELFTEST)
> +endif
> +
>  run_tests:
> -	@/bin/sh ./ftracetest || echo "ftrace selftests: [FAIL]"
> +	@$(TEST_STR)
>  
>  clean:
>  	rm -rf logs/*
