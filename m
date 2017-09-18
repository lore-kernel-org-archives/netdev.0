From: Shuah Khan <shuah@kernel.org>
Subject: Re: [PATCH 3/3] selftests: silence test output by default
Date: Mon, 18 Sep 2017 11:46:18 -0600
Message-ID: <e8b067d2-9cef-2f3c-78a5-d6630aa765c1@kernel.org>
References: <1505755982-7855-1-git-send-email-jbacik@fb.com>
 <1505756224-8187-1-git-send-email-jbacik@fb.com>
Reply-To: shuah@kernel.org
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: Josef Bacik <jbacik@fb.com>,
        "David S. Miller" <davem@davemloft.net>,
        linux-kernel@vger.kernel.org, linux-kselftest@vger.kernel.org,
        netdev@vger.kernel.org, shuah Khan <shuahkh@osg.samsung.com>
To: josef@toxicpanda.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1505756224-8187-1-git-send-email-jbacik@fb.com>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 09/18/2017 11:37 AM, josef@toxicpanda.com wrote:
> From: Josef Bacik <jbacik@fb.com>
> 
> Some of the networking tests are very noisy and make it impossible to
> see if we actually passed the tests as they run.  Default to suppressing
> the output from any tests run in order to make it easier to track what
> failed.
> 
> Signed-off-by: Josef Bacik <jbacik@fb.com>
> --

This change suppresses pass/fail wrapper output for all tests, not just the
networking tests.

Could you please send me before and after results for what you are trying
to fix.

>  tools/testing/selftests/lib.mk | 4 ++--
>  1 file changed, 2 insertions(+), 2 deletions(-)
> 
> diff --git a/tools/testing/selftests/lib.mk b/tools/testing/selftests/lib.mk
> index 693616651da5..223234cd98e9 100644
> --- a/tools/testing/selftests/lib.mk
> +++ b/tools/testing/selftests/lib.mk
> @@ -24,7 +24,7 @@ define RUN_TESTS
>  			echo "selftests: Warning: file $$BASENAME_TEST is not executable, correct this.";\
>  			echo "not ok 1..$$test_num selftests: $$BASENAME_TEST [FAIL]"; \
>  		else					\
> -			cd `dirname $$TEST` > /dev/null; (./$$BASENAME_TEST && echo "ok 1..$$test_num selftests: $$BASENAME_TEST [PASS]") || echo "not ok 1..$$test_num selftests:  $$BASENAME_TEST [FAIL]"; cd - > /dev/null;\
> +			cd `dirname $$TEST` > /dev/null; (./$$BASENAME_TEST > /dev/null 2>&1 && echo "ok 1..$$test_num selftests: $$BASENAME_TEST [PASS]") || echo "not ok 1..$$test_num selftests:  $$BASENAME_TEST [FAIL]"; cd - > /dev/null;\
>  		fi;					\
>  	done;
>  endef
> @@ -55,7 +55,7 @@ endif
>  define EMIT_TESTS
>  	@for TEST in $(TEST_GEN_PROGS) $(TEST_PROGS); do \
>  		BASENAME_TEST=`basename $$TEST`;	\
> -		echo "(./$$BASENAME_TEST && echo \"selftests: $$BASENAME_TEST [PASS]\") || echo \"selftests: $$BASENAME_TEST [FAIL]\""; \
> +		echo "(./$$BASENAME_TEST > /dev/null 2>&1 && echo \"selftests: $$BASENAME_TEST [PASS]\") || echo \"selftests: $$BASENAME_TEST [FAIL]\""; \
>  	done;
>  endef
>  
> 

thanks,
-- Shuah
