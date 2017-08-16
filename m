From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [patch net-next repost 2/3] net/sched: Change cls_flower to use IDR
Date: Wed, 16 Aug 2017 10:42:01 -0700
Message-ID: <CAM_iQpXOKrT658X1ADfz=WmKryqUgzfOwUF6uTnPNG00EPOQdg@mail.gmail.com>
References: <1502871244-19870-1-git-send-email-chrism@mellanox.com> <1502871244-19870-3-git-send-email-chrism@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
        Jamal Hadi Salim <jhs@mojatatu.com>,
        Jiri Pirko <jiri@resnulli.us>,
        David Miller <davem@davemloft.net>, mawilcox@microsoft.com
To: Chris Mi <chrism@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f196.google.com ([209.85.192.196]:33330 "EHLO
        mail-pf0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751640AbdHPRmW (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 16 Aug 2017 13:42:22 -0400
Received: by mail-pf0-f196.google.com with SMTP id c65so1906799pfl.0
        for <netdev@vger.kernel.org>; Wed, 16 Aug 2017 10:42:21 -0700 (PDT)
In-Reply-To: <1502871244-19870-3-git-send-email-chrism@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Aug 16, 2017 at 1:14 AM, Chris Mi <chrism@mellanox.com> wrote:
> Currently, all filters with the same priority are linked in a doubly
> linked list. Every filter should have a unique handle. To make the
> handle unique, we need to iterate the list every time to see if the
> handle exists or not when inserting a new filter. It is time-consuming.
> For example, it takes about 5m3.169s to insert 64K rules.
>
> This patch changes cls_flower to use IDR. With this patch, it
> takes about 0m1.127s to insert 64K rules. The improvement is huge.
>
> But please note that in this testing, all filters share the same action.
> If every filter has a unique action, that is another bottleneck.
> Follow-up patch in this patchset addresses that.
>
> Signed-off-by: Chris Mi <chrism@mellanox.com>
> Signed-off-by: Jiri Pirko <jiri@mellanox.com>

While you are on it, why only migrate cls_flower? I am sure
we have similar handle generators in other tc flters too.

Also, _possibly_ we may make the tc filter handle generator
generic?

Thanks.
