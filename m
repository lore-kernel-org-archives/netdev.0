From: Baoquan He <bhe@redhat.com>
Subject: Re: [bnx2] [Regression 4.8] Driver loading fails without firmware
Date: Mon, 31 Oct 2016 11:59:30 +0800
Message-ID: <20161031035930.GB7138@x1>
References: <244cb42b-0fce-fe41-7b7c-babb51411e8c@molgen.mpg.de>
 <b0675854-41f9-e7b6-4ad0-85ff59b98977@molgen.mpg.de>
 <20161026120021.GA4402@x1>
 <f055c961-58ca-ea81-46d8-610fa055cce8@molgen.mpg.de>
 <20161029025538.GA4099@x1>
 <1477825531.980.9.camel@molgen.mpg.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Cc: Sony Chacko <sony.chacko@qlogic.com>,
        Dept-HSGLinuxNICDev@qlogic.com, netdev@vger.kernel.org,
        "David S. Miller" <davem@davemloft.net>, dvteam@molgen.mpg.de,
        dyoung@redhat.com
To: Paul Menzel <pmenzel@molgen.mpg.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:34070 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1758438AbcJaD7f (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sun, 30 Oct 2016 23:59:35 -0400
Content-Disposition: inline
In-Reply-To: <1477825531.980.9.camel@molgen.mpg.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Paul,

On 10/30/16 at 12:05pm, Paul Menzel wrote:
> Dear Baoquan,
> 
> 
> Am Samstag, den 29.10.2016, 10:55 +0800 schrieb Baoquan He:
> > On 10/27/16 at 03:21pm, Paul Menzel wrote:
> 
> > > > > Baoquan, could you please fix this regression. My suggestion is, that you
> > > > > add the old code back, but check if the firmware has been loaded. If it
> > > > > hasn’t, load it again.
> > > > > 
> > > > > That way, people can update their Linux kernel, and it continues working
> > > > > without changing the initramfs, or anything else.
> > > > 
> > > > I saw your mail but I am also not familiar with bnx2 driver. As the
> > > > commit log says I just tried to make bnx2 driver reset itself earlier.
> > > > 
> > > > So you did a git bisect and found this commit caused the regression,
> > > > right? If yes, and network developers have no action, I will look into
> > > > the code and see if I have idea to fix it.
> > > 
> > > Well, I looked through the commits and found that one, which would explain
> > > the changed behavior.
> > > 
> > > To be sure, and to follow your request, I took Linux 4.8.4 and reverted your
> > > commit (attached). Then I deleted the firmware again from the initramfs, and
> > > rebooted. The devices showed up just fine as before.
> > > 
> > > So to summarize, the commit is indeed the culprit.
> 
> > Sorry for this.
> > 
> > Could you tell the steps to reproduce? I will find a machine with bnx2
> > NIC and check if there's other ways.
> 
> Well, delete the bnx2 firmware files from the initramfs, and start the
> system.
> 
> Did you read my proposal, to try to load the firmware twice, that means,
> basically revert only the deleted lines of your commit, and add an
> additional check?

Thanks for your information!

I got a x86_64 system with bnx2 NIC, and clone Linus's git tree into
that system. Then building a new kernel 4.9.0-rc3+ with new initramfs.
But when I uncompressed the new initramfs, didn't find bnx2 related
firmware, no bnx2 files under lib/firmware of uncompressed initramfs
folder. While I did see them in /lib/firmware/bnx2/bnx2-xxxxx.fw. Could
you please say it more specifically how I should do to reproduce the
failure you encountered? I think your proposal looks good, just need a
test before post.

Thanks
Baoquan
