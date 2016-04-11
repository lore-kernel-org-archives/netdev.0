From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH RFC] net: decrease the length of backlog queue
 immediately after it's detached from sk
Date: Mon, 11 Apr 2016 05:13:48 -0700
Message-ID: <1460376828.6473.538.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1459315001-3448-1-git-send-email-yangyingliang@huawei.com>
	 <1459315520.6473.187.camel@edumazet-glaptop3.roam.corp.google.com>
	 <1459316043.6473.188.camel@edumazet-glaptop3.roam.corp.google.com>
	 <56FB6AA7.1080004@huawei.com>
	 <1459345637.6473.205.camel@edumazet-glaptop3.roam.corp.google.com>
	 <5705F759.9020003@huawei.com>
	 <1460024518.6473.389.camel@edumazet-glaptop3.roam.corp.google.com>
	 <1460040665.6473.398.camel@edumazet-glaptop3.roam.corp.google.com>
	 <5707939B.2030907@huawei.com>
	 <1460126665.6473.437.camel@edumazet-glaptop3.roam.corp.google.com>
	 <570B9126.9080806@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	Ding Tianhong <dingtianhong@huawei.com>
To: Yang Yingliang <yangyingliang@huawei.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qg0-f42.google.com ([209.85.192.42]:36673 "EHLO
	mail-qg0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751171AbcDKMNw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Apr 2016 08:13:52 -0400
Received: by mail-qg0-f42.google.com with SMTP id f52so141795967qga.3
        for <netdev@vger.kernel.org>; Mon, 11 Apr 2016 05:13:51 -0700 (PDT)
In-Reply-To: <570B9126.9080806@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2016-04-11 at 19:57 +0800, Yang Yingliang wrote:
> 
> On 2016/4/8 22:44, Eric Dumazet wrote:
> > On Fri, 2016-04-08 at 19:18 +0800, Yang Yingliang wrote:
> >
> >> I expand  tcp_adv_win_scale and tcp_rmem. It has no effect.
> >
> > Try :
> >
> > echo -2 >/proc/sys/net/ipv4/tcp_adv_win_scale
> >
> > And restart your flows.
> >
> cat /proc/sys/net/ipv4/tcp_rmem
> 10240 2097152 10485760

What about leaving the default values ?

$ cat /proc/sys/net/ipv4/tcp_rmem
4096	87380	6291456

> 
> echo 102400 20971520 104857600 > /proc/sys/net/ipv4/tcp_rmem
> echo -2 >/proc/sys/net/ipv4/tcp_adv_win_scale
> 
> It seems has not effect.
> 

I have no idea what you did on the sender side to allow it to send more
than 1.5 MB then.
