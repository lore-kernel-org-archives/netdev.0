From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [RFC] make kmemleak scan __ro_after_init section (was: Re:
 [PATCH 0/5] genetlink improvements)
Date: Thu, 03 Nov 2016 16:48:28 +0100
Message-ID: <1478188108.4041.7.camel@sipsolutions.net>
References: <1477312805-7110-1-git-send-email-johannes@sipsolutions.net>
         <20161101172840.6d7d6278@jkicinski-Precision-T1700>
         <CAM_iQpVeB+2M1MPxjRx++E=q4mDuo7XQqfQn3-160PqG8bNLdQ@mail.gmail.com>
         <20161101185630.3c7d326f@jkicinski-Precision-T1700>
         <CAM_iQpV_0gyrJC0U6Qk9VSSaNOphe_0tq5o2kt8-r0UybLU5FA@mail.gmail.com>
         <20161102234755.4381f528@jkicinski-Precision-T1700>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
        LKML <linux-kernel@vger.kernel.org>,
        Catalin Marinas <catalin.marinas@arm.com>, linux-mm@kvack.org
To: Jakub Kicinski <kubakici@wp.pl>,
        Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20161102234755.4381f528@jkicinski-Precision-T1700>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

Sorry for not chipping in earlier - LPC is taking my time.

> > > > Looks like we are missing a kfree(family->attrbuf); on error
> > > > path, but it is not related to Johannes' recent patches.

Actually, I think it *is* related to my patch - I inserted the code
there in the wrong place or so. I'll find a fix for that when I'm back
home, or you (Cong) can submit yours. It wasn't likely that this was
the problem though, since that's just an error path that should never
happen (we have <30 genl families, and a 16-bit space for their IDs)

> I realized that kmemleak is not scanning the __ro_after_init
> section...
> Following patch solves the false positives but I wonder if it's the
> right/acceptable solution.

Hah, makes sense to me, but I guess we really want Catalin to comment
:)

johannes
