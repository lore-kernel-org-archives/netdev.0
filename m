From: David Miller <davem@davemloft.net>
Subject: Re: Issue with netlink implementation
Date: Fri, 03 Apr 2009 22:06:16 -0700 (PDT)
Message-ID: <20090403.220616.176801869.davem@davemloft.net>
References: <6b4fbcea0904030921j1b627d3ar37af13a0788706b4@mail.gmail.com>
	<6b4fbcea0904031424j4b1f5526ydd1d21307e511273@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: keyoor.khristi@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:39490
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751476AbZDDFG1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 4 Apr 2009 01:06:27 -0400
In-Reply-To: <6b4fbcea0904031424j4b1f5526ydd1d21307e511273@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Keyoor Khristi <keyoor.khristi@gmail.com>
Date: Sat, 4 Apr 2009 02:54:48 +0530

You might want to ask networking questions on the networking
developer list, netdev@vger.kernel.org, CC:'d

Thank you.

> Hi All,
> 
> We are facing an issue with netlink implementation. We are sending the
> data from user space to kernel space. a kernel thread gets the data
> from netlink socket (via skb_recv_datagram). After doing little bit
> processing we give the skb to driver. driver sends the data and frees
> the skb. Sometimes we observe that the writer thread in userspace gets
> stuck writing a packet and doesnt come out. We traced the problem to
> netlink_attachskb. When a packet is sent on the netlink socket
> netlink_attachskb is called to add the skb to the queue. when there is
> not enough space, the thread is added to nlk->wait queue and issues
> schedule_timeout. it doesnt come out of it as no other thread awakens
> it. It seems when the driver frees the skb, the data is freed and the
> receive space is made available in the destructor but the thread
> waiting is not awaken. This is causing the problem we're seeing.
> I think the netlink implementation in af_netlink.c can be enhanced. In
> netlink_attachskb, after invoking skb_set_owner_r we should change the
> skb->destructor to point to newly added function netlink_rfree. When
> skb is freed, netlink_rfree function can issue sock_rfree and awaken
> the threads waiting on nlk->wait queue.
> 
> Please let me know what you think about it.
> I'm not sure if i've sent the email to correct forum. If i should be
> sending to another forum, please tell me.
> 
> Regards,
> K
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/
