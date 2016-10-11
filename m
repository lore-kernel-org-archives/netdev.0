From: David Miller <davem@davemloft.net>
Subject: Re: slab corruption with current -git
Date: Mon, 10 Oct 2016 20:30:19 -0400 (EDT)
Message-ID: <20161010.203019.388602181022157591.davem@davemloft.net>
References: <f7ta8ec71qq.fsf@redhat.com>
        <CA+55aFy6pRhvodYG9WWjfxQBFr4ExSk_wxwY=treWYTPK+NTvQ@mail.gmail.com>
        <CA+55aFy0szySf+SnysjXTyfiU=RMBo9U1sHAVaTKG=tUTF+XGw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: aconole@redhat.com, fw@strlen.de, viro@zeniv.linux.org.uk,
        akpm@linux-foundation.org, axboe@fb.com, tytso@mit.edu,
        cl@linux.com, pablo@netfilter.org, linux-kernel@vger.kernel.org,
        linux-fsdevel@vger.kernel.org, netdev@vger.kernel.org,
        netfilter-devel@vger.kernel.org
To: torvalds@linux-foundation.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CA+55aFy0szySf+SnysjXTyfiU=RMBo9U1sHAVaTKG=tUTF+XGw@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Mon, 10 Oct 2016 12:05:17 -0700

> David - I think that also explains what was wrong with the old code.
> In the old code, this loop:
> 
>         while (hooks_entry && nf_entry_dereference(hooks_entry->next)) {
> 
> would exit with "hooks_entry" pointing to the last list entry (because
> ->next was NULL). Nothing was ever unlinked in the loop itself,
> because it never actually found a matching entry, but then after the
> loop it would free that last entry because it *thought* that was the
> match.

It only does this when the ops don't match, but yes it can happen.

Linus can you add some extra info to that:

		WARN(1, "nf_unregister_net_hook: hook not found!\n");

diagnostic, such as the reg->pf and reg->hooknum values?

That might help track down why this is happening in the first
place.
