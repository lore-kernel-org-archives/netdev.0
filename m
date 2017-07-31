From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [patch net-next 09/20] net: sched: convert actions array into rcu list
Date: Mon, 31 Jul 2017 14:07:13 -0700
Message-ID: <CAM_iQpWUUM1rj991FM2c2ruOTfgB3ed30AyQo2_KDtj5G8Ojiw@mail.gmail.com>
References: <20170728144042.6380-1-jiri@resnulli.us> <20170728144042.6380-10-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
        David Miller <davem@davemloft.net>,
        Jamal Hadi Salim <jhs@mojatatu.com>,
        Daniel Borkmann <daniel@iogearbox.net>, mlxsw@mellanox.com
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f67.google.com ([74.125.82.67]:36976 "EHLO
        mail-wm0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751658AbdGaVHf (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 31 Jul 2017 17:07:35 -0400
Received: by mail-wm0-f67.google.com with SMTP id t138so309259wmt.4
        for <netdev@vger.kernel.org>; Mon, 31 Jul 2017 14:07:35 -0700 (PDT)
In-Reply-To: <20170728144042.6380-10-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jul 28, 2017 at 7:40 AM, Jiri Pirko <jiri@resnulli.us> wrote:
> From: Jiri Pirko <jiri@mellanox.com>
>
> Currently the actions are stored in array with array size. To traverse
> this array in fastpath, tcf_tree_lock is taken to protect it. Convert
> the array into a singly linked list, similar to the filter chains style
> and allow traversal protected by rcu.

Did you read commit 22dc13c837c33207548c8ee5116 ?

An action can't be shared by multiple filters if you put them
in a list (no matter singly or double), this is why I use pointers.
