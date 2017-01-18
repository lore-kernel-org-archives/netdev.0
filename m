From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [PATCH v2 net-next] net:add one common config
 ARCH_WANT_RELAX_ORDER to support relax ordering.
Date: Wed, 18 Jan 2017 16:22:01 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6DB0266CD6@AcuExch.aculab.com>
References: <1483939954-9864-1-git-send-email-maowenan@huawei.com>
 <20170117.141533.680344033700095483.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "jeffrey.t.kirsher@intel.com" <jeffrey.t.kirsher@intel.com>,
        "alexander.duyck@gmail.com" <alexander.duyck@gmail.com>
To: 'David Miller' <davem@davemloft.net>,
        "maowenan@huawei.com" <maowenan@huawei.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out6.electric.net ([192.162.217.188]:53828 "EHLO
        smtp-out6.electric.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752792AbdARQWK (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 18 Jan 2017 11:22:10 -0500
In-Reply-To: <20170117.141533.680344033700095483.davem@davemloft.net>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Miller
> Sent: 17 January 2017 19:16
> > Relax ordering(RO) is one feature of 82599 NIC, to enable this feature can
> > enhance the performance for some cpu architecure, such as SPARC and so on.
> > Currently it only supports one special cpu architecture(SPARC) in 82599
> > driver to enable RO feature, this is not very common for other cpu architecture
> > which really needs RO feature.
> > This patch add one common config CONFIG_ARCH_WANT_RELAX_ORDER to set RO feature,
> > and should define CONFIG_ARCH_WANT_RELAX_ORDER in sparc Kconfig firstly.
> >
> > Signed-off-by: Mao Wenan <maowenan@huawei.com>
> 
> Since no-one has reviewed this patch, and I do not feel comfortable with applying
> it without such review, I am tossing this patch.
> 
> If someone eventually reviews it, repost this patch.

Having re-read parts of the PCIe spec I think I'd like someone to
explain exactly which transfers are affected by the 'relaxed ordering'
bit and why any re-ordered transactions aren't a problem.

In particular I believe RO allows the write to update the receive
descriptor ring to overtake a write of receive packet data.
That could lead to the network stack processing a receive frame
before it has actually been written.

	David
