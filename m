From: Michael Ma <make0818@gmail.com>
Subject: Why do we need tasklet in IFB?
Date: Fri, 28 Oct 2016 14:36:27 -0700
Message-ID: <CAAmHdhz_g5_+Uqp47cPm3NQd=8=9tCecddQLVCfHbChx=Tjhcw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
To: Linux Kernel Network Developers <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f66.google.com ([209.85.218.66]:35775 "EHLO
        mail-oi0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754198AbcJ1Vg3 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 28 Oct 2016 17:36:29 -0400
Received: by mail-oi0-f66.google.com with SMTP id n202so5556270oig.2
        for <netdev@vger.kernel.org>; Fri, 28 Oct 2016 14:36:29 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi -

Currently IFB uses tasklet to process tx/rx on the interface that
forwarded the packet to IFB. My understanding on why we're doing this
is that since dev_queue_xmit() can be invoked in interrupt, we want to
defer the processing of original tx/rx in case ifb_xmit() is called
from interrupt.

However, if the packet is originally from rx, calling context should
already be a tasklet and there is no need to queue the processing to
another tasklet anymore. Even if the packet is originated from tx, we
can rely on the deferred processing of the "original device" or TC if
necessary. Did I miss anything here?

Furthermore, looking at the bonding device's code there isn't this
kind of buffering/tasklet handling for packet forwarding even though
bond also has its own txq/rxq configured separately from the actual
nic, which is very similar to IFB.

So why do we need tasklet in IFB?

Thanks,
Michael
