From: "Reshetova, Elena" <elena.reshetova@intel.com>
Subject: RE: [PATCH 06/16] drivers, net, mlx5: convert mlx5_cq.refcount from
 atomic_t to refcount_t
Date: Tue, 28 Mar 2017 14:00:01 +0000
Message-ID: <2236FBA76BA1254E88B949DDB74E612B41C82E54@IRSMSX102.ger.corp.intel.com>
References: <1490691403-4016-1-git-send-email-elena.reshetova@intel.com>
 <1490691403-4016-7-git-send-email-elena.reshetova@intel.com>
 <063D6719AE5E284EB5DD2968C1650D6DCFFBE8AF@AcuExch.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        "linux-arm-kernel@lists.infradead.org"
        <linux-arm-kernel@lists.infradead.org>,
        "linux-rdma@vger.kernel.org" <linux-rdma@vger.kernel.org>,
        "linux-hams@vger.kernel.org" <linux-hams@vger.kernel.org>,
        "linux-ppp@vger.kernel.org" <linux-ppp@vger.kernel.org>,
        "linux-wireless@vger.kernel.org" <linux-wireless@vger.kernel.org>,
        "ganeshgr@chelsio.com" <ganeshgr@chelsio.com>,
        "nbd@openwrt.org" <nbd@openwrt.org>,
        "blogic@openwrt.org" <blogic@openwrt.org>,
        "matthias.bgg@gmail.com" <matthias.bgg@gmail.com>,
        "yishaih@mellanox.com" <yishaih@mellanox.com>,
        "saeedm@mellanox.com" <saeedm@mellanox.com>,
        "matanb@mellanox.com" <matanb@mellanox.com>,
        "leonro@mellanox.com" <leonro@mellanox.com>,
        "ajk@comnets.uni-bremen.de" <aj
To: David Laight <David.Laight@ACULAB.COM>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga05.intel.com ([192.55.52.43]:50113 "EHLO mga05.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751903AbdC1OAJ (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 28 Mar 2017 10:00:09 -0400
In-Reply-To: <063D6719AE5E284EB5DD2968C1650D6DCFFBE8AF@AcuExch.aculab.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


> From: Elena Reshetova
> > Sent: 28 March 2017 09:57
> >
> > refcount_t type and corresponding API should be
> > used instead of atomic_t when the variable is used as
> > a reference counter. This allows to avoid accidental
> > refcounter overflows that might lead to use-after-free
> > situations.
> 
> I can't help feeling that you ought to find a scheme
> that will detect extra decrements and extra increments
> before the counter wraps 32 bits.
> 
> If an extra reference is requested every 100us it takes 4.8 days
> for the counter to increment back to zero.
> Simple tests aren't doing to find that - but it can easily happen
> on a system that is running for several years.

So, you are proposing to try detecting this case instead of preventing overflows?
Not sure how this would look like in a generic form...



> 
> 	David
