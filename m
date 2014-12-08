From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [PATCH net-next V1] net/mlx4_en: ethtool force speed when
 asking for autoneg=off
Date: Mon, 8 Dec 2014 10:56:30 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6D1CA04B67@AcuExch.aculab.com>
References: <1417969655-28028-1-git-send-email-amirv@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Yevgeny Petrilin <yevgenyp@mellanox.com>,
	"Saeed Mahameed" <saeedm@mellanox.com>
To: 'Amir Vadai' <amirv@mellanox.com>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0.aculab.com ([213.249.233.131]:36321 "HELO mx0.aculab.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1755130AbaLHK52 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Dec 2014 05:57:28 -0500
Received: from mx0.aculab.com ([127.0.0.1])
 by localhost (mx0.aculab.com [127.0.0.1]) (amavisd-new, port 10024) with SMTP
 id 17454-02 for <netdev@vger.kernel.org>;
 Mon,  8 Dec 2014 10:57:15 +0000 (GMT)
In-Reply-To: <1417969655-28028-1-git-send-email-amirv@mellanox.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Amir Vadai
> From: Saeed Mahameed <saeedm@mellanox.com>
> 
> Use cmd->autoneg == AUTONEG_DISABLE as a user hint to force specific speed.
> We don't want to rely on ethtool to calculate advertised link modes when
> forcing specific speed, a user can request a specific speed and specify
> "autoneg off" in ethtool command to give a hint for forcing this speed.

I'm not 100% sure what you are trying to achieve?

By far the safest way to 'force' a specific speed is to set the
advertised modes to contain only the desired speed.
Doing anything else on links that are capable of auto-negotiation
is a complete recipe for disaster.

Even if you fix the operating mode of the PHY and MAC you almost
certainly want to advertise that mode to the remote system.

Yes, I know this is made all the more complicated by 10/100M autodetect.

	David
