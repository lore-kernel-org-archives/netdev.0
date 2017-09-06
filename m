From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: [PATCH net-next] net: cpsw: Don't handle SIOC[GS]HWTSTAMP when
 CPTS is disabled
Date: Wed, 6 Sep 2017 10:59:01 +0200
Message-ID: <20170906085901.qauya3ogfewjcyv3@localhost>
References: <20170830065055.419-1-stefan.sorensen@spectralink.com>
 <20170830.144745.947488279115809130.davem@davemloft.net>
 <20170831074807.3dbbt6qhqxdquipa@localhost>
 <c470bbf2-fadf-88ba-f944-f0b373d211ad@ti.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>,
        stefan.sorensen@spectralink.com, netdev@vger.kernel.org,
        linux-omap@vger.kernel.org
To: Grygorii Strashko <grygorii.strashko@ti.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f194.google.com ([209.85.128.194]:35530 "EHLO
        mail-wr0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752066AbdIFI7G (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 6 Sep 2017 04:59:06 -0400
Content-Disposition: inline
In-Reply-To: <c470bbf2-fadf-88ba-f944-f0b373d211ad@ti.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Sep 05, 2017 at 04:25:22PM -0500, Grygorii Strashko wrote:
> I'd like to clarify one thing here - what is the preferable time-stamping
> device: PHY over MAC, or MAC over PHY? 
> my understanding it's PHY and ethtool_get_ts_info() seems already implemented this way.

We simply do not have a way to support MAC and PHY time stamping and
PTP Hardware Clocks at the same time.  Sure, it must be somehow
possible, but that would involve extending SO_TIMESTAMPING yet again,
and this is not worth the effort, IMHO.

There is exactly one PHY on the market that supports time stamping,
and yes, people who design their boards with it generally want to use
it.  They have to enable CONFIG_NETWORK_PHY_TIMESTAMPING and disable
MAC time stamping.

Thanks,
Richard
