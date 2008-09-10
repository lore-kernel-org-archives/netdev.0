From: "Ranjit Manomohan" <ranjitm@google.com>
Subject: Re: [PATCH 1/2] Traffic control cgroups subsystem
Date: Wed, 10 Sep 2008 16:14:42 -0700
Message-ID: <166fe7950809101614y20b60745t652183e32703ccc9@mail.gmail.com>
References: <Pine.LNX.4.64.0809101040280.7050@ranjit.corp.google.com>
	 <20080910220115.GH20815@postel.suug.ch>
	 <166fe7950809101556q61cb7e30m2d5e758304618f61@mail.gmail.com>
	 <20080910.160026.31554352.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: tgraf@suug.ch, akpm@linux-foundation.org, kaber@trash.net,
	lizf@cn.fujitsu.com, menage@google.com,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: "David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([216.239.33.17]:4965 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751057AbYIJXO6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Sep 2008 19:14:58 -0400
Received: from zps75.corp.google.com (zps75.corp.google.com [172.25.146.75])
	by smtp-out.google.com with ESMTP id m8ANEhDW022805
	for <netdev@vger.kernel.org>; Thu, 11 Sep 2008 00:14:44 +0100
Received: from rv-out-0708.google.com (rvbk29.prod.google.com [10.140.87.29])
	by zps75.corp.google.com with ESMTP id m8ANEgYj017187
	for <netdev@vger.kernel.org>; Wed, 10 Sep 2008 16:14:43 -0700
Received: by rv-out-0708.google.com with SMTP id k29so75622rvb.4
        for <netdev@vger.kernel.org>; Wed, 10 Sep 2008 16:14:42 -0700 (PDT)
In-Reply-To: <20080910.160026.31554352.davem@davemloft.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Sep 10, 2008 at 4:00 PM, David Miller <davem@davemloft.net> wrote:
> From: "Ranjit Manomohan" <ranjitm@google.com>
> Date: Wed, 10 Sep 2008 15:56:55 -0700
>
>> That is correct for ingress, for egress the sk is already available in
>> the skb so should be fine.
>
> That is not something you can rely upon, even for egress, %100 of the time.
>
> Some forms of reallocation and mangling might decide to orphan the SKB
> and thus drop the skb->sk reference before you see the packet.  And they
> are absolutely free to do this.
>
> Just grep for skb_orphan().
>
> Therefore, it is absolutely something you should not rely upon for
> correct operation.

Thats fine and we do not rely on this. Those packets would just not be
classified, the cgroup classid is only a hint and used when available
(which is most of the time).

>
> Like I said from the beginning, Thomas's approach is the superior one.

It would leave a lot of packets (like acks) unaccounted for and these
do take up a significant portion of network packets transmitted on a
high speed link). I am ok with Thomas' simpler approach too, just
pointing out that it is not as accurate as the proposed alternative.

-Thanks,
Ranjit

>
