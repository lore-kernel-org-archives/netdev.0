From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [next-queue PATCH v2 2/5] net/sched: Fix accessing invalid dev_queue
Date: Sat, 30 Sep 2017 17:22:33 -0700
Message-ID: <CAM_iQpW7YtS2=rRw814=zWcJaUOGmkWQ+NHQKPwsBF4hMQSRVg@mail.gmail.com>
References: <20170930002657.15291-1-vinicius.gomes@intel.com> <20170930002657.15291-3-vinicius.gomes@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
        intel-wired-lan <intel-wired-lan@lists.osuosl.org>,
        Jesus Sanchez-Palencia <jesus.sanchez-palencia@intel.com>,
        Jamal Hadi Salim <jhs@mojatatu.com>,
        Jiri Pirko <jiri@resnulli.us>, andre.guedes@intel.com,
        Ivan Briano <ivan.briano@intel.com>, boon.leong.ong@intel.com,
        richardcochran@gmail.com, Henrik Austad <henrik@austad.us>,
        levipearson@gmail.com, rodney.cummings@ni.com
To: Vinicius Costa Gomes <vinicius.gomes@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f53.google.com ([74.125.83.53]:46983 "EHLO
        mail-pg0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750988AbdJAAWy (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 30 Sep 2017 20:22:54 -0400
Received: by mail-pg0-f53.google.com with SMTP id v3so1424123pgv.3
        for <netdev@vger.kernel.org>; Sat, 30 Sep 2017 17:22:54 -0700 (PDT)
In-Reply-To: <20170930002657.15291-3-vinicius.gomes@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Sep 29, 2017 at 5:26 PM, Vinicius Costa Gomes
<vinicius.gomes@intel.com> wrote:
> From: Jesus Sanchez-Palencia <jesus.sanchez-palencia@intel.com>
>
> In qdisc_alloc() the dev_queue pointer was used without any checks being
> performed. If qdisc_create() gets a null dev_queue pointer, it just
> passes it along to qdisc_alloc(), leading to a crash. That happens if a
> root qdisc implements select_queue() and returns a null dev_queue
> pointer for an "invalid handle", for example.

Does it make sense to let mqprio_select_queue() always return
non-NULL?

At least mq_select_queue() returns queue #0 as a fallback.
