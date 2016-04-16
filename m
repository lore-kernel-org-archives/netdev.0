From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [PATCH] devlink: fix devlink_sb_register prototype
Date: Sat, 16 Apr 2016 23:00:19 +0200
Message-ID: <20160416210018.GF1954@nanopsycho.orion>
References: <1460838446-1246570-1-git-send-email-arnd@arndb.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jiri Pirko <jiri@mellanox.com>,
	"David S. Miller" <davem@davemloft.net>,
	Ido Schimmel <idosch@mellanox.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Arnd Bergmann <arnd@arndb.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f51.google.com ([74.125.82.51]:38612 "EHLO
	mail-wm0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751310AbcDPVAW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 16 Apr 2016 17:00:22 -0400
Received: by mail-wm0-f51.google.com with SMTP id u206so74865377wme.1
        for <netdev@vger.kernel.org>; Sat, 16 Apr 2016 14:00:21 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1460838446-1246570-1-git-send-email-arnd@arndb.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Sat, Apr 16, 2016 at 10:27:06PM CEST, arnd@arndb.de wrote:
>The devlink shared buffer interface contains two different
>prototypes for devlink_sb_register, and the one that is
>used when NET_DEVLINK is disabled does not work:
>
>drivers/net/ethernet/mellanox/mlxsw/spectrum_buffers.c: In function 'mlxsw_sp_buffers_init':
>drivers/net/ethernet/mellanox/mlxsw/spectrum_buffers.c:547:9: error: too many arguments to function 'devlink_sb_register'
>  return devlink_sb_register(priv_to_devlink(mlxsw_sp->core), 0,
>
>This makes the two prototypes have the same argument list.
>
>Signed-off-by: Arnd Bergmann <arnd@arndb.de>
>Fixes: bf7974710a40 ("devlink: add shared buffer configuration")

Already fixed by:

commit de33efd0fb7f923cd41671b1f743c3a0d44dd953
Author: Jiri Pirko <jiri@mellanox.com>
Date:   Fri Apr 15 09:17:08 2016 +0200

    devlink: fix sb register stub in case devlink is disabled
