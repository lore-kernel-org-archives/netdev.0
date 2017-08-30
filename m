From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net: cpsw: Don't handle SIOC[GS]HWTSTAMP when
 CPTS is disabled
Date: Wed, 30 Aug 2017 14:47:45 -0700 (PDT)
Message-ID: <20170830.144745.947488279115809130.davem@davemloft.net>
References: <20170830065055.419-1-stefan.sorensen@spectralink.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: 8BIT
Cc: grygorii.strashko@ti.com, netdev@vger.kernel.org,
        linux-omap@vger.kernel.org
To: stefan.sorensen@spectralink.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:34532 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751291AbdH3Vrq (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 30 Aug 2017 17:47:46 -0400
In-Reply-To: <20170830065055.419-1-stefan.sorensen@spectralink.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stefan Sørensen <stefan.sorensen@spectralink.com>
Date: Wed, 30 Aug 2017 08:50:55 +0200

> There is no reason to handle SIOC[GS]HWTSTAMP and return -EOPNOTSUPP when
> CPTS is disabled, so just pass them on to the phy. This will allow PTP
> timestamping on a capable phy by disabling CPTS.
> 
> Signed-off-by: Stefan Sørensen <stefan.sorensen@spectralink.com>

It should not be required to disable a Kconfig option just to get PHY
timestamping to work properly.

Rather, if the CPTS code returns -EOPNOTSUPP we should try to
fallthrough to the PHY library based methods.

Thanks.
