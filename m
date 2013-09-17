From: Francesco Ruggeri <fruggeri@aristanetworks.com>
Subject: Re: [CFT][PATCH] net: Delay default_device_exit_batch until no
 devices are unregistering
Date: Tue, 17 Sep 2013 10:14:31 -0700
Message-ID: <CA+HUmGij5oFZCDWoXcdmQm+WhZCMr+tQZ600K=ORFx5tRFuSag@mail.gmail.com>
References: <1379008796-2121-1-git-send-email-fruggeri@aristanetworks.com>
	<87txhp249u.fsf@xmission.com>
	<CA+HUmGgyCsc-er6iB_mqg9whMyaquGWinkHOQEuEHbFCYVrXBw@mail.gmail.com>
	<871u4t1d9t.fsf@xmission.com>
	<CA+HUmGjEC8eXT7BHm20uVOagJQbsqO9VZjmGSgmUvnrtEH-JYw@mail.gmail.com>
	<87d2ocrx9b.fsf@xmission.com>
	<CA+HUmGifVOs+d=hs2rTUmMyyK17xfBFFbO8sY=rjS2D=RxFLZg@mail.gmail.com>
	<87six5kpu5.fsf@xmission.com>
	<CA+HUmGih9akzhpRrb_0WEapi4jGcuSV8qO==QeRWHoqnxzFyng@mail.gmail.com>
	<87mwncaz04.fsf_-_@xmission.com>
	<CA+HUmGjg9jE1fjSMgkfVtiWVRD3d2DuwfbPU3Owrk_cTCe0FQA@mail.gmail.com>
	<87mwnb949b.fsf@xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>,
	Jiri Pirko <jiri@resnulli.us>,
	Alexander Duyck <alexander.h.duyck@intel.com>,
	Cong Wang <amwang@redhat.com>, netdev@vger.kernel.org
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vb0-f54.google.com ([209.85.212.54]:41345 "EHLO
	mail-vb0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753584Ab3IQROc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Sep 2013 13:14:32 -0400
Received: by mail-vb0-f54.google.com with SMTP id q14so4365001vbe.13
        for <netdev@vger.kernel.org>; Tue, 17 Sep 2013 10:14:31 -0700 (PDT)
In-Reply-To: <87mwnb949b.fsf@xmission.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>
> If you could test this patch perhaps refine it I think we are almost at
> a final point of fixing this.
>
I will.

> Just to be clear my reason for prefering this approach is that because
> it adds no extra wait points (we already wait for the rtnl_lock), the
> logic is unconditional and explicit and not hidden in the loopback
> device's reference count.  Which should allow anyone reading the code
> to discover and understand this guarantee.  Although a big fat comment
> in default_device_exit_batch that we are guaranteeing we don't allow
> the network namespace to exit while there are still network devices in
> it (or something to that effect) is probably appropriate.

I agree, this approach is cleaner than overloading loopback_dev's
refcount as in my original patch.
I will let you know how my tests go over the next few days.

Thanks,
Francesco


>
> Eric
>
