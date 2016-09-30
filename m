From: Christian Lamparter <chunkeey@googlemail.com>
Subject: Re: UDP wierdness around skb_copy_and_csum_datagram_msg()
Date: Fri, 30 Sep 2016 20:40:44 +0200
Message-ID: <2193954.GuvoBo3fQP@debian64>
References: <CAA3=++__5iwkyyCvSCWJS_b=pBXg=CTYikGgLSh40dkDaY82vg@mail.gmail.com> <3897844.9kvF4Wy8aS@debian64> <87a8epp9ya.fsf@kentik.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: Christian Lamparter <chunkeey@googlemail.com>,
        Alan Curry <rlwinm@sdf.org>,
        Eric Dumazet <eric.dumazet@gmail.com>, netdev@vger.kernel.org,
        Al Viro <viro@zeniv.linux.org.uk>,
        "davem@davemloft.net" <davem@davemloft.net>
To: Jay Smith <jay@kentik.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f44.google.com ([74.125.82.44]:34895 "EHLO
        mail-wm0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932348AbcI3Sks (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 30 Sep 2016 14:40:48 -0400
Received: by mail-wm0-f44.google.com with SMTP id f193so397401wmg.0
        for <netdev@vger.kernel.org>; Fri, 30 Sep 2016 11:40:47 -0700 (PDT)
In-Reply-To: <87a8epp9ya.fsf@kentik.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Friday, September 30, 2016 10:35:25 AM CEST Jay Smith wrote:
> Christian Lamparter writes:
> > On Wednesday, September 28, 2016 7:20:39 PM CEST Jay Smith wrote:
> >> Actually, on a little more searching of this list's archives, I think
> >> that this discussion:  https://patchwork.kernel.org/patch/9260733/ is
> >> about exactly the same issue I've found, except from the TCP side. I'm
> >> cc'ing a few of the participants from that discussion.
> >> 
> >> So is the patch proposed there (copying and restoring the entire
> >> iov_iter in skb_copy_and_csum_datagram_msg()) being considered as a
> >> fix?
> >
> > From Alan's post:
> >
> > "My ugly patch fixes this in the most obvious way: make a local copy of
> > msg->msg_iter before the call to skb_copy_and_csum_datagram(), and copy
> > it back if the checksum is bad, just before goto csum_error;"
> >
> > IMHO this meant that the patch is a proof of concept for his problem.
> 
> It's also the simplest thing that fixes all of the relevant cases (udp4,
> udp6, tcp4). 
Al Viro noted that tcp needed more work here (tp->ucopy.len and friends).
Trouble is, that this discussion (between Alan, David, me and Eric) was 
offlist at that point... And it doesn't look like anyone involved
wants to repeat what they have already said/written. 

(Al Viro, are you there?)

> [...]
> > As for fixing the issue: I'm happy to test and review patches. 
> > The trouble is that nobody seem to be able to produce them...
> 
> Sorry -- is the trouble you're talking about here that no-one's produced
> a patch, or that we don't have a reproduction of the problem?  I don't
> think either is true.
Reproduction wasn't the issue. Back in August, I posted method 
which used the network emulator (CONFIG_NET_SCH_NETEM) to reproduce
it easily and almost anywhere [0].

(i.e.: run this on the server/router)
# tc qdisc add dev eth0 root netem corrupt 0.1%
 
Alan also wrote a userspace tool that had a select/noselect switch
which would lead to different outcomes... etc. However, in the end
Alan could fix his issue by switching to CCMP(AES WLAN cipher), 
which he reported fixed his corruption issue.

So sadly yes, what I meant was that the patches are missing in action.

Regards,
Christian

[0] <https://lkml.org/lkml/2016/8/3/181>
