From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [next-queue PATCH v6 3/5] net/sched: Introduce Credit Based
 Shaper (CBS) qdisc
Date: Wed, 11 Oct 2017 18:32:52 -0700
Message-ID: <1507771972.31614.41.camel@edumazet-glaptop3.roam.corp.google.com>
References: <20171012005449.26533-1-vinicius.gomes@intel.com>
         <20171012005449.26533-4-vinicius.gomes@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, intel-wired-lan@lists.osuosl.org,
        jhs@mojatatu.com, xiyou.wangcong@gmail.com, jiri@resnulli.us,
        andre.guedes@intel.com, ivan.briano@intel.com,
        jesus.sanchez-palencia@intel.com, boon.leong.ong@intel.com,
        richardcochran@gmail.com, henrik@austad.us, levipearson@gmail.com,
        rodney.cummings@ni.com
To: Vinicius Costa Gomes <vinicius.gomes@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f178.google.com ([209.85.192.178]:57078 "EHLO
        mail-pf0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751757AbdJLBcz (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 11 Oct 2017 21:32:55 -0400
Received: by mail-pf0-f178.google.com with SMTP id b85so2735611pfj.13
        for <netdev@vger.kernel.org>; Wed, 11 Oct 2017 18:32:55 -0700 (PDT)
In-Reply-To: <20171012005449.26533-4-vinicius.gomes@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2017-10-11 at 17:54 -0700, Vinicius Costa Gomes wrote:
> This queueing discipline implements the shaper algorithm defined by
> the 802.1Q-2014 Section 8.6.8.2 and detailed in Annex L.

...

> +static s64 delay_from_credits(s64 credits, s32 slope)
> +{
> +	s64 rate = slope * BYTES_PER_KBIT;
> +
> +	if (unlikely(rate == 0))
> +		return S64_MAX;
> +
> +	return ((-credits * NSEC_PER_SEC) / rate);
> +}

Have you tried to compile this on 32bit arch ?

make ARCH=i386
