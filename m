From: Vitalii Demianets <vitas@nppfactor.kiev.ua>
Subject: Re: Introducing open source MSTP daemon
Date: Fri, 23 Sep 2011 16:13:42 +0300
Message-ID: <201109231613.42197.vitas@nppfactor.kiev.ua>
References: <201109221727.33010.vitas@nppfactor.kiev.ua> <201109231036.05039.vitas@nppfactor.kiev.ua> <20110923123058.GD1012103@jupiter.n2.diac24.net>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: bridge@lists.linux-foundation.org, netdev@vger.kernel.org,
	"Srinivas M.A." <srinivas.aji@gmail.com>,
	Stephen Hemminger <shemminger@vyatta.com>
To: David Lamparter <equinox@diac24.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx3.cyfra.ua ([62.80.160.182]:35988 "EHLO mx3.cyfra.ua"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753476Ab1IWNOv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 23 Sep 2011 09:14:51 -0400
In-Reply-To: <20110923123058.GD1012103@jupiter.n2.diac24.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Friday 23 September 2011 15:30:58 David Lamparter wrote:
> On Fri, Sep 23, 2011 at 10:36:04AM +0300, Vitalii Demianets wrote:
> > I suppose these questions are not related to kernel development so I
> > suggest to continue discussion on above topics at the project discussion
> > board: http://sourceforge.net/p/mstpd/discussion/
>
> That's a forum - I'm afraid that's not quite a good communication
> channel for software development feedback. A "normal" software developer
> probably has 10, 20, 30... packages he follows around; if each of them
> was using a separate discussion forum, the developer would have to check
> 30 forums regularly, in hir browser.
>
> A mailing list delivers all of that discussion to the developer's
> mailbox where it's very easy to sort, follow & respond. Considering the
> probably rather low traffic, an existing list might even do it.
>

Ok, as long as there is no objection from other list participants, let's 
continue in netdev list.

> > > I assume it works with current Linux kernel bridge code on a RSTP
> > > level? The code looks considerably more maintainable than rstpd :) - I
> > > will try running it later!
> >
> > Sorry, at the moment function MSTP_OUT_set_state() does nothing except
> > logging. But it is valueable thought: although MSTI states do not have
> > meaning to the kernel bridge code, CIST states can be used to control
> > bridge slave states, so mstpd can replace rstpd as more generic (and
> > conforming to more recent standard).
>
> Well, with the current kernel code you can basically support MSTP setups
> where all VLANs are mapped to one MSTI, since there's just one port
> state for all VLANs. As far as I can tell, that doesn't need to be
> the CIST/instance 0, as long as it's the same for all VLANs.
>
Theoretically, yes. But if the user have bothered to change default config and 
assign all the VLANs to some MSTI, he obviously wants to do something 
MST-related. Maybe she is just in the middle of the configuration process and 
in some time he'll add some  VLANs to another MSTI?
I'd prefer to keep it simple, and translating CIST states to the kernel bridge 
(and all MSTI states to another driver) seems simple enough to me. And this 
approach will also work in the cases when mstpd chooses (R)STP mode of 
operation instead of MSTP, e.g. auto-sensing STP-only neighbors.

> > Anyways, the code is basically untested. It compiles and runs in my
> > setup, that's all for now. But I somehow have gut feeling that the code
> > is mature enough to be put for the community consideration.
>
> Well, "the community" is usually happy when you continually maintain and
> improve your code - one-shot code publications ("fire & forget") happen
> all too often and are forgotten quickly...
>
Understandable enough :)
So for now I'll focus on the (R)STP case and add code which will translate 
CIST states to the kernel bridge. Then the code can be really evaluated (at 
least for the (R)STP cases), not only reviewed.

-- 
Vitalii Demianets
