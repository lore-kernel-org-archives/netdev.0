From: Dmitry Vyukov <dvyukov@google.com>
Subject: Re: KASAN: use-after-free Write in detach_if_pending
Date: Mon, 30 Oct 2017 18:40:16 +0100
Message-ID: <CACT4Y+bRqQFNg-GL6Cd_gA6ZfJGz6Hb2Dhfjqp5fbvRWb+09Zg@mail.gmail.com>
References: <089e0825d424dfce58055c84205f@google.com> <alpine.DEB.2.20.1710291327310.1922@nanos>
 <1509282075.11887.44.camel@edumazet-glaptop3.roam.corp.google.com>
 <CACT4Y+YrZzmn9N5jXH-8+T9P+kbyjstDFAeNooaPdrBbzepH4w@mail.gmail.com>
 <1509381386.11887.46.camel@edumazet-glaptop3.roam.corp.google.com>
 <CACT4Y+bppGVyDVCYa0eL6hG5StSCn35eqH+fjM1LOBu+ktD9rQ@mail.gmail.com> <1509384629.11887.50.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Thomas Gleixner <tglx@linutronix.de>,
        syzbot
        <bot+c0733f3aab92fc116dc1d10d8a25f5bf1f739eff@syzkaller.appspotmail.com>,
        John Stultz <john.stultz@linaro.org>,
        LKML <linux-kernel@vger.kernel.org>, sboyd@codeaurora.org,
        syzkaller-bugs@googlegroups.com, netdev <netdev@vger.kernel.org>,
        Jason Wang <jasowang@redhat.com>,
        David Miller <davem@davemloft.net>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f180.google.com ([209.85.223.180]:43911 "EHLO
        mail-io0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932137AbdJ3Rki (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 30 Oct 2017 13:40:38 -0400
Received: by mail-io0-f180.google.com with SMTP id 134so29010872ioo.0
        for <netdev@vger.kernel.org>; Mon, 30 Oct 2017 10:40:38 -0700 (PDT)
In-Reply-To: <1509384629.11887.50.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Oct 30, 2017 at 6:30 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> On Mon, 2017-10-30 at 18:06 +0100, Dmitry Vyukov wrote:
>
>> Yes, but hashes in random trees also don't tell much. A tree can be
>> rebased so the hash will be lost. It can be a tree unknown to the
>> system. Even if we find the commit by hash, in order to match it
>> against other trees we will have to use the title anyway (or are there
>> better options?), so using hashes becomes pointless.
>
> We do not send hashes on random trees, but official SHA1 in David Miller
> trees. They will be the same SHA1 in official Linus Torvalds tree.
>
> Really, you make our life more difficult by pretending that hashes are
> not the proper way.
>
> They are reasons we use Fixes: tags all over the places, they are unique
> in Linus tree.
>
> Since syzbot gives a SHA1 itself, it must be using a tree, right ?
>
> So a SHA1 that is guaranteed to enter the same tree is correct.
>
> Please fix your bot.


They don't necessary enter the same tree (that's more of an exception
than the rule). For bugs that we find in Linus tree, fixes enter usb,
kvm, block, sound, linux-next and a bunch of other trees that I never
heard of. At the very least we will need a git repo address + commit
hash. But then for say linux-next hashes disappear. And mm which is
not a git tree at all (no hashes).
And still the hashes will need to be explicitly marked as fixes (with
#syz fix or something else). So that would look like:
##syz fix: git://git.kernel.org/pub/scm/linux/kernel/git/mhocko/mm.git
e7989f973ae1b90ec7c0b671c81f7f553affccbe
which does not look much better than:
##syz fix: tun: do not arm flow_gc_timer in tun_flow_init()
which also I think makes it easier for humans to ensure that they
actually reference what they meant to reference (and maybe find the
fix in other trees).
