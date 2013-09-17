From: Francesco Ruggeri <fruggeri@aristanetworks.com>
Subject: Re: [PATCH 1/1] net: race condition when removing virtual net_device
Date: Mon, 16 Sep 2013 22:12:35 -0700
Message-ID: <CA+HUmGhmx_nAnvV4wyZ0Un-E9MZwbHRV7c=eCBBoJ+im+z1oew@mail.gmail.com>
References: <1379008796-2121-1-git-send-email-fruggeri@aristanetworks.com>
	<87txhp249u.fsf@xmission.com>
	<CA+HUmGgyCsc-er6iB_mqg9whMyaquGWinkHOQEuEHbFCYVrXBw@mail.gmail.com>
	<871u4t1d9t.fsf@xmission.com>
	<CA+HUmGjEC8eXT7BHm20uVOagJQbsqO9VZjmGSgmUvnrtEH-JYw@mail.gmail.com>
	<87d2ocrx9b.fsf@xmission.com>
	<CA+HUmGifVOs+d=hs2rTUmMyyK17xfBFFbO8sY=rjS2D=RxFLZg@mail.gmail.com>
	<87six5kpu5.fsf@xmission.com>
	<CA+HUmGih9akzhpRrb_0WEapi4jGcuSV8qO==QeRWHoqnxzFyng@mail.gmail.com>
	<87r4cocn0n.fsf@xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>,
	Jiri Pirko <jiri@resnulli.us>,
	Alexander Duyck <alexander.h.duyck@intel.com>,
	Cong Wang <amwang@redhat.com>, netdev@vger.kernel.org
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vb0-f53.google.com ([209.85.212.53]:45466 "EHLO
	mail-vb0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751739Ab3IQFMg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Sep 2013 01:12:36 -0400
Received: by mail-vb0-f53.google.com with SMTP id i3so3710739vbh.12
        for <netdev@vger.kernel.org>; Mon, 16 Sep 2013 22:12:35 -0700 (PDT)
In-Reply-To: <87r4cocn0n.fsf@xmission.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Sep 16, 2013 at 5:25 PM, Eric W. Biederman
<ebiederm@xmission.com> wrote:

>
> If you could verify that my patch to dev_close solves the ordering
> issues you were seeing I would appreciate that.
>

I have not run extensive tests, but your patch fixes the reordering
issue I was seeing in dev_close_many. When I destroyed a namespace
with only v0 and lo the order was preserved from
unregister_netdevice_many to netdev_run_todo.

Francesco

====== lo down, v0 down
unregister_netdevice_queue: v0 (ns ffff880136bc8000)
unregister_netdevice_queue: lo (ns ffff880136bc8000)
unregister_netdevice_many: v0 (ns ffff880136bc8000) lo (ns ffff880136bc8000)
netdev_run_todo: v0 (ns ffff880136bc8000) lo (ns ffff880136bc8000)

====== lo up, v0 down
unregister_netdevice_queue: v0 (ns ffff880037ac8000)
unregister_netdevice_queue: lo (ns ffff880037ac8000)
unregister_netdevice_many: v0 (ns ffff880037ac8000) lo (ns ffff880037ac8000)
netdev_run_todo: v0 (ns ffff880037ac8000) lo (ns ffff880037ac8000)


====== lo down, v0 up
unregister_netdevice_queue: v0 (ns ffff880136bc8000)
unregister_netdevice_queue: lo (ns ffff880136bc8000)
unregister_netdevice_many: v0 (ns ffff880136bc8000) lo (ns ffff880136bc8000)
netdev_run_todo: v0 (ns ffff880136bc8000) lo (ns ffff880136bc8000)


====== lo up, v0 up
unregister_netdevice_queue: v0 (ns ffff880037ac8000)
unregister_netdevice_queue: lo (ns ffff880037ac8000)
unregister_netdevice_many: v0 (ns ffff880037ac8000) lo (ns ffff880037ac8000)
netdev_run_todo: v0 (ns ffff880037ac8000) lo (ns ffff880037ac8000)
