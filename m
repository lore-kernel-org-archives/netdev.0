From: Tom Herbert <tom@herbertland.com>
Subject: Default XPS settings in mlx4 driver
Date: Tue, 19 May 2015 13:38:35 -0700
Message-ID: <CALx6S36qXcqhfFQVLWu2CgoJYQL6E-myvgBvDFxATA+NjX+qBA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Amir Vadai <amirv@mellanox.com>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Ido Shamay <idos@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f169.google.com ([209.85.213.169]:37641 "EHLO
	mail-ig0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750734AbbESUif (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 May 2015 16:38:35 -0400
Received: by igbsb11 with SMTP id sb11so24067911igb.0
        for <netdev@vger.kernel.org>; Tue, 19 May 2015 13:38:35 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Ido,

I'm looking at your patch "net/mlx4_en: Configure the XPS queue
mapping on driver load". We're testing a 40 CPU system and it looks
like XPS is being configured by default with forty queues 0-39 where
each xps_cpus is (1 << i). The problem is that this does not easily
align with RX queues and the TX completion interrupt for TX queue z
happens in interrupt for (z % num_rx_queues). So it looks like, the
default XPS doesn't respect the RX interrupt affinities, so we have TX
queues that are bound to a CPU on one numa node but have their TX
completions happen on another which is suboptimal. It would be nice if
the default XPS could take where the completion interrupt happens into
account somehow.

Looks like there's a few other drivers that are setting XPS, they
might have similar issue.

Thanks,
Tom
