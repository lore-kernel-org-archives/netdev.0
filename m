From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [PATCH v1 net-next 1/5] drop_monitor: import netnamespace framework
Date: Wed, 12 Jul 2017 09:58:25 -0700
Message-ID: <CAM_iQpVDns-WLagoiAxVCmkohm9+QJF1so60++K5Qef-qOFx=w@mail.gmail.com>
References: <1499856053-30475-1-git-send-email-zhangjunweimartin@didichuxing.com>
 <20170712133748.GA21036@hmswarspite.think-freely.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: martinbj2008@gmail.com, David Miller <davem@davemloft.net>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>,
        zhangjunweimartin@didichuxing.com
To: Neil Horman <nhorman@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f68.google.com ([74.125.82.68]:33981 "EHLO
        mail-wm0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753625AbdGLQ6r (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 12 Jul 2017 12:58:47 -0400
Received: by mail-wm0-f68.google.com with SMTP id p204so67870wmg.1
        for <netdev@vger.kernel.org>; Wed, 12 Jul 2017 09:58:46 -0700 (PDT)
In-Reply-To: <20170712133748.GA21036@hmswarspite.think-freely.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jul 12, 2017 at 6:37 AM, Neil Horman <nhorman@tuxdriver.com> wrote:
> On Wed, Jul 12, 2017 at 06:40:49PM +0800, martinbj2008@gmail.com wrote:
>> The dropwatch is a very useful tool to diagnose network problem,
>> which give us greate help.
>> Dropwatch could not work under container(net namespace).
>> It is a pitty, so let it support net ns.
>>
> Sorry, Im having a hard time wrapping my head around this.  Why exactly is it
> that dropwatch won't work in a namespaced environment?  IIRC, the kfree
> tracepoints are namespace agnostic, and so running dropwatch anywhere should
> result in seeing drops in all namespaces.  I grant that perhaps it would be nice
> to filter on a namespace, but it should all 'just work' for some definition of
> the term, no?

Agreed.

And I doubt Martin's implementation which uses skb->sk to retrieve net
works for RX packets, since skb->sk is set very late (except with early demux)
on RX side but we can drop them at anytime...
