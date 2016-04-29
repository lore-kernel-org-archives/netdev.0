From: Saeed Mahameed <saeedm@dev.mellanox.co.il>
Subject: Re: [PATCH net-next V1 00/11] Mellanox 100G extending mlx5 ethtool support
Date: Fri, 29 Apr 2016 23:27:06 +0300
Message-ID: <CALzJLG_a4s54MwCzOHMeCp0i5F5pyb-PHY_AFA-ok2JT5S62wQ@mail.gmail.com>
References: <1461527516-29290-1-git-send-email-saeedm@mellanox.com>
 <20160426.160301.938979848864279754.davem@davemloft.net> <CALzJLG-BJvB7h2wAOqy8ibDdkw7Croaiy7+QU9izrcivuS1yOg@mail.gmail.com>
 <20160426.174150.2239494413467110.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Saeed Mahameed <saeedm@mellanox.com>,
	Linux Netdev List <netdev@vger.kernel.org>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Tal Alon <talal@mellanox.com>,
	Eran Ben Elisha <eranbe@mellanox.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f170.google.com ([209.85.161.170]:33301 "EHLO
	mail-yw0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752781AbcD2U10 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 Apr 2016 16:27:26 -0400
Received: by mail-yw0-f170.google.com with SMTP id t10so209038010ywa.0
        for <netdev@vger.kernel.org>; Fri, 29 Apr 2016 13:27:26 -0700 (PDT)
In-Reply-To: <20160426.174150.2239494413467110.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Apr 27, 2016 at 12:41 AM, David Miller <davem@davemloft.net> wrote:
> From: Saeed Mahameed <saeedm@dev.mellanox.co.il>
> Date: Tue, 26 Apr 2016 23:55:03 +0300
>
>> It will be a nightmare to rollback in such case.  What if the rollback failed ?
>
> It is absolutely essential to handle this properly.
>
> Which means you must have a prepare/commit model, wherein the prepare
> phase makes sure to pre-allocate all necessary resources, and only if
> all the prepare phase preparations succeed will the commit phase run.
>
> The commit phase cannot error, because all of the resources have been
> allocated successfully already.
>
> This way there are no issues of "rolling back" because you never
> actually move the state forward until you can guarantee that you can
> do everything.

Right, for pure software/kernel resources this is the right way to go,
Actually we already have a patch that is similar of what you described,
we are aiming to push it towards 4.8.

but my concerns is when features A and B requires firmware commands A then B
and firmware command B fails, there is no gurantee that roll back for
firmware command A will work.

this is why in case of B fails we keep the state (new A and prev B)
rather than try to go back to (prev A and prev B).
