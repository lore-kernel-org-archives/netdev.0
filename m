From: Iyappan Subramanian <isubramanian@apm.com>
Subject: Re: [PATCH 2/2] drivers: net: xgene: Clean up all outstanding tx descriptors
Date: Mon, 28 Aug 2017 10:48:12 -0700
Message-ID: <CAKh23Fn_oqpsKnSH+OUbQMVvN0oyVSsnbpsHb-c_7obGLjXLSw@mail.gmail.com>
References: <1503699810-12803-1-git-send-email-isubramanian@apm.com>
 <1503699810-12803-3-git-send-email-isubramanian@apm.com> <20170825231034.GC4207@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: David Miller <davem@davemloft.net>,
        netdev <netdev@vger.kernel.org>,
        "linux-arm-kernel@lists.infradead.org"
        <linux-arm-kernel@lists.infradead.org>,
        Dean Nelson <dnelson@redhat.com>,
        Quan Nguyen <qnguyen@apm.com>, patches <patches@apm.com>
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f50.google.com ([209.85.215.50]:35470 "EHLO
        mail-lf0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751161AbdH1RsO (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 28 Aug 2017 13:48:14 -0400
Received: by mail-lf0-f50.google.com with SMTP id k186so4806704lfe.2
        for <netdev@vger.kernel.org>; Mon, 28 Aug 2017 10:48:14 -0700 (PDT)
In-Reply-To: <20170825231034.GC4207@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Andrew,

On Fri, Aug 25, 2017 at 4:10 PM, Andrew Lunn <andrew@lunn.ch> wrote:
> On Fri, Aug 25, 2017 at 03:23:30PM -0700, Iyappan Subramanian wrote:
>> When xgene_enet is rmmod'd and there are still outstanding tx descriptors
>> that have been setup but have not completed, it is possible on the next
>> modprobe of the driver to receive the oldest of such tx descriptors. This
>> results in a kernel NULL pointer dereference.
>>
>> This patch attempts to clean up (by tearing down) all outstanding tx
>> descriptors when the xgene_enet driver is being rmmod'd.
>>
>> Given that, on the next modprobe it should be safe to ignore any such tx
>> descriptors received that map to a NULL skb pointer.
>
> This does not sound correct. Before the module is allowed to be
> removed, everything needs to be finished. You need to wait for all the
> tx descriptors to be returned before unloading. How can you free the
> memory for the descriptor if it is still in use? How can you free the
> skbuf the descriptor points to, if it is still in use...

Thanks for pointing out the issue.  It is an error, we will fix the issue.

Since the two patches are unrelated, I'm going to post them separately.

Thanks,
Iyappan

>
>       Andrew
