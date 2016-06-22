From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [PATCH RFC] sched: split classification and enqueue
Date: Wed, 22 Jun 2016 10:05:09 -0700
Message-ID: <CAM_iQpXGX=jPO7q=W32o3X2_4ce5PbY2PuTMhkmhtGP6PXuH4Q@mail.gmail.com>
References: <1466589835-18521-1-git-send-email-fw@strlen.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Florian Westphal <fw@strlen.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f195.google.com ([209.85.161.195]:34262 "EHLO
	mail-yw0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753089AbcFVRFf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Jun 2016 13:05:35 -0400
Received: by mail-yw0-f195.google.com with SMTP id l125so7043765ywb.1
        for <netdev@vger.kernel.org>; Wed, 22 Jun 2016 10:05:35 -0700 (PDT)
In-Reply-To: <1466589835-18521-1-git-send-email-fw@strlen.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jun 22, 2016 at 3:03 AM, Florian Westphal <fw@strlen.de> wrote:
>
> This (unfinished!) hack splits classification and enqueue into
> two steps.
>
> Before enqueueing the packet and *before* acquiring the root qdisc lock,
> the new qdisc ->classify() function is invoked.
>
> This function -- much like enqueue in the current scheme -- looks up
> a child class and/or determines the next qdisc where the packet needs
> to be handled via the classifier action subsystem.
> Then it invokes the new ->classify() hook of the child, which can repeat
> until the leaf qdisc is reached.


Then how is the atomicity guaranteed? One of the important
purposes of the qdisc lock is to guarantee the atomicity of any
change of in the whole hierarchy, i.e., qdisc/class/filter/action.
