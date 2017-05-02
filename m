From: chetan loke <loke.chetan@gmail.com>
Subject: Re: TPACKET_V3 timeout bug?
Date: Tue, 2 May 2017 08:04:12 -0700
Message-ID: <CAAsGZS5ir2Ha1swhdGCg7ibgYRORZykZcu089=oJ51NT4GKDuA@mail.gmail.com>
References: <20170415194042.GA5936@lunn.ch> <20170415224530.GA21010@oracle.com>
 <20170416021050.GA16418@lunn.ch> <251BA382-D82C-4931-A98F-A23AD88F9811@alum.mit.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Cc: Andrew Lunn <andrew@lunn.ch>,
        Sowmini Varadhan <sowmini.varadhan@oracle.com>,
        netdev <netdev@vger.kernel.org>,
        tcpdump-workers@lists.tcpdump.org
To: Guy Harris <guy@alum.mit.edu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ua0-f176.google.com ([209.85.217.176]:35241 "EHLO
        mail-ua0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751409AbdEBPEN (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 2 May 2017 11:04:13 -0400
Received: by mail-ua0-f176.google.com with SMTP id e55so54570241uaa.2
        for <netdev@vger.kernel.org>; Tue, 02 May 2017 08:04:13 -0700 (PDT)
In-Reply-To: <251BA382-D82C-4931-A98F-A23AD88F9811@alum.mit.edu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Apr 15, 2017 at 7:41 PM, Guy Harris <guy@alum.mit.edu> wrote:
> On Apr 15, 2017, at 7:10 PM, Andrew Lunn <andrew@lunn.ch> wrote:
>
>> Do you think this is a kernel problem, libpcap problem, or an
>> application problem?
>

Its clearly a kernel regression.

If you look at if_packet.h, I have explicitly called out all the cases
for the return/status codes. When I first merged the functionality in
3.11(or 3.12 I think) I had the logic in place to retire the block
with or without packets in it. I think there was one case where we
wouldn't wake up userspace. Someone checked in a fix for that. Now I
am not sure the regression happened as part of that bug fix or
sometime later. If you diff 3.12 against the latest you will find the
regression. Look for prb_retire_rx_blk_timer_expired().


> An application problem.  See my response on netdev; the timeout (which is=
 provided by the kernel's capture mechanism, in most cases) is to make sure=
 packets don't stay stuck in the kernel's packet buffer for an indefinite p=
eriod of time, it's *not* to make sure a thread capturing packets doesn't s=
tay blocked for an indefinite period of time.  Whether the timer goes off e=
ven if no

I cannot speak on behalf of user-space wrappers developed around
tpacket_v3 but the intention(from the kernel POV) of the block_timer
*is* to unblock the capture/user process/thread so that it does NOT
stay blocked for an indefinite period of time. The header explicitly
specifies that contract.

I'm tied up for the next 3 weeks. However I can work on it after
that(unless someone else has cycles for it now).

Chetan
