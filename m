From: Andy Gospodarek <gospo@cumulusnetworks.com>
Subject: Re: [PATCH] Experimental new bonding driver mode=batman
Date: Wed, 20 May 2015 16:04:22 -0400
Message-ID: <20150520200420.GN9559@gospo.home.greyhouse.net>
References: <555AD3A7.7050202@netscape.net>
 <20150519074941.GB17391@unicorn.suse.cz>
 <555AF479.7000603@netscape.net>
 <20150520073221.GA19868@unicorn.suse.cz>
 <10002.1432143933@nyx>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Michal Kubecek <mkubecek@suse.cz>,
	Patrick Simmons <linuxrocks123@netscape.net>,
	netdev@vger.kernel.org, Veaceslav Falico <vfalico@gmail.com>
To: Jay Vosburgh <jay.vosburgh@canonical.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f181.google.com ([209.85.220.181]:32911 "EHLO
	mail-qk0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753505AbbETUEZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 May 2015 16:04:25 -0400
Received: by qkgv12 with SMTP id v12so39575934qkg.0
        for <netdev@vger.kernel.org>; Wed, 20 May 2015 13:04:25 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <10002.1432143933@nyx>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, May 20, 2015 at 10:45:33AM -0700, Jay Vosburgh wrote:
> Michal Kubecek <mkubecek@suse.cz> wrote:
> 
> >On Tue, May 19, 2015 at 04:29:45AM -0400, Patrick Simmons wrote:
> >> On 05/19/2015 03:49 AM, Michal Kubecek wrote:
> >> >On Tue, May 19, 2015 at 02:09:43AM -0400, Patrick Simmons wrote:
> >> >>
> >> >>I've written a new mode for the kernel bonding driver.  It's similar to
> >> >>the round-robin mode, but it keeps statistics on TCP resends so as to
> >> >>favor slave devices with more bandwidth when choosing where to send
> >> >>packets.  I've tested it on two laptops using WiFi/Ethernet and it seems
> >> >>to work okay, but it should be considered experimental.
> >> >
> >> >A description of how is the mode supposed to work would be definitely
> >> >helpful.
> >> >
> >> 
> >> Rationale: It's helpful for cases where the slave devices have
> >> significantly different or varying bandwidth.  The reason I wrote it
> >> is to bond powerline networking and wireless networking adapters
> >> into a single interface for use with connecting to a MythTV server.
> >> Neither of these systems is particularly reliable with bandwidth,
> >> but mode=batman can adaptively figure out which network has more
> >> available bandwidth at any given moment.  This is better than
> >> mode=round-robin which always balances everything 50/50.
> >
> >Thank you. But I rather meant some basic description of the algorithm
> >used to achieve this goal. Both should be IMHO part of the commit
> >message.
> 
> 	Agreed; the concept sounds interesting, but without a detailed
> description of how it works it is difficult to evaluate its value.
> 
> >> Regarding your analysis, I appreciate your comments, and I know it's
> >> rough, but I'm sorry to say I'm not really interested in doing much
> >> to improve its polish past where it is.  If it fails some way when I
> >> try to deploy it, then I'll fix that, and maybe I'll play around
> >> with the balancing heuristics, but the code quality is what it is
> >> unless someone else wants to improve it.  I would fix the
> >> indentation if that would make it acceptable for you to merge it,
> >> but not much more.  My argument for merging it is basically "it
> >> doesn't do anything unless you pass mode=batman, so what's the
> >> harm?".
> >> 
> >> So, if you guys decide you don't want to merge it because of the
> >> global spinlock etc., that's cool and I understand, but I thought I
> >> should at least post to this list so you and any other potentially
> >> interested people know it exists.  Oh, and, if you're not going to
> >> merge it, please let me know so I can know post the patch to GitHub
> >> or somewhere.  And, if you could include a note in the comments at
> >> the top of bond_main.c or somewhere pointing people to the patch,
> >> I'd very much appreciate that. I don't want anyone else to have to
> >> endure hours of kernel rebuilds with KASAN enabled if they want this
> >> functionality :)
> >
> >Well, it's not my call, I'm not a bonding maintainer. But I believe at
> >least some of the objections would be shared by them. Of course, it's up
> >to you if you want to dedicate your time to improving the code to be
> >acceptable for mainline or rather maintain it out of tree (which may end
> >up taking even more time in the long term).
> 
> 	Well, I am a bonding maintainer, and I can say that the patch in
> its current state is not suitable for inclusion.
> 
> 	At a minimum, there are many coding style issues, commented out
> debug statements, etc, along with design issues (e.g., the batman mode
> handling in bond_handle_frame is unconditional and takes place for all
> modes, not just the new batman mode).
> 
> 	If you (Patrick) or someone else wishes to contribute this to
> mainline, I'd suggest that the first step is to read and follow the
> instructions in Documentation/SubmittingPatches in the kernel source
> code.
> 
> 	It is also not feasible to add pointers in the kernel source
> code to out-of-tree patches; sorry.

Well I can now delete most of my initial response.  :)

Overall I would say this is really cool functionality.  Even if you do
not want it merged, I think it is great that you shared it with the
community this way.  I got a chance to look at is a bit this morning and
I agree additional explanation of the algorithm you are using would
probably be nice for those checking this out for the first time.

I also think if you would be able to leverage the exiting bonding infra
for using skb->queue_mapping you could probably add the same
functionality (though it might be higher in the stack), but I totally
understand if you want to just keep using what you are using as-is.
