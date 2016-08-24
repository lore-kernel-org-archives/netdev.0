From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH net-next] tcp: md5: add LINUX_MIB_TCPMD5FAILURE counter
Date: Wed, 24 Aug 2016 10:35:20 -0700
Message-ID: <20160824103520.56fad551@xeon-e3>
References: <1472054483.14381.86.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
        netdev <netdev@vger.kernel.org>,
        Neal Cardwell <ncardwell@google.com>,
        Yuchung Cheng <ycheng@google.com>,
        Julien Goodwin <julieng@google.com>,
        Eric Dumazet <edumazet@google.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f176.google.com ([209.85.192.176]:33287 "EHLO
        mail-pf0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754560AbcHXSAt (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 24 Aug 2016 14:00:49 -0400
Received: by mail-pf0-f176.google.com with SMTP id y134so9051172pfg.0
        for <netdev@vger.kernel.org>; Wed, 24 Aug 2016 11:00:49 -0700 (PDT)
In-Reply-To: <1472054483.14381.86.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 24 Aug 2016 09:01:23 -0700
Eric Dumazet <eric.dumazet@gmail.com> wrote:

> From: Eric Dumazet <edumazet@google.com>
> 
> Adds SNMP counter for drops caused by MD5 mismatches.
> 
> The current syslog might help, but a counter is more precise and helps
> monitoring.
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> ---
>  include/uapi/linux/snmp.h |    1 +
>  net/ipv4/proc.c           |    1 +
>  net/ipv4/tcp_ipv4.c       |    1 +
>  net/ipv6/tcp_ipv6.c       |    1 +
>  4 files changed, 4 insertions(+)
> 
> diff --git a/include/uapi/linux/snmp.h b/include/uapi/linux/snmp.h
> index 25a9ad8bcef1240915f2553a8acade447186d869..e7a31f8306903f53bc5881ae4c271f85cad2e361 100644
> --- a/include/uapi/linux/snmp.h
> +++ b/include/uapi/linux/snmp.h
> @@ -235,6 +235,7 @@ enum
>  	LINUX_MIB_TCPSPURIOUSRTOS,		/* TCPSpuriousRTOs */
>  	LINUX_MIB_TCPMD5NOTFOUND,		/* TCPMD5NotFound */
>  	LINUX_MIB_TCPMD5UNEXPECTED,		/* TCPMD5Unexpected */
> +	LINUX_MIB_TCPMD5FAILURE,		/* TCPMD5Failure */
>  	LINUX_MIB_SACKSHIFTED,
>  	LINUX_MIB_SACKMERGED,
>  	LINUX_MIB_SACKSHIFTFALLBACK,

You can't add value in middle of user API enum without breaking
binary compatibility.
