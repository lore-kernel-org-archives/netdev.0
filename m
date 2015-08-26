From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [Question] Usage of dev_hold()/dev_put()
Date: Wed, 26 Aug 2015 06:10:21 -0700
Message-ID: <1440594621.8932.21.camel@edumazet-glaptop2.roam.corp.google.com>
References: <60A73B7A161A82449A7DB7B382BFD155371410A6@SZXEMA504-MBS.china.huawei.com>
	 <1440512689.8932.9.camel@edumazet-glaptop2.roam.corp.google.com>
	 <60A73B7A161A82449A7DB7B382BFD15537141B06@SZXEMA504-MBS.china.huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Jason Wang <jasowang@redhat.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Qinchuanyu <qinchuanyu@huawei.com>, Yewudi <yewudi@huawei.com>,
	liuyongan 00175866 <l00175866@notesmail.huawei.com.cn>,
	Wangbicheng <wangbicheng@huawei.com>,
	Yan Chen <Y.Chen@huawei.com>
To: "Zhangjie (HZ)" <zhangjie14@huawei.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f45.google.com ([209.85.220.45]:33954 "EHLO
	mail-pa0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756397AbbHZNKY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Aug 2015 09:10:24 -0400
Received: by pabzx8 with SMTP id zx8so70034564pab.1
        for <netdev@vger.kernel.org>; Wed, 26 Aug 2015 06:10:24 -0700 (PDT)
In-Reply-To: <60A73B7A161A82449A7DB7B382BFD15537141B06@SZXEMA504-MBS.china.huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2015-08-26 at 07:48 +0000, Zhangjie (HZ) wrote:
> Eric,
> Thank you for your patient apply.
> There is still a question, 
> In receive path, driver does not call dev_hold(), when skb goes to host stack, skb->dev is likely to be used. 
> If device is destroyed before that, it seems dangerous.

This is also handled properly.

Check : flush_backlog() in net/core/dev.c
   sock_queue_rcv_skb() , and all functions setting skb->dev to NULL
