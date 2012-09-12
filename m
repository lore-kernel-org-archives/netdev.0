From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next V3 1/2] IB/ipoib: Add rtnl_link_ops support
Date: Wed, 12 Sep 2012 17:13:43 +0200
Message-ID: <1347462823.13103.1085.camel@edumazet-glaptop>
References: <1345724119-32110-1-git-send-email-ogerlitz@mellanox.com>
	 <1345724119-32110-2-git-send-email-ogerlitz@mellanox.com>
	 <Pine.GSO.4.63.1208291450330.1098@stinky-local.trash.net>
	 <5050668B.1010105@mellanox.com>
	 <CAKoUAr=8zZA9EgvJEVrd0a-Uw=zzksHj+5P2Sp3Lb4vXgSJRYA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Or Gerlitz <ogerlitz@mellanox.com>,
	Patrick McHardy <kaber@trash.net>, netdev@vger.kernel.org,
	Shlomo Pongratz <shlomop@mellanox.com>
To: Rami Rosen <roszenrami@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ey0-f174.google.com ([209.85.215.174]:60628 "EHLO
	mail-ey0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752847Ab2ILPNt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Sep 2012 11:13:49 -0400
Received: by eaac11 with SMTP id c11so914340eaa.19
        for <netdev@vger.kernel.org>; Wed, 12 Sep 2012 08:13:47 -0700 (PDT)
In-Reply-To: <CAKoUAr=8zZA9EgvJEVrd0a-Uw=zzksHj+5P2Sp3Lb4vXgSJRYA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2012-09-12 at 17:53 +0300, Rami Rosen wrote:
> Hi,
> 
> From the dump of CPU #1, it seems indeed not related at all to "modprobe -r".
> 
> Could it be that there is some IB stack sysfs write activity?
> (regardless of the modprobe -r" you issued) ?  I see some candidates
> for it.
> 
> delete_child() is a method of the IB stack (ipoib/ipoib_main.c)
> 
> Maybe in order to help debug the problem, you might try to add in
> delete_child() method, print of the name of the attribute which is
> being deleted ?
> 
>   (struct device_attribute has a a member "struct attribute attr",
> which in turn has  "const char *name").


It might be related to module load/unload

udevd or some external daemon can access sysfs files while you unload
the module
