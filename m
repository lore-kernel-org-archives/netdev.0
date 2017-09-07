From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH v2 1/2] selftests: bpf: test_kmod.sh: check if module
 is present in the path before insert
Date: Thu, 07 Sep 2017 11:16:52 +0200
Message-ID: <59B10E84.9090801@iogearbox.net>
References: <1504772342-21878-1-git-send-email-naresh.kamboju@linaro.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, davem@davemloft.net,
        alexei.starovoitov@gmail.com, netdev@vger.kernel.org
To: naresh.kamboju@linaro.org, shuahkh@osg.samsung.com,
        linux-kselftest@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1504772342-21878-1-git-send-email-naresh.kamboju@linaro.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 09/07/2017 10:19 AM, naresh.kamboju@linaro.org wrote:
> From: Naresh Kamboju <naresh.kamboju@linaro.org>
>
> The test script works when kernel source and build module test_bpf.ko
> present on the machine. This patch will check if module is present in
> the path.
>
> Signed-off-by: Naresh Kamboju <naresh.kamboju@linaro.org>

Looks good, what changed between v1 and v2? Didn't get the cover
letter in case there was one. ;)

Which tree are you targeting? There are usually a lot of changes
in BPF selftests going the usual route via net and net-next tree
as we often require to put test cases along the BPF patches. Given
the merge window now and given one can regard it as a fix, it's
net tree. I'm also ok if Shuah wants to pick it up this window as
test_kmod.sh hasn't been changed in quite a while, so no merge
conflicts expected.

Anyway, for the patch:

Acked-by: Daniel Borkmann <daniel@iogearbox.net>

Thanks!

> ---
>   tools/testing/selftests/bpf/test_kmod.sh | 8 +++++---
>   1 file changed, 5 insertions(+), 3 deletions(-)
>
> diff --git a/tools/testing/selftests/bpf/test_kmod.sh b/tools/testing/selftests/bpf/test_kmod.sh
> index 6d58cca8e235..a53eb1cb54ef 100755
> --- a/tools/testing/selftests/bpf/test_kmod.sh
> +++ b/tools/testing/selftests/bpf/test_kmod.sh
> @@ -9,9 +9,11 @@ test_run()
>
>   	echo "[ JIT enabled:$1 hardened:$2 ]"
>   	dmesg -C
> -	insmod $SRC_TREE/lib/test_bpf.ko 2> /dev/null
> -	if [ $? -ne 0 ]; then
> -		rc=1
> +	if [ -f $SRC_TREE/lib/test_bpf.ko ]; then
> +		insmod $SRC_TREE/lib/test_bpf.ko 2> /dev/null
> +		if [ $? -ne 0 ]; then
> +			rc=1
> +		fi
>   	fi
>   	rmmod  test_bpf 2> /dev/null
>   	dmesg | grep FAIL
>
