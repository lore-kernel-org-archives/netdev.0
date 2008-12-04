From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [E1000-devel] networking probs in next-20081203
Date: Thu, 04 Dec 2008 13:00:15 -0800
Message-ID: <m1bpvrslk0.fsf@frodo.ebiederm.org>
References: <49381644.8020502@intel.com>
	<20081204175236.GA19808@x200.localdomain>
	<1228414280.11091.54.camel@moss-spartans.epoch.ncsc.mil>
	<20081204.102138.123959105.davem@davemloft.net>
	<1228419142.11091.90.camel@moss-spartans.epoch.ncsc.mil>
	<1228421219.11091.94.camel@moss-spartans.epoch.ncsc.mil>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, adobriyan@gmail.com,
	auke-jan.h.kok@intel.com, akpm@linux-foundation.org,
	e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org,
	jmorris@namei.org, eparis@parisplace.org
To: Stephen Smalley <sds@tycho.nsa.gov>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out01.mta.xmission.com ([166.70.13.231]:39474 "EHLO
	out01.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754360AbYLDVG0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Dec 2008 16:06:26 -0500
In-Reply-To: <1228421219.11091.94.camel@moss-spartans.epoch.ncsc.mil> (Stephen
	Smalley's message of "Thu, 04 Dec 2008 15:06:59 -0500")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Stephen Smalley <sds@tycho.nsa.gov> writes:

> On Thu, 2008-12-04 at 14:32 -0500, Stephen Smalley wrote:
>> On Thu, 2008-12-04 at 10:21 -0800, David Miller wrote:
>> > From: Stephen Smalley <sds@tycho.nsa.gov>
>> > Date: Thu, 04 Dec 2008 13:11:20 -0500
>> > 
>> > > On Thu, 2008-12-04 at 20:52 +0300, Alexey Dobriyan wrote:
>> > > > On Thu, Dec 04, 2008 at 09:41:24AM -0800, Kok, Auke wrote:
>> > > > > maybe try disabling selinux?
>> > > > 
>> > > > This will work. :^)
>> > > 
>> > > SELinux didn't change here.  /proc/net did.
>> > 
>> > We've been through this before...
>> 
>> Yep, and we altered SELinux so that they could freely change proc
>> directories into symlinks to support the earlier proc/net change.  But
>> now proc/net has turned into its own separate filesystem, with its own
>> filesystem type, which is unknown to SELinux.  Thus causing it to be
>> left unlabeled and inaccessible to confined domains.
>> 
>> > And it is a usability issue that people can't change how procfs
>> > directories work without requiring the user to update their selinux
>> > policies first.
>> 
>> Introducing a new filesystem type (proc/net) without teaching SELinux
>> how to handle it is always going to produce denials on accessing that
>> filesystem.  If they left the filesystem type string as "proc" it
>> wouldn't be a problem.
>
> Actually, that isn't quite correct as it wouldn't generate the same
> name/key for lookup.
>
>>   Or they can adjust the SELinux code to
>> automagically handle it.  Regardless, we didn't break anything.
>
> Looking back, I see that they did in fact change selinux as part of the
> patch to make proc/net its own filesystem, although unfortunately not in
> a way that will quite work.  But no selinux maintainer was ever cc'd on
> that patch.

Yes.  Apologies.  The whole thing started with some stupid security
drama and so things tried to happen outside of the normal channels
and things just went wrong, and got lost...

When I resent and started things through the normal channels I forgot
to cc you guys.  My apologies.

Which piece of selinux magic did I miss?

In particular can you tell if this was a code bug or a logic bug?

Eric
