From: Rami Rosen <roszenrami@gmail.com>
Subject: Re: [PATCH v4 net-next 4/6] drivers: net: xgene-v2: Add base driver
Date: Wed, 8 Mar 2017 05:43:04 +0200
Message-ID: <CAKoUArkOj-RvWZB-Gy6GC2C3yHFvsEGgoauQcAxYhBAurdjH0A@mail.gmail.com>
References: <1488935325-13603-1-git-send-email-isubramanian@apm.com> <1488935325-13603-5-git-send-email-isubramanian@apm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
        Netdev <netdev@vger.kernel.org>, andrew@lunn.ch,
        Florian Fainelli <f.fainelli@gmail.com>,
        David.Laight@aculab.com, linux-arm-kernel@lists.infradead.org,
        patches@apm.com, kchudgar@apm.com
To: Iyappan Subramanian <isubramanian@apm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f67.google.com ([209.85.214.67]:33544 "EHLO
        mail-it0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S933575AbdCHDnG (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 7 Mar 2017 22:43:06 -0500
Received: by mail-it0-f67.google.com with SMTP id g138so2936600itb.0
        for <netdev@vger.kernel.org>; Tue, 07 Mar 2017 19:43:05 -0800 (PST)
In-Reply-To: <1488935325-13603-5-git-send-email-isubramanian@apm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,
One minor comment:

The return type of xge_init_hw() should be changed to be void, as
the method xge_port_reset() always returns 0;  and also the return type
of xge_port_reset() should be changed to be void, it never fails; see
in [PATCH v4 net-next 3/6] drivers: net: xgene-v2: Add ethernet
hardware configuration.


+static int xge_init_hw(struct net_device *ndev)
+{
+       struct xge_pdata *pdata = netdev_priv(ndev);
+       int ret;
+
+       ret = xge_port_reset(ndev);
+       if (ret)
+               return ret;
+
+       xge_port_init(ndev);
+       pdata->nbufs = NUM_BUFS;
+
+       return 0;
+}

Regards,
Rami Rosen
