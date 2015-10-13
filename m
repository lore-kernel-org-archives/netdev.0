From: Scott Feldman <sfeldma@gmail.com>
Subject: Re: [patch net-next v4 4/7] switchdev: introduce possibility to defer obj_add/del
Date: Mon, 12 Oct 2015 20:08:23 -0700
Message-ID: <CAE4R7bBkO=mcMQ-Pbns5kq4gcjZNqpZz1_-snn89bnfGdqzVcw@mail.gmail.com>
References: <1444672467-20621-1-git-send-email-jiri@resnulli.us>
 <1444672986-20709-1-git-send-email-jiri@resnulli.us> <1444672986-20709-3-git-send-email-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Netdev <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	Ido Schimmel <idosch@mellanox.com>,
	Elad Raz <eladr@mellanox.com>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Guenter Roeck <linux@roeck-us.net>,
	Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
	"andrew@lunn.ch" <andrew@lunn.ch>,
	john fastabend <john.fastabend@gmail.com>,
	David Laight <David.Laight@aculab.com>,
	"stephen@networkplumber.org" <stephen@networkplumber.org>
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f182.google.com ([209.85.214.182]:36172 "EHLO
	mail-ob0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751009AbbJMDIn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 Oct 2015 23:08:43 -0400
Received: by obbrx8 with SMTP id rx8so3695811obb.3
        for <netdev@vger.kernel.org>; Mon, 12 Oct 2015 20:08:42 -0700 (PDT)
In-Reply-To: <1444672986-20709-3-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Oct 12, 2015 at 11:03 AM, Jiri Pirko <jiri@resnulli.us> wrote:
> From: Jiri Pirko <jiri@mellanox.com>
>
> Similar to the attr usecase, the caller knows if he is holding RTNL and is
> in atomic section. So let the called to decide the correct call variant.
>
> This allows drivers to sleep inside their ops and wait for hw to get the
> operation status. Then the status is propagated into switchdev core.
> This avoids silent errors in drivers.
>
> Signed-off-by: Jiri Pirko <jiri@mellanox.com>

<snip>

> +static void switchdev_port_obj_work(struct work_struct *work)
> +{
> +       struct switchdev_obj_work *ow =
> +                       container_of(work, struct switchdev_obj_work, work);
> +       bool rtnl_locked = rtnl_is_locked();
> +       int err;
> +
> +       if (!rtnl_locked)
> +               rtnl_lock();

Same comment as on patch 2/7 about not unconditionally grabbing rtnl_lock.
