From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: bonding sysfs output
Date: Tue, 27 Nov 2007 00:44:45 -0800
Message-ID: <20071127004445.a046f791.akpm@linux-foundation.org>
References: <87tznafjeu.fsf@szonett.ki.iif.hu>
	<20071125205150.4e49915f.akpm@linux-foundation.org>
	<87lk8lflzf.fsf@szonett.ki.iif.hu>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Wagner Ferenc <wferi@niif.hu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:46701 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751705AbXK0Io6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Nov 2007 03:44:58 -0500
In-Reply-To: <87lk8lflzf.fsf@szonett.ki.iif.hu>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 26 Nov 2007 09:29:40 +0100 Wagner Ferenc <wferi@niif.hu> wrote:

> Andrew Morton <akpm@linux-foundation.org> writes:
> 
> > On Sun, 25 Nov 2007 16:12:57 +0100 Wagner Ferenc <wferi@niif.hu> wrote:
> >
> >> I propose it as a fix for trailing NULs and spaces like eg.
> >> 
> >> $ od -c /sys/class/net/bond0/bonding/slaves 
> >> 0000000   e   t   h   -   l   e   f   t       e   t   h   -   r   i   g
> >> 0000020   h   t      \n  \0
> >> 0000025
> >> 
> >> I'm afraid there're other problems with "++more++" handling, but let's
> >> not consider those just yet.  Find the patch attached.  The first
> >> hunks also renames buffer to buf, for consistency's shake.
> >> 
> >> The original version had varying behaviour for Not Applicable cases.
> >> This patch also settles for empty files (not even a line feed) in
> >> those cases, but I'm not sure about the general policy on this matter.
> >
> > hm, there are a lot of changes there.  Were they all actually needed to fix
> > the one bug which you have described?
> 
> Trailing NULs are present in each file under /sys/class/net/*/bonding
> and also in /sys/class/net/bonding_masters.  That is, in every file
> provided by drivers/net/bonding/bond_sysfs.c.  Most of the patch is
> concerned with this.
> 
> Closely related is the presence of trailing spaces in multivalue
> files.  There are three such files, one of them has the trailing space
> removed.  This patch removes it from the other two.  During this it
> also renames one function argument 'buffer' to 'buf', for consistency.
> 
> On the policy side: some files are not applicable to some types of
> bonds, and return a single linefeed in that case.  Except for one
> single case, which returns 'NA\n'.  The patch changes these cases into
> emtpy files.
> 
> If these are worthy changes, I'm absolutely willing to split up the
> patch into three parts as the above.

Well that would be good if poss, thanks.

But fixing bugs is way more important than niceties of patch presentation
however I wasn't prepared to fix the rejects which that patch is hitting in
the considerably-changed bonding_show_ad_partner_mac().  Please:

- raise patches against the latest Linus tree
(ftp://ftp.kernel.org/pub/linux/kernel/v2.6/snapshots/)

- cc netdev@vger.kernel.org on networking-related matters

- Include a Signed-off-by: as per Documentation/SubmittingPatches

- Try to ensure that the full explanation (such as you have above) is
covered in the changelog text.

Thanks.
