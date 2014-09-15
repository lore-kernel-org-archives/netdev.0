From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [Patch net-next 2/5] net_sched: fix memory leak in cls_tcindex
Date: Mon, 15 Sep 2014 15:46:47 -0700
Message-ID: <CAM_iQpUx_Q2yDhkiw0uFrmFoPociN9zOC4iyKAm8YNEJHdNBbA@mail.gmail.com>
References: <1410815210-6693-1-git-send-email-xiyou.wangcong@gmail.com>
	<1410815210-6693-3-git-send-email-xiyou.wangcong@gmail.com>
	<54175D17.6030109@intel.com>
	<CAM_iQpVCJ9Hge4c3o-jzwWD+8cryoZFC49wHJH14-r9HYzzRVw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
	john fastabend <john.fastabend@gmail.com>,
	"David S. Miller" <davem@davemloft.net>
To: John Fastabend <john.r.fastabend@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oa0-f48.google.com ([209.85.219.48]:48949 "EHLO
	mail-oa0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758740AbaIOWqs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Sep 2014 18:46:48 -0400
Received: by mail-oa0-f48.google.com with SMTP id g18so3076385oah.21
        for <netdev@vger.kernel.org>; Mon, 15 Sep 2014 15:46:47 -0700 (PDT)
In-Reply-To: <CAM_iQpVCJ9Hge4c3o-jzwWD+8cryoZFC49wHJH14-r9HYzzRVw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Sep 15, 2014 at 3:15 PM, Cong Wang <xiyou.wangcong@gmail.com> wrote:
> On Mon, Sep 15, 2014 at 2:41 PM, John Fastabend
> <john.r.fastabend@intel.com> wrote:
>> Actually can we just get rid of the balloc here altogether and
>> remove the checks in errout_alloc so that cp->perfect and cp->h
>> are freed unconditionally? They should be NULL if they are not
>> being used because of the kzalloc.
>>
>
> Hmm, but for cp->h which you don't duplicate if we free it we
> free p->h too, which seems not expected. I think we probably
> need to cp->h = kmemdup(p->h) as well.

I can see why you didn't use kmemdup() there, because p->h
is accessible for readers since we now use RCU read lock.
I think that means we probably have to duplicate the whole
hash table including the chained elements. But it deserves
another patch, to fix this memory leak I think we should just keep
the balloc logic.

I will just fix the missing err = -ENOMEM.

Thanks.
