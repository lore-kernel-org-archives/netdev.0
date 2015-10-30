From: Rayagond Kokatanur <rayagond@vayavyalabs.com>
Subject: Re: stmmac: Reporting ethtool_ts_info
Date: Fri, 30 Oct 2015 10:45:21 +0530
Message-ID: <CAJ3bTp6aKFqFs63HZPFRUD1R46dLfAhz_6SOkz4_NMi7qHJ37Q@mail.gmail.com>
References: <562F1577.8040803@electromag.com.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>,
	Giuseppe Cavallaro <peppe.cavallaro@st.com>
To: Phil Reid <preid@electromag.com.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f51.google.com ([74.125.82.51]:33875 "EHLO
	mail-wm0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752283AbbJ3FVB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 Oct 2015 01:21:01 -0400
Received: by wmff134 with SMTP id f134so3504992wmf.1
        for <netdev@vger.kernel.org>; Thu, 29 Oct 2015 22:21:00 -0700 (PDT)
In-Reply-To: <562F1577.8040803@electromag.com.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Oct 27, 2015 at 11:41 AM, Phil Reid <preid@electromag.com.au> wrote:
> G'day All,
>
> The stmmac driver checks (priv->hwts_tx_en) && (priv->hwts_rx_en) before
> reporting WHTSTAMP capabilities.
> No other driver seems to do this. hwts_*_en indicate if timestamping is
> enabled, not if the interface is capable of it.
> Instead they check there capabilities. Which would be
> (priv->dma_cap.time_stamp || priv->dma_cap.atime_stamp)

Yes true.

priv->hwts_*_en indicate if timestamping is enabled/disabled at run
time. But  priv->dma_cap.time_stamp  and priv->dma_cap.atime_stamp
indicates HW is support for PTPv1/PTPv2.

We should use  - (priv->dma_cap.time_stamp ||
priv->dma_cap.atime_stamp) in ethtool_ts_ops.

wwr
Rayagond
>
> Does this seem reasonable?
>
>
> --
> Regards
> Phil Reid
>
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
