From: "Ian McDonald" <ian.mcdonald@jandi.co.nz>
Subject: Re: [PATCH] make _minimum_ TCP retransmission timeout configurable
Date: Thu, 30 Aug 2007 09:32:38 +1200
Message-ID: <5640c7e00708291432q6acde704od52247647a6b453@mail.gmail.com>
References: <200708292052.NAA21975@tardy.cup.hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: "Rick Jones" <rick.jones2@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wa-out-1112.google.com ([209.85.146.179]:46376 "EHLO
	wa-out-1112.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756980AbXH2Vcj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Aug 2007 17:32:39 -0400
Received: by wa-out-1112.google.com with SMTP id v27so357680wah
        for <netdev@vger.kernel.org>; Wed, 29 Aug 2007 14:32:38 -0700 (PDT)
In-Reply-To: <200708292052.NAA21975@tardy.cup.hp.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 8/30/07, Rick Jones <rick.jones2@hp.com> wrote:
> Enable configuration of the minimum TCP Retransmission Timeout via
> a new sysctl "tcp_rto_min" to help those who's networks (eg cellular)
> have quite variable RTTs avoid spurrious RTOs.
>
> Signed-off-by: Rick Jones <rick.jones2@hp.com>
> Signed-off-by: Lamont Jones <lamont@hp.com>
> ---
>
> diff -r 1559df81a153 Documentation/networking/ip-sysctl.txt
> --- a/Documentation/networking/ip-sysctl.txt    Mon Aug 13 05:00:33 2007 +0000
> +++ b/Documentation/networking/ip-sysctl.txt    Wed Aug 22 10:42:55 2007 -0700
> @@ -339,6 +339,13 @@ tcp_rmem - vector of 3 INTEGERs: min, de
>         selected receiver buffers for TCP socket. This value does not override
>         net.core.rmem_max, "static" selection via SO_RCVBUF does not use this.
>         Default: 87380*2 bytes.
> +
> +tcp_rto_min - INTEGER
> +       The minimum value for the TCP Retransmission Timeout, expressed
> +       in milliseconds for the convenience of the user.
> +       This is bounded at the low-end by TCP_RTO_MIN and by TCP_RTO_MAX at
> +       the high-end.
> +       Default: 200.
>

Hmmm... RFC2988 says:
   (2.4) Whenever RTO is computed, if it is less than 1 second then the
         RTO SHOULD be rounded up to 1 second.

         Traditionally, TCP implementations use coarse grain clocks to
         measure the RTT and trigger the RTO, which imposes a large
         minimum value on the RTO.  Research suggests that a large
         minimum RTO is needed to keep TCP conservative and avoid
         spurious retransmissions [AP99].  Therefore, this
         specification requires a large minimum RTO as a conservative
         approach, while at the same time acknowledging that at some
         future point, research may show that a smaller minimum RTO is
         acceptable or superior.

I went and had a look and this RFC has not been obsoleted. RFC3390
also backs this assertion up.

So I'm suspecting that the default should be changed to 1000 to match
the RFC which would solve this issue. I note that the RFC is a SHOULD
rather than a MUST. I had a quick look around and not sure why Linux
overrides the RFC on this one.

Ian
-- 
Web1: http://wand.net.nz/~iam4/
Web2: http://www.jandi.co.nz
Blog: http://iansblog.jandi.co.nz
