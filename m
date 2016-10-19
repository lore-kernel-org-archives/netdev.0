From: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Subject: Re: bad commit touching stmmac_ptp.c
Date: Wed, 19 Oct 2016 09:16:26 +0200
Message-ID: <63faa826-2e87-f73e-6c1f-34fbced9d220@st.com>
References: <alpine.LFD.2.20.1610182339340.25105@knanqh.ubzr>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Alexandre TORGUE <alexandre.torgue@st.com>,
        Rayagond Kokatanur <rayagond@vayavyalabs.com>,
        "David S. Miller" <davem@davemloft.net>, <netdev@vger.kernel.org>
To: Nicolas Pitre <nicolas.pitre@linaro.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx07-00178001.pphosted.com ([62.209.51.94]:7096 "EHLO
        mx07-00178001.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S936519AbcJSOSM (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 19 Oct 2016 10:18:12 -0400
In-Reply-To: <alpine.LFD.2.20.1610182339340.25105@knanqh.ubzr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello Nicolas

I have just sent a new patch to try to fix the problems you
raised.

Please let me know if

    [PATCH (net.git)] stmmac: fix and review the ptp registration

actually covers and fixes the points.

FYI, I am trying to review the PTP, especially for
for the GMAC4, in these days so I will send other
patches on top of this if OK.

Thanks for your advice and warning.

Peppe

On 10/19/2016 6:16 AM, Nicolas Pitre wrote:
> Hello,
>
> I noticed a recently added commit 7086605a6a ("stmmac: fix error check
> when init ptp") to the mainline linux tree from you. This commit is
> wrong.  The affected code now reads as:
>
> int stmmac_ptp_register(struct stmmac_priv *priv)
> {
>         spin_lock_init(&priv->ptp_lock);
>         priv->ptp_clock_ops = stmmac_ptp_clock_ops;
>
>         priv->ptp_clock = ptp_clock_register(&priv->ptp_clock_ops,
>                                              priv->device);
>         if (IS_ERR(priv->ptp_clock)) {
>                 priv->ptp_clock = NULL;
>                 return PTR_ERR(priv->ptp_clock);
>         }
>
>         spin_lock_init(&priv->ptp_lock);
>
>         netdev_dbg(priv->dev, "Added PTP HW clock successfully\n");
>
>         return 0;
> }
>
> Firstly, you basically reverted the change I did with commit
> efee95f42b ("ptp_clock: future-proofing drivers against PTP subsystem
> becoming optional").  Please have a look at that commit and ponder its
> implications.
>
> Secondly, the error you're actually returning to the caller with your
> patch is actually PTR_ERR(NULL) which is basically a more convoluted way
> to return the same value as what was returned before your patch, which
> is probably not what you intended.
>
> And finally you added a needless initialization of priv->ptp_lock given
> that this was already done a few lines before that addition.
>
> Was this patch actually reviewed?
>
>
> Nicolas
>
