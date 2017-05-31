From: Harald Welte <laforge@gnumonks.org>
Subject: Re: loosing netdevices with namespaces and unshare?
Date: Wed, 31 May 2017 14:27:52 +0200
Message-ID: <20170531122752.siaou43verg4epep@nataraja>
References: <20170530220741.ldmhwj3bsvdoaofc@nataraja>
 <CAM_iQpW2ARBTmGK8JhVXSFCaB1F-WPDKeDZwEbxMLf_Xi7aXQw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ganesha.gnumonks.org ([213.95.27.120]:59922 "EHLO
        ganesha.gnumonks.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751133AbdEaMck (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 31 May 2017 08:32:40 -0400
Content-Disposition: inline
In-Reply-To: <CAM_iQpW2ARBTmGK8JhVXSFCaB1F-WPDKeDZwEbxMLf_Xi7aXQw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Cong,

On Tue, May 30, 2017 at 04:18:17PM -0700, Cong Wang wrote:
> On Tue, May 30, 2017 at 3:07 PM, Harald Welte <laforge@gnumonks.org> wrote:
> > But, to the contrary, this doesn't happen.  The unshare-created netns is
> > gone, but the netdevice did not get moved back to the root namespace
> > either.  The only hack to get back to the "eth0" device is to unload the
> > driver and re-load it.
> 
> 
> Net namespace simply unregisters all netdevices inside when it is
> gone, no matter where they are from. 

ah, ok. I missed that part.  Is there a good piece of documentation on
netwokr namespaces that I should read?

> I am pretty sure you can move it back to root-ns if you want, 

Yes, I can explicitly do that, but this of course doesn't work if e.g.
my [single] process in that namespace crashes due to some bug, OOM or
the like.

> it is a little tricky because you have to give the root-ns a name
> first.

It's actually not, as you can just identify the root-ns by pid 1, so
"ip link set $DEV netns 1" will move it back.  As indicated, I'm worried
about the error paths.

> > What am I missing here?  Is this the intended behavior?
> 
> Yes it is.

thanks for your confirmation.  Guess I have to get used to it.

> > Of course I know I could simply do something like "ip link set eth0
> > netns 1" from within the namespace before leaving.  But what if the
> > process is not bash and the process exits abnormally?   I'd consider
> > that explicit reassignment more like a hack than a proper solution...
> 
> It doesn't make sense to move it back to where it is from, for example,
> what if you move a veth0 from netns1 to netns2 and netns1 is gone
> before netns2?

for virtual devices, I would agree.  For physical devices, I think the
default behavior to unregister them is - from my of course very
subjective point of view - quite questionable.

Regards,
	Harald
-- 
- Harald Welte <laforge@gnumonks.org>           http://laforge.gnumonks.org/
============================================================================
"Privacy in residential applications is a desirable marketing option."
                                                  (ETSI EN 300 175-7 Ch. A6)
