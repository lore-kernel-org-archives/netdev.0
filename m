From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH iproute2] vxlan: allow specifying multiple default
 destinations
Date: Wed, 29 May 2013 15:56:25 -0700
Message-ID: <20130529155625.2ee5f6bb@nehalam.linuxnetplumber.net>
References: <1369821617-29098-1-git-send-email-mike.rapoport@ravellosystems.com>
	<1369821617-29098-4-git-send-email-mike.rapoport@ravellosystems.com>
	<ko4kcr$h8j$1@ger.gmane.org>
	<CAF1J0HPDAkhAybQt-tOFLLTLzaXiWy_TSbFF2FT3PMaXbnxJuw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Cong Wang <xiyou.wangcong@gmail.com>, netdev@vger.kernel.org
To: Mike Rapoport <mike.rapoport@ravellosystems.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f169.google.com ([209.85.192.169]:48255 "EHLO
	mail-pd0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S967080Ab3E2W4a (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 May 2013 18:56:30 -0400
Received: by mail-pd0-f169.google.com with SMTP id y11so9634437pdj.14
        for <netdev@vger.kernel.org>; Wed, 29 May 2013 15:56:30 -0700 (PDT)
In-Reply-To: <CAF1J0HPDAkhAybQt-tOFLLTLzaXiWy_TSbFF2FT3PMaXbnxJuw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 29 May 2013 13:52:55 +0300
Mike Rapoport <mike.rapoport@ravellosystems.com> wrote:

> On Wed, May 29, 2013 at 1:13 PM, Cong Wang <xiyou.wangcong@gmail.com> wrote:
> > On Wed, 29 May 2013 at 10:00 GMT, Mike Rapoport <mike.rapoport@ravellosystems.com> wrote:
> >> Signed-off-by: Mike Rapoport <mike.rapoport@ravellosystems.com>
> >> ---
> >>  ip/iplink_vxlan.c | 125 ++++++++++++++++++++++++++++++++++++++++++++++++++++++
> >>  1 file changed, 125 insertions(+)
> >>
> >> diff --git a/ip/iplink_vxlan.c b/ip/iplink_vxlan.c
> >> index 1025326..be6c0ac 100644
> >> --- a/ip/iplink_vxlan.c
> >> +++ b/ip/iplink_vxlan.c
> >> @@ -28,11 +28,87 @@ static void explain(void)
> >>       fprintf(stderr, "                 [ port MIN MAX ] [ [no]learning ]\n");
> >>       fprintf(stderr, "                 [ [no]proxy ] [ [no]rsc ]\n");
> >>       fprintf(stderr, "                 [ [no]l2miss ] [ [no]l3miss ]\n");
> >> +     fprintf(stderr, "                 [ dstadd DST ]\n");
> >> +     fprintf(stderr, "                 [ dstdel ADDR ]\n");
> >
> > Excuse me, but this looks like a design failure as you manipulate
> > remotes with `ip link` while creating vxlan devices, shouldn't this be
> > in a standard alone tool if we can't reuse any existing tool? Or am I
> > missing anything?
> 
> Frankly, I had a long hesitation about the userspace implementation.
> From one side it seems very logical to use ip/iplink_vxlan for vxlan
> device manipulations. Moreover, since the remotes are used pretty much
> the same way as the group address, adding the remotes management to
> ip/iplink_vxlan makes a lot of sense. Besides, creation of stand alone
> tool for remote list manipulation in vxlan seemed to me little bit far
> fetched.
> 
> On the other hand, I quite agree with you that
> ip link add vxlan0 ... dstadd 192.168.1.1
> or
> ip link set vxlan0 ... dstdel 192.168.1.1
> looks weird at least.

Don't like add/delete semantics here either.
Maybe replace or modify, or has this grown enough that having its own
command line tool "vxlan ..." makes sense?
