From: Cong Wang <cwang@twopensource.com>
Subject: Re: [PATCH net] net/mlx4_en: mlx4_en_netpoll shouldn't call
 napi_schedule when port is down
Date: Mon, 29 Sep 2014 09:47:30 -0700
Message-ID: <CAHA+R7O_QicCpZNpWzWGD_bGD7i4-ySVjV5UuUVpF8EMsohsPg@mail.gmail.com>
References: <1411988695-30547-1-git-send-email-amirv@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "David S. Miller" <davem@davemloft.net>,
	Ido Shamay <idos@mellanox.com>,
	netdev <netdev@vger.kernel.org>,
	Yevgeny Petrilin <yevgenyp@mellanox.com>,
	Or Gerlitz <ogerlitz@mellanox.com>
To: Amir Vadai <amirv@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f49.google.com ([209.85.215.49]:50994 "EHLO
	mail-la0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754070AbaI2Qrc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 29 Sep 2014 12:47:32 -0400
Received: by mail-la0-f49.google.com with SMTP id ge10so3756842lab.8
        for <netdev@vger.kernel.org>; Mon, 29 Sep 2014 09:47:30 -0700 (PDT)
In-Reply-To: <1411988695-30547-1-git-send-email-amirv@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Sep 29, 2014 at 4:04 AM, Amir Vadai <amirv@mellanox.com> wrote:
> From: Ido Shamay <idos@mellanox.com>
>
> mlx4_en_netpoll, which is mlx4_en ndo_poll_controller callback,
> might be called when port is down, causing a napi_schedule when
> napi->poll callback in NULL. mutex_trylock is needed to acquire
> the port_state lock, since other threads may grab it and stop
> the port while we are in napi scheduling. Using trylock since in atomic
> context.

Are you sure it's safe? Its comment says:

 * This function must not be used in interrupt context. The
 * mutex must be released by the same task that acquired it.

Did you test it with LOCKDEP enabled?
