From: Roland Dreier <rdreier@cisco.com>
Subject: Re: [PATCH RFC 02/10] mlx4_en: Device initialization
Date: Tue, 15 Jul 2008 12:21:51 -0700
Message-ID: <adawsjndkc0.fsf@cisco.com>
References: <487B6571.8000602@mellanox.co.il>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jeff@garzik.org, netdev@vger.kernel.org,
	Liran Liss <liranl@mellanox.co.il>, tziporet@mellanox.co.il
To: Yevgeny Petrilin <yevgenyp@mellanox.co.il>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sj-iport-3.cisco.com ([171.71.176.72]:56233 "EHLO
	sj-iport-3.cisco.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755057AbYGOTZ4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Jul 2008 15:25:56 -0400
In-Reply-To: <487B6571.8000602@mellanox.co.il> (Yevgeny Petrilin's message of
	"Mon, 14 Jul 2008 17:40:49 +0300")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

 > +	/* Create a netdev for each port */
 > +	mlx4_foreach_port(i, mdev->ports_map) {
 > +		mlx4_info(mdev, "Activating port:%d\n", i);
 > +		if (mlx4_en_init_netdev(mdev, i, &mdev->profile.prof[i])) {
 > +			mdev->pndev[i] = NULL;
 > +			goto err_free_netdev;
 > +		}
 > +	}
 > +	return mdev;
 > +
 > +
 > +err_free_netdev:
 > +	for (i = 0; i < dev->caps.num_ports; i++) {
 > +		if (mdev->pndev[i])
 > +			mlx4_en_destroy_netdev(mdev->pndev[i]);
 > +	}

There's a strange asymmetry between the mlx4_foreach_port() loop and the
for () loop here.
