From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH net-next] enic: use kasprintf instead of snprintf
Date: Sun, 18 Jun 2017 22:40:52 -0700
Message-ID: <1497850852.8495.41.camel@perches.com>
References: <20170619050537.6393-1-gvaradar@cisco.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8bit
Cc: benve@cisco.com
To: Govindarajulu Varadarajan <gvaradar@cisco.com>,
        davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtprelay0166.hostedemail.com ([216.40.44.166]:50854 "EHLO
        smtprelay.hostedemail.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1750895AbdFSFkz (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 19 Jun 2017 01:40:55 -0400
In-Reply-To: <20170619050537.6393-1-gvaradar@cisco.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 2017-06-18 at 22:05 -0700, Govindarajulu Varadarajan wrote:
> With -Wformat-truncation=, gcc throws the following warning. Instead of
> using snprintf, use kasprintf and allocate string size as needed.
> 
> drivers/net/ethernet/cisco/enic/enic_main.c: In function ‘enic_open’:
> drivers/net/ethernet/cisco/enic/enic_main.c:1740:15: warning: ‘%u’ directive output may be truncated writing between 1 and 2 bytes into a region of size between 1 and 12 [-Wformat-truncation=]
>      "%.11s-rx-%u", netdev->name, i);
>                ^~
> drivers/net/ethernet/cisco/enic/enic_main.c:1740:5: note: directive argument in the range [0, 16]
>      "%.11s-rx-%u", netdev->name, i);
>      ^~~~~~~~~~~~~
> drivers/net/ethernet/cisco/enic/enic_main.c:1738:4: note: ‘snprintf’ output between 6 and 18 bytes into a destination of size 16
>     snprintf(enic->msix[intr].devname,
>     ^~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
>      sizeof(enic->msix[intr].devname),
>      ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
>      "%.11s-rx-%u", netdev->name, i);
>      ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
> drivers/net/ethernet/cisco/enic/enic_main.c:1751:5: warning: ‘snprintf’ output may be truncated before the last format character [-Wformat-truncation=]
>      "%.11s-tx-%u", netdev->name, i);


Perhaps it'd be better to use a style
with a variable length format precision

ie:

	"%.*s-tx-%u", IFNAMSIZ - 4 - <something>, netdev-name, i)
