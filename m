From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: net-2.6.24 plans
Date: Mon, 17 Sep 2007 14:40:37 -0700
Message-ID: <20070917144037.100b3fc1.akpm@linux-foundation.org>
References: <20070916.202258.03371690.davem@davemloft.net>
	<20070917.141826.70218261.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linville@tuxdriver.com, jgarzik@pobox.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:56035 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754454AbXIQVlo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Sep 2007 17:41:44 -0400
In-Reply-To: <20070917.141826.70218261.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 17 Sep 2007 14:18:26 -0700 (PDT)
David Miller <davem@davemloft.net> wrote:

> From: David Miller <davem@davemloft.net>
> Date: Sun, 16 Sep 2007 20:22:58 -0700 (PDT)
> 
> > Tomorrow (Monday) I want to rebase the net-2.6.24 tree one more time
> > to deal with all of the conflicts which exist between
> > linux-2.6/net-2.6 and net-2.6.24, but I'll likely defer that
> > until the net-2.6 fixes I just pushed to Linus are integrated.
> 
> I've just completed this rebase.
> 
> Andrew, I removed the troublesome IOAT patch.  The only conflicts
> and fixes you should need at this point are:
> 
> 1) Removal of SET_MODULE_OWNER() from any extra drivers you import
>    into your tree.
> 
> 2) dev_get_by_*() needs &init_net added as first parameter in any
>    other code you import outside of the net tree.

yup, I think I have all of those done now.

> I guess a lot of this could be avoided if I simply merge in whatever
> external stuff you're sucking in.

external stuff is mainly drivers.  These two:

git://porch.greyhouse.net/gospo/tehuti-2.6.git
ipg-add-ip1000a-driver-to-kernel-tree.patch

plus boatloads of stuff in wireless.

>  I imagine this is just one of
> Linville's trees (I'm surprised that hasn't been sent to me frankly)
> and some specific new drivers you're merging in.

Yeah, git-net versus git-wireless isn't pretty.  The huge amount of pending
wireless stuff has been a bit of a nuisance for some months.  But it's
probably a bigger nuisance for John ;)

I don't know what remains to be done there, but it would be good to dig in
and get it all merged up.  Given the damage which net-2.6.24 does to
git-wireless, that might be tricky, dunno.

> I don't want to sound like a control freak or a whiner, but these
> merge conflicts are growing painful at an astronomic rate and I'd
> therefore prefer if we simply push everything through the net-2.6.24
> tree from now until the merge window.

Works for me.

> Today's rebase took several hours and it took significantly longer to
> suck in Jeff's netdev tree over the weekend.  I'm tired of playing
> patch monkey, so I can sympathize with how life must be every day
> for Andrew :-)

I'm finding that most problems are caused by maintainers committing stuff
to their git trees which affects code which other git-tree owners maintain.
Things like git-net playing with git-wireless code, git-block playing with
git-scsi-misc code, etc.

It would suit _me_ better if people were to try harder to merge changes via
the correct maintainer rather than going out-of-scope like this.  But it
would make life quite a lot harder for the people who are doing this
development, so it isn't clear where the line is best drawn.

>  But on a more serious note there are things I have
> to actually hack on myself so anything that decreases the amount of
> time I spend doing mindless patch whacking in the net-2.6.24 tree is
> appreciated.
> 
> What say you?

My current aggregate diff against 2.6.23-rc6 is 28.8MB.  I'm just sitting
here with my head spinning ;)

(I actually got it all to build, boot and run ltp, which was rather
stunning)
