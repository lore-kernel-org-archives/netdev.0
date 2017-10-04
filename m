From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] selftests: rtnetlink: try concurrent change of
 ifalias
Date: Wed, 04 Oct 2017 07:16:33 -0700
Message-ID: <1507126593.14419.0.camel@edumazet-glaptop3.roam.corp.google.com>
References: <20171004115258.5878-1-fw@strlen.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Florian Westphal <fw@strlen.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f67.google.com ([74.125.83.67]:37061 "EHLO
        mail-pg0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752448AbdJDOQf (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 4 Oct 2017 10:16:35 -0400
Received: by mail-pg0-f67.google.com with SMTP id o1so12109459pga.4
        for <netdev@vger.kernel.org>; Wed, 04 Oct 2017 07:16:35 -0700 (PDT)
In-Reply-To: <20171004115258.5878-1-fw@strlen.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2017-10-04 at 13:52 +0200, Florian Westphal wrote:
> to make sure this is serialized correctly.
> 
> Signed-off-by: Florian Westphal <fw@strlen.de>
> ---
>  tools/testing/selftests/net/rtnetlink.sh | 8 ++++++++
>  1 file changed, 8 insertions(+)
> 
> diff --git a/tools/testing/selftests/net/rtnetlink.sh b/tools/testing/selftests/net/rtnetlink.sh
> index 62c87da92770..13c29beb5769 100755
> --- a/tools/testing/selftests/net/rtnetlink.sh
> +++ b/tools/testing/selftests/net/rtnetlink.sh
> @@ -278,6 +278,14 @@ kci_test_ifalias()
>  	        ip link show "$devdummy" | grep -q "alias $namewant"
>  		check_fail $?
>  
> +		for i in $(seq 1 100); do
> +			uuidgen > "$syspathname" &
> +		done
> +
> +		for i in $(seq 1 100); do
> +			wait
> +		done
> +

A single wait is enough, you do not need a loop.
