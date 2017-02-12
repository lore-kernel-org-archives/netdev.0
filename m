From: Or Gerlitz <gerlitz.or@gmail.com>
Subject: Re: [PATCH net-next 4/4] net/sched: cls_bpf: Use skip flags to
 reflect HW offload status
Date: Sun, 12 Feb 2017 11:59:46 +0200
Message-ID: <CAJ3xEMi=Q5yr=M40h_nCZF3+L-NT=UskkAgH-jXr825icxxV-A@mail.gmail.com>
References: <1486649888-2786-1-git-send-email-ogerlitz@mellanox.com>
 <1486649888-2786-5-git-send-email-ogerlitz@mellanox.com> <20170209172223.405b9e2f@cakuba.netronome.com>
 <CAJ3xEMh_2PdQXb01NmMnvaRyMzxC8VtNnu8XCqvPLQYRwYJPuQ@mail.gmail.com> <20170210094244.6feb9c47@cakuba.netronome.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Or Gerlitz <ogerlitz@mellanox.com>,
        "David S. Miller" <davem@davemloft.net>,
        Daniel Borkmann <daniel@iogearbox.net>,
        John Fastabend <john.r.fastabend@intel.com>,
        Amir Vadai <amir@vadai.me>,
        Linux Netdev List <netdev@vger.kernel.org>,
        Jiri Pirko <jiri@mellanox.com>, Roi Dayan <roid@mellanox.com>,
        Paul Blakey <paulb@mellanox.com>
To: Jakub Kicinski <kubakici@wp.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ot0-f194.google.com ([74.125.82.194]:35095 "EHLO
        mail-ot0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750915AbdBLJ7r (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 12 Feb 2017 04:59:47 -0500
Received: by mail-ot0-f194.google.com with SMTP id 65so8076994otq.2
        for <netdev@vger.kernel.org>; Sun, 12 Feb 2017 01:59:47 -0800 (PST)
In-Reply-To: <20170210094244.6feb9c47@cakuba.netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Feb 10, 2017 at 7:42 PM, Jakub Kicinski <kubakici@wp.pl> wrote:
> On Fri, 10 Feb 2017 18:33:13 +0200, Or Gerlitz wrote:
>> On Fri, Feb 10, 2017 at 3:22 AM, Jakub Kicinski <kubakici@wp.pl> wrote:
>> > On Thu,  9 Feb 2017 16:18:08 +0200, Or Gerlitz wrote:
>> >> Currently there is no way of querying whether a filter is
>> >> offloaded to HW or not when using both policy (no flag).

>> >> Reuse the skip flags to show the insertion status by setting
>> >> the skip_hw flag in case the filter wasn't offloaded.

>> > I'm obviously all for reporting whether tc objects are offloaded or not
>> > but let me ask perhaps the silly question of why reuse the SKIP_HW flag?
>> > We don't have to worry about flag bits running out, could it be clearer
>> > to users to report whether object is present in HW using a new flag?  Or
>> > even two flags for present/non-present so user doesn't have to ponder
>> > what no flag means (old kernel or not offloaded?). I don't really mind
>> > either way I'm just wondering what the motivation was and maybe how
>> > others feel.

>> yeah, the flags are a bit confusing to some people, but it's all about
>> polarity..

>> when the flags were introduced few of us where in favor of "positive"
>> polarity, that is with possibly three values: "sw only" "hw only" and
>> "both" but that JJJ (Jiri/John/Jamal) consensus was to pick a
>> "negative" polarity of "skip sw" "skip hw" and "default" which means
>> the filter is in SW and possibly in HW. I think we can live with that
>> semantics and this small series just helps for the default case, allow
>> user-space to know if the filter was offloaded using the existing
>> fields.

>> I am not in favor of making this more complex...

> I'm 100% with you.  Restating my proposal was to leave the SKIP_* flags
> with all their existing semantics and complexity and for reporting to
> user space whether something got offloaded add new ones.  My opinion
> is that it would make things simpler, but I'm happy with your version
> if none else thinks this way.

> To spell it out with this patchset we would get the following semantics
> of flags in dumps:
>  - no flags - offloaded || old kernel;
>  - skip_hw - not offloaded (either on user request || no flag
>    was set but offload could not happen);
>  - skip_sw - offload only on explicit request.

> What we could do if we want to add flags would be:
>  - no flags - old kernel;
>  - no_offload - not offloaded;
>  - skip_hw | no_offload - not offloaded on explicit user request;
>  - offload - offloaded opportunistically;
>  - skip_sw | offload - offloaded on explicit request.

Jakub,

Re old kernels, I was thinking that we can address that with pushing
this series to
stable kernels, if this direction can fly, we can avoid adding these
two new flags.

Checking that with dave on the cover letter thread, lets see where
this takes us.

Or.
