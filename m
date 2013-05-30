From: Mike Rapoport <mike.rapoport@ravellosystems.com>
Subject: Re: [PATCH iproute2] vxlan: allow specifying multiple default destinations
Date: Thu, 30 May 2013 11:42:59 +0300
Message-ID: <CAF1J0HNiBED=BLHqPPk8w2=DDvSWdZwMPvtag6rpPhxnboT4GA@mail.gmail.com>
References: <1369821617-29098-1-git-send-email-mike.rapoport@ravellosystems.com>
	<1369821617-29098-4-git-send-email-mike.rapoport@ravellosystems.com>
	<ko4kcr$h8j$1@ger.gmane.org>
	<CAF1J0HPDAkhAybQt-tOFLLTLzaXiWy_TSbFF2FT3PMaXbnxJuw@mail.gmail.com>
	<20130529155625.2ee5f6bb@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Cong Wang <xiyou.wangcong@gmail.com>, netdev@vger.kernel.org
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys010aog111.obsmtp.com ([74.125.245.90]:47082 "HELO
	na3sys010aog111.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S967186Ab3E3InC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 May 2013 04:43:02 -0400
Received: by mail-ob0-f180.google.com with SMTP id eh20so4385558obb.11
        for <netdev@vger.kernel.org>; Thu, 30 May 2013 01:43:00 -0700 (PDT)
In-Reply-To: <20130529155625.2ee5f6bb@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, May 30, 2013 at 1:56 AM, Stephen Hemminger
<stephen@networkplumber.org> wrote:
> On Wed, 29 May 2013 13:52:55 +0300
> Mike Rapoport <mike.rapoport@ravellosystems.com> wrote:
>
>> On Wed, May 29, 2013 at 1:13 PM, Cong Wang <xiyou.wangcong@gmail.com> wrote:
>> > On Wed, 29 May 2013 at 10:00 GMT, Mike Rapoport <mike.rapoport@ravellosystems.com> wrote:
>> >> Signed-off-by: Mike Rapoport <mike.rapoport@ravellosystems.com>
>> >> ---
>> >>  ip/iplink_vxlan.c | 125 ++++++++++++++++++++++++++++++++++++++++++++++++++++++
>> >>  1 file changed, 125 insertions(+)
>> >>
>> >> diff --git a/ip/iplink_vxlan.c b/ip/iplink_vxlan.c
>> >> index 1025326..be6c0ac 100644
>> >> --- a/ip/iplink_vxlan.c
>> >> +++ b/ip/iplink_vxlan.c
>> >> @@ -28,11 +28,87 @@ static void explain(void)
>> >>       fprintf(stderr, "                 [ port MIN MAX ] [ [no]learning ]\n");
>> >>       fprintf(stderr, "                 [ [no]proxy ] [ [no]rsc ]\n");
>> >>       fprintf(stderr, "                 [ [no]l2miss ] [ [no]l3miss ]\n");
>> >> +     fprintf(stderr, "                 [ dstadd DST ]\n");
>> >> +     fprintf(stderr, "                 [ dstdel ADDR ]\n");
>> >
>> > Excuse me, but this looks like a design failure as you manipulate
>> > remotes with `ip link` while creating vxlan devices, shouldn't this be
>> > in a standard alone tool if we can't reuse any existing tool? Or am I
>> > missing anything?
>>
>> Frankly, I had a long hesitation about the userspace implementation.
>> From one side it seems very logical to use ip/iplink_vxlan for vxlan
>> device manipulations. Moreover, since the remotes are used pretty much
>> the same way as the group address, adding the remotes management to
>> ip/iplink_vxlan makes a lot of sense. Besides, creation of stand alone
>> tool for remote list manipulation in vxlan seemed to me little bit far
>> fetched.
>>
>> On the other hand, I quite agree with you that
>> ip link add vxlan0 ... dstadd 192.168.1.1
>> or
>> ip link set vxlan0 ... dstdel 192.168.1.1
>> looks weird at least.
>
> Don't like add/delete semantics here either.
> Maybe replace or modify,

I think that replace or modify do not express the actual operation
meaning. My intention with dstadd was "add remote host X to
pseudo-multicast group". Replace/modify maybe nice to have features to
avoid doing delete+ add.

> or has this grown enough that having its own
> command line tool "vxlan ..." makes sense?

Say, misc/vxlan that will handle remote destinations management? Or
should it take care of some vxlan parameters currently implemented in
ip/iplink_vxlan and bridge/fdb?

--
Sincerely yours,
Mike.
