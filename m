From: Michael Chan <michael.chan@broadcom.com>
Subject: Re: [PATCH net-next 00/10] bnxt_en: Add XDP support.
Date: Mon, 30 Jan 2017 23:38:33 -0800
Message-ID: <CACKFLikc7xUW7YpHcy4_S4KE3s+_EHht-VJGWp+ji+4ue7WoYg@mail.gmail.com>
References: <1485827375-20421-1-git-send-email-michael.chan@broadcom.com>
 <20170131044745.GA8082@ast-mbp.thefacebook.com> <20170130211346.6d637248@cakuba>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Alexei Starovoitov <alexei.starovoitov@gmail.com>,
        David Miller <davem@davemloft.net>,
        Netdev <netdev@vger.kernel.org>
To: Jakub Kicinski <kubakici@wp.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ua0-f178.google.com ([209.85.217.178]:35274 "EHLO
        mail-ua0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750764AbdAaHie (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 31 Jan 2017 02:38:34 -0500
Received: by mail-ua0-f178.google.com with SMTP id y9so268725334uae.2
        for <netdev@vger.kernel.org>; Mon, 30 Jan 2017 23:38:34 -0800 (PST)
In-Reply-To: <20170130211346.6d637248@cakuba>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jan 30, 2017 at 9:13 PM, Jakub Kicinski <kubakici@wp.pl> wrote:
> On Mon, 30 Jan 2017 20:47:47 -0800, Alexei Starovoitov wrote:
>> On Mon, Jan 30, 2017 at 08:49:25PM -0500, Michael Chan wrote:
>> > The first 8 patches refactor the code (rx/tx code paths and ring logic)
>> > and add the basic infrastructure to support XDP.  The 9th patch adds
>> > basic ndo_xdp to support XDP_DROP and XDP_PASS only.  The 10th patch
>> > completes the series with XDP_TX.
>>
>> Looks great.
>> Could you please share performance numbers ?
>>
>> Also please add something like:
>>   if (prog && prog->xdp_adjust_head) {
>>           netdev_warn(dev, "Does not support bpf_xdp_adjust_head()\n");
>>           return -EOPNOTSUPP;
>>   }
>> unless you plan to add adjut_head support until net-next closes.
>> Note, it's must have for load balancer functionality.
>
> I was about to ask whether it's OK at this point to add XDP support
> without xdp_adjust_head()?  My understanding was that this is basic
> functionality and therefore required?

I need to first figure out what xdp_adjust_head means.  If it is ok,
I'd like to defer it.

>
> FWIW the check you requested is there in patch 9.

Yes, it is in there.  I just copied the same code from other drivers.
