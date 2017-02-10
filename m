From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [PATCH iproute2 2/2] actions: Add support for user cookies
Date: Fri, 10 Feb 2017 06:24:50 -0500
Message-ID: <5a189312-8ac0-2508-d5d1-43db24959b5d@mojatatu.com>
References: <1486725492-16748-1-git-send-email-jhs@emojatatu.com>
 <1486725492-16748-2-git-send-email-jhs@emojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, mrv@mojatatu.com,
        Jamal Hadi Salim <hadi@mojatatu.com>
To: stephen@networkplumber.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f193.google.com ([209.85.223.193]:36690 "EHLO
        mail-io0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751690AbdBJLeb (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 10 Feb 2017 06:34:31 -0500
Received: by mail-io0-f193.google.com with SMTP id q20so5504471ioi.3
        for <netdev@vger.kernel.org>; Fri, 10 Feb 2017 03:34:12 -0800 (PST)
In-Reply-To: <1486725492-16748-2-git-send-email-jhs@emojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 17-02-10 06:18 AM, Jamal Hadi Salim wrote:
> From: Jamal Hadi Salim <hadi@mojatatu.com>
>
> Make use of 128b user cookies
>
> Introduce optional 128-bit action cookie.
> Like all other cookie schemes in the networking world (eg in protocols
> like http or existing kernel fib protocol field, etc) the idea is to save
> user state that when retrieved serves as a correlator. The kernel
> _should not_ intepret it.  The user can store whatever they wish in the
> 128 bits.
>
> Sample exercise(showing variable length use of cookie)
>
> .. create an accept action with cookie a1b2c3d4
> sudo $TC actions add action ok index 1 cookie a1b2c3d4
>
> .. dump all gact actions..
> sudo $TC -s actions ls action gact
>
>     action order 0: gact action pass
>      random type none pass val 0
>      index 1 ref 1 bind 0 installed 5 sec used 5 sec
>     Action statistics:
>     Sent 0 bytes 0 pkt (dropped 0, overlimits 0 requeues 0)
>     backlog 0b 0p requeues 0
>     cookie a1b2c3d4
>
> .. bind the accept action to a filter..
> sudo $TC filter add dev lo parent ffff: protocol ip prio 1 \
> u32 match ip dst 127.0.0.1/32 flowid 1:1 action gact index 1
>
> ... send some traffic..
> $ ping 127.0.0.1 -c 3
> PING 127.0.0.1 (127.0.0.1) 56(84) bytes of data.
> 64 bytes from 127.0.0.1: icmp_seq=1 ttl=64 time=0.020 ms
> 64 bytes from 127.0.0.1: icmp_seq=2 ttl=64 time=0.027 ms
> 64 bytes from 127.0.0.1: icmp_seq=3 ttl=64 time=0.038 ms
>
> Signed-off-by: Jamal Hadi Salim <jhs@mojatatu.com>
> ---
>  include/linux/pkt_cls.h |  2 +-
>  tc/m_action.c           | 44 ++++++++++++++++++++++++++++++++++++++------
>  2 files changed, 39 insertions(+), 7 deletions(-)
>
> diff --git a/include/linux/pkt_cls.h b/include/linux/pkt_cls.h
> index fef68c4..af17f3c 100644
> --- a/include/linux/pkt_cls.h
> +++ b/include/linux/pkt_cls.h
> @@ -343,7 +343,7 @@ enum {
>  	TCA_BPF_NAME,
>  	TCA_BPF_FLAGS,
>  	TCA_BPF_FLAGS_GEN,
> -	TCA_BPF_DIGEST,
> +	TCA_BPF_TAG,
>  	__TCA_BPF_MAX,
>  };
>


Sorry - above header wasnt supposed to be in the patch. Ignore.
I will send v2.

cheers,
jamal
