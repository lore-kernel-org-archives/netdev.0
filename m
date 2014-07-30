From: Eli Cohen <eli@dev.mellanox.co.il>
Subject: Re: [PATCH net-next 1/3] mlx5: Move pci device handling from mlx5_ib
 to mlx5_core
Date: Wed, 30 Jul 2014 13:26:15 +0300
Message-ID: <20140730102615.GA24716@mtldesk30>
References: <1406579424-16213-1-git-send-email-eli@mellanox.com>
 <1406579424-16213-2-git-send-email-eli@mellanox.com>
 <CAJZOPZLyhh6pGSwFHOe8oCc4a3xVTdCHric6sH78Kz5Dr7NvLw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Roland Dreier <roland@kernel.org>,
	Jack Morgenstein <jackm@dev.mellanox.co.il>,
	Eli Cohen <eli@mellanox.com>,
	Yevgeny Petrilin <yevgenyp@mellanox.com>
To: Or Gerlitz <or.gerlitz@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f179.google.com ([209.85.212.179]:41820 "EHLO
	mail-wi0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751223AbaG3K0V (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Jul 2014 06:26:21 -0400
Received: by mail-wi0-f179.google.com with SMTP id f8so2046432wiw.12
        for <netdev@vger.kernel.org>; Wed, 30 Jul 2014 03:26:20 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <CAJZOPZLyhh6pGSwFHOe8oCc4a3xVTdCHric6sH78Kz5Dr7NvLw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jul 28, 2014 at 11:57:37PM +0300, Or Gerlitz wrote:
> 
> You need to issue a warning here if someone attempts to change the
> previously default value of the now deprecated module param. E.g warn
> this is deprecated and point them to mlx5_core
> 

It is handled in the module init function:

static int __init mlx5_ib_init(void)
{
-       return pci_register_driver(&mlx5_ib_driver);
+       if (deprecated_prof_sel != 2)
+               pr_warn("prof_sel is deprecated for mlx5_ib, set it
for mlx5_core\n");
+
+       return mlx5_register_interface(&mlx5_ib_interface);
}
