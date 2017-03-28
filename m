From: Michael Chan <michael.chan@broadcom.com>
Subject: Re: Null pointer dereference in tg3_poll_work running linux-3.4
Date: Tue, 28 Mar 2017 11:53:05 -0700
Message-ID: <CACKFLinE3PYyQwcF+CYAcJF=wFz6V58DHWF45WVof+JUn0g8dQ@mail.gmail.com>
References: <CAO7SqHCqADHoZMy7+quaF83-Ln24A=xx10D1Tv9=SX5DFsncpg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Network Development <netdev@vger.kernel.org>,
        "michael.chan@broadcom.com" <mchan@broadcom.com>,
        "prashant.sreedharan@broadcom.com" <prashant@broadcom.com>,
        Siva Reddy Kallam <siva.kallam@broadcom.com>
To: Salam Noureddine <noureddine@arista.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f43.google.com ([209.85.214.43]:38352 "EHLO
        mail-it0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754791AbdC1Sxl (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 28 Mar 2017 14:53:41 -0400
Received: by mail-it0-f43.google.com with SMTP id y18so31160617itc.1
        for <netdev@vger.kernel.org>; Tue, 28 Mar 2017 11:53:30 -0700 (PDT)
In-Reply-To: <CAO7SqHCqADHoZMy7+quaF83-Ln24A=xx10D1Tv9=SX5DFsncpg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Mar 28, 2017 at 11:32 AM, Salam Noureddine
<noureddine@arista.com> wrote:
> Hi,
>
> We've seen a very rare kernel panic in tg3_poll_work on hardware
> running linux-3.4.
> I haven't seen any upstream patches that seem to fix this issue in the
> tg3 driver.
> The disassembly shows that the panic is happening in tg3_rx which is
> inlined into
> tg3_poll_work. In the code below, the "data" pointer seem to be Null,

The data pointer is derived from the opaque value in the receive
descriptor.  When the hardware completes a receive packet, the opaque
value is returned so that the driver can retrieve the proper entry in
the ring and locate the "data" pointer for the buffer.

I don't remember any bug fixes related to this logic.  One possibility
is that there is DMA corruption and we are getting a bad opaque value.
If you have the core dump, it will be useful to look at the receive
completion ring.   These opaque values are simple index values and
should be in sequence.
