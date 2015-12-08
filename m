From: Shannon Nelson <shannon.nelson@intel.com>
Subject: Re: [RFC 1/1] ethtool: support per queue coalesce options
Date: Tue, 8 Dec 2015 10:17:51 -0800
Message-ID: <CAP-MU4PrJ7xrEmR5k_1qNeXFzybsJMo-SAPX-Us++YokX+zeGQ@mail.gmail.com>
References: <1449549861-12513-1-git-send-email-kan.liang@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>,
	bwh@kernel.org, Jesse Brandeburg <jesse.brandeburg@intel.com>,
	andi@firstfloor.org, f.fainelli@gmail.com,
	alexander.duyck@gmail.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	carolyn.wyborny@intel.com, donald.c.skidmore@intel.com,
	mitch.a.williams@intel.com, ogerlitz@mellanox.com,
	edumazet@google.com, jiri@mellanox.com, sfeldma@gmail.com,
	gospo@cumulusnetworks.com, sasha.levin@oracle.com,
	dsahern@gmail.com, tj@kernel.org, cascardo@redhat.com,
	corbet@lwn.net
To: kan.liang@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f194.google.com ([209.85.223.194]:32892 "EHLO
	mail-io0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751240AbbLHSRv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Dec 2015 13:17:51 -0500
Received: by ioef137 with SMTP id f137so3147704ioe.0
        for <netdev@vger.kernel.org>; Tue, 08 Dec 2015 10:17:51 -0800 (PST)
In-Reply-To: <1449549861-12513-1-git-send-email-kan.liang@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Dec 7, 2015 at 8:44 PM,  <kan.liang@intel.com> wrote:
> From: Kan Liang <kan.liang@intel.com>
>
> Intruduce new coalesce option "queue" to get/set coalesce value to

s/Intruduce/Introduce/

[...]

> diff --git a/ethtool.c b/ethtool.c
> index 92c40b8..7c644db 100644
> --- a/ethtool.c
> +++ b/ethtool.c
> @@ -1178,6 +1178,12 @@ static int dump_channels(const struct ethtool_channels *echannels)
>
>  static int dump_coalesce(const struct ethtool_coalesce *ecoal)
>  {
> +       if (ecoal->queue < 0)
> +               fprintf(stdout, "Queue: All\n");

If some queues have been given different settings, then "All" is
rather misleading, and there seems to be no way to indicate that some
queues have separate settings.

sln
