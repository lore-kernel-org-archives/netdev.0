From: Michal Kubecek <mkubecek@suse.cz>
Subject: Re: Order of interfaces in output of ip link
Date: Wed, 3 Sep 2014 07:43:35 +0200
Message-ID: <20140903054335.GA32737@unicorn.suse.cz>
References: <19313218.dxlnVqzEMb@hp>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Ovidiu Mara <ovidiu.mara@epfl.ch>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from cantor2.suse.de ([195.135.220.15]:54361 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751209AbaICFni (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 3 Sep 2014 01:43:38 -0400
Content-Disposition: inline
In-Reply-To: <19313218.dxlnVqzEMb@hp>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Sep 02, 2014 at 04:27:42PM +0200, Ovidiu Mara wrote:
> The ip command shows the interfaces on this machine in an unnatural order (eth0 followed by eth2 then eth1).
> ...
> 2: eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc mq state UP mode DEFAULT group default qlen 1000\    link/ether 2c:59:e5:9a:4c:a4 brd ff:ff:ff:ff:ff:ff
> 3: eth2: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc mq state UP mode DEFAULT group default qlen 1000\    link/ether ac:16:2d:98:9e:d8 brd ff:ff:ff:ff:ff:ff
> 4: eth1: <NO-CARRIER,BROADCAST,MULTICAST,UP> mtu 1500 qdisc mq state DOWN mode DEFAULT group default qlen 1000\    link/ether 2c:59:e5:9a:4c:a5 brd ff:ff:ff:ff:ff:ff
> 5: eth3: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc mq state UP mode DEFAULT group default qlen 1000\    link/ether ac:16:2d:98:9e:d9 brd ff:ff:ff:ff:ff:ff
> ...
> eth0 and eth1 are two ports on the same network card, so I would
> expect them to be shown together, as they are numbered.

In general, you can't expect that. As drivers can initialize in
parallel, it happens quite often that interfaces are interleaved like
this. Actually, the names are probably misleading here: most likely the
interface with index 3 was named "eth1" by kernel and interface with
index 4 was named eth2 but udev changed the names.

> Could you please tell me if there is any workaround for this?

It depends on what exactly you want to achieve and why. But AFAIK ip
documentation doesn't promise any particular order of the interfaces so
it's wrong to assume any.

                                                        Michal Kubecek
