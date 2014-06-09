From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] net: force a list_del() in
 unregister_netdevice_many()
Date: Sun, 08 Jun 2014 22:48:00 -0700
Message-ID: <1402292880.3645.340.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1401840715-16375-1-git-send-email-xiyou.wangcong@gmail.com>
		 <1401840715-16375-2-git-send-email-xiyou.wangcong@gmail.com>
		 <1401842581.3645.241.camel@edumazet-glaptop2.roam.corp.google.com>
		 <CAM_iQpWeq6a+ighGoLXqDp06t+D97adFrtRpM+ACqtf3J4SUNg@mail.gmail.com>
		 <1402060661.3645.289.camel@edumazet-glaptop2.roam.corp.google.com>
	 <1402062243.3645.295.camel@edumazet-glaptop2.roam.corp.google.com>
	 <53950D7C.5060001@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Cong Wang <xiyou.wangcong@gmail.com>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>
To: Gao feng <gaofeng@cn.fujitsu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f178.google.com ([209.85.192.178]:52573 "EHLO
	mail-pd0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750796AbaFIFsD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Jun 2014 01:48:03 -0400
Received: by mail-pd0-f178.google.com with SMTP id v10so4430086pde.37
        for <netdev@vger.kernel.org>; Sun, 08 Jun 2014 22:48:02 -0700 (PDT)
In-Reply-To: <53950D7C.5060001@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2014-06-09 at 09:27 +0800, Gao feng wrote:
> On 06/06/2014 09:44 PM, Eric Dumazet wrote:
> > From: Eric Dumazet <edumazet@google.com>
> > 
> > unregister_netdevice_many() API is error prone and we had too
> > many bugs because of dangling LIST_HEAD on stacks.
> > 
> > See commit f87e6f47933e3e ("net: dont leave active on stack LIST_HEAD")
> > 
> > In fact, instead of making sure no caller leaves an active list_head,
> > just force a list_del() in the callee. No one seems to need to access
> > the list after unregister_netdevice_many()
> > 
> 
> Just like the patch I posted one year ago, interesting :)
> http://patchwork.ozlabs.org/patch/223521/


Yeah, apparently no caller has to keep around the list in current
kernel. Not sure how it was last year.
