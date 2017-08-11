From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH] selftests: bpf: add check for ip XDP redirect
Date: Fri, 11 Aug 2017 13:31:35 +0200
Message-ID: <598D9597.2030907@iogearbox.net>
References: <1502409753-27516-1-git-send-email-u9012063@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: John Fastabend <john.fastabend@gmail.com>
To: William Tu <u9012063@gmail.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:56999 "EHLO
        www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752728AbdHKLbg (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 11 Aug 2017 07:31:36 -0400
In-Reply-To: <1502409753-27516-1-git-send-email-u9012063@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/11/2017 02:02 AM, William Tu wrote:
> Kernel test robot reports error when running test_xdp_redirect.sh.
> Check if ip tool supports xdpgeneric, if not, skip the test.
>
> Signed-off-by: William Tu <u9012063@gmail.com>
> Cc: Daniel Borkmann <daniel@iogearbox.net>
> Cc: John Fastabend <john.fastabend@gmail.com>
> ---
>   tools/testing/selftests/bpf/test_xdp_redirect.sh | 5 +++++
>   1 file changed, 5 insertions(+)
>
> diff --git a/tools/testing/selftests/bpf/test_xdp_redirect.sh b/tools/testing/selftests/bpf/test_xdp_redirect.sh
> index d8c73ed6e040..c5a8b7173c12 100755
> --- a/tools/testing/selftests/bpf/test_xdp_redirect.sh
> +++ b/tools/testing/selftests/bpf/test_xdp_redirect.sh
> @@ -23,6 +23,11 @@ cleanup()
>   	ip netns del ns2 2> /dev/null
>   }
>
> +ip link set dev lo xdpgeneric off 2>/dev/null > /dev/null
> +if [ $? -ne 0 ];then
> +        echo "selftests: [SKIP] Could not run test without the ip xdpgeneric support"
> +        exit 0

Small nit: could you make that indent consistently as tabs
like in your cleanup() function slightly further above?

Other than that (+ subject should also be [PATCH net-next]):

Acked-by: Daniel Borkmann <daniel@iogearbox.net>
