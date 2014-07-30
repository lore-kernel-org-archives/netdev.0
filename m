From: Or Gerlitz <or.gerlitz@gmail.com>
Subject: Re: [PATCH net-next 1/3] mlx5: Move pci device handling from mlx5_ib
 to mlx5_core
Date: Wed, 30 Jul 2014 23:57:51 +0300
Message-ID: <CAJZOPZJPQNH5Nxg0hrrfSfV05ALqH3SdV0=dHYKq9jduivMS1g@mail.gmail.com>
References: <1406579424-16213-1-git-send-email-eli@mellanox.com>
	<1406579424-16213-2-git-send-email-eli@mellanox.com>
	<CAJZOPZLyhh6pGSwFHOe8oCc4a3xVTdCHric6sH78Kz5Dr7NvLw@mail.gmail.com>
	<20140730102615.GA24716@mtldesk30>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Roland Dreier <roland@kernel.org>,
	Jack Morgenstein <jackm@dev.mellanox.co.il>,
	Eli Cohen <eli@mellanox.com>,
	Yevgeny Petrilin <yevgenyp@mellanox.com>
To: Eli Cohen <eli@dev.mellanox.co.il>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qg0-f48.google.com ([209.85.192.48]:48932 "EHLO
	mail-qg0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751309AbaG3U5w (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Jul 2014 16:57:52 -0400
Received: by mail-qg0-f48.google.com with SMTP id i50so2656008qgf.35
        for <netdev@vger.kernel.org>; Wed, 30 Jul 2014 13:57:51 -0700 (PDT)
In-Reply-To: <20140730102615.GA24716@mtldesk30>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jul 30, 2014 at 1:26 PM, Eli Cohen <eli@dev.mellanox.co.il> wrote:
>
> On Mon, Jul 28, 2014 at 11:57:37PM +0300, Or Gerlitz wrote:
> >
> > You need to issue a warning here if someone attempts to change the
> > previously default value of the now deprecated module param. E.g warn
> > this is deprecated and point them to mlx5_core
> >
>
> It is handled in the module init function:



Oh, I see it now, well done.

Or.

>
>
> static int __init mlx5_ib_init(void)
> {
> -       return pci_register_driver(&mlx5_ib_driver);
> +       if (deprecated_prof_sel != 2)
> +               pr_warn("prof_sel is deprecated for mlx5_ib, set it
> for mlx5_core\n");
> +
> +       return mlx5_register_interface(&mlx5_ib_interface);
> }
>
