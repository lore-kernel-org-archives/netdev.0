From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [net-next PATCH 0/3] net: optimize ICMP-reply code path
Date: Mon, 09 Jan 2017 09:56:50 -0800
Message-ID: <1483984610.5846.12.camel@edumazet-glaptop3.roam.corp.google.com>
References: <20170109150246.30215.63371.stgit@firesoul>
         <CAM_iQpWVokaBs=mvG+PKArVx_t3xVg5n9SWjj69Uu=m-ywyH+w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Jesper Dangaard Brouer <brouer@redhat.com>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f68.google.com ([74.125.83.68]:33767 "EHLO
        mail-pg0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1422779AbdAIR4w (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 9 Jan 2017 12:56:52 -0500
Received: by mail-pg0-f68.google.com with SMTP id 194so7782121pgd.0
        for <netdev@vger.kernel.org>; Mon, 09 Jan 2017 09:56:52 -0800 (PST)
In-Reply-To: <CAM_iQpWVokaBs=mvG+PKArVx_t3xVg5n9SWjj69Uu=m-ywyH+w@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2017-01-09 at 09:43 -0800, Cong Wang wrote:
> On Mon, Jan 9, 2017 at 7:03 AM, Jesper Dangaard Brouer
> <brouer@redhat.com> wrote:
> >
> > Use-case: The specific case I experienced this being a bottleneck is,
> > sending UDP packets to a port with no listener, which obviously result
> > in kernel replying with ICMP Destination Unreachable (type:3), Port
> > Unreachable (code:3), which cause the bottleneck.
> 
> Why this is a case we should care about for performance?

This is called provisioning.

If you have a server farm that was qualified to handle 100 Mpps,
you want to absorb these 100 Mpps, even if the UDP server is restarted
in a clean or catastrophic mode.

The catastrophic mode would be the case that Jesper described : No UDP
socket is bound and ready to receive packets.
