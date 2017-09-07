From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH v2 2/2] selftests: bpf: test_kmod.sh: use modprobe on
 target device
Date: Thu, 07 Sep 2017 11:20:16 +0200
Message-ID: <59B10F50.5020109@iogearbox.net>
References: <1504772342-21878-1-git-send-email-naresh.kamboju@linaro.org> <1504772342-21878-2-git-send-email-naresh.kamboju@linaro.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, davem@davemloft.net,
        alexei.starovoitov@gmail.com, netdev@vger.kernel.org
To: naresh.kamboju@linaro.org, shuahkh@osg.samsung.com,
        linux-kselftest@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1504772342-21878-2-git-send-email-naresh.kamboju@linaro.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 09/07/2017 10:19 AM, naresh.kamboju@linaro.org wrote:
> From: Naresh Kamboju <naresh.kamboju@linaro.org>
>
> on ARM and ARM64 devices kernel source tree is not available so
> insmod "$SRC_TREE/lib/test_bpf.ko" is not working.
>
> on these target devices the test_bpf.ko is installed under
> /lib/modules/`uname -r`/kernel/lib/
> so use modprobe dry run to check for missing test_bpf.ko module and
> insert for testing.
>
> Signed-off-by: Naresh Kamboju <naresh.kamboju@linaro.org>

Acked-by: Daniel Borkmann <daniel@iogearbox.net>

One really small nit that could probably be fixed up along the
way when applying:

> ---
>   tools/testing/selftests/bpf/test_kmod.sh | 10 ++++++++++
>   1 file changed, 10 insertions(+)
>
> diff --git a/tools/testing/selftests/bpf/test_kmod.sh b/tools/testing/selftests/bpf/test_kmod.sh
> index a53eb1cb54ef..eab9a970d742 100755
> --- a/tools/testing/selftests/bpf/test_kmod.sh
> +++ b/tools/testing/selftests/bpf/test_kmod.sh
> @@ -14,6 +14,16 @@ test_run()
>   		if [ $? -ne 0 ]; then
>   			rc=1
>   		fi
> +	 else

Looks like a whitespace slipped in right before the "else",
so should be removed to only habe the tab indent.

> +		# Use modprobe dry run to check for missing test_bpf module
> +		if ! /sbin/modprobe -q -n test_bpf; then
> +			echo "test_bpf: [SKIP]"
> +		elif /sbin/modprobe -q test_bpf; then
> +			echo "test_bpf: ok"
> +		else
> +			echo "test_bpf: [FAIL]"
> +			rc=1
> +		fi
>   	fi
>   	rmmod  test_bpf 2> /dev/null
>   	dmesg | grep FAIL
>
