From: Paul Gortmaker <paul.gortmaker@windriver.com>
Subject: Re: [RFC] Any value in having a netdev FAQ?
Date: Wed, 17 Jul 2013 11:18:22 -0400
Message-ID: <51E6B5BE.6050505@windriver.com>
References: <20130716025954.GC26761@windriver.com> <1374006725.12825.112.camel@envy.home>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	<netdev@vger.kernel.org>
To: Darren Hart <dvhart@linux.intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:54606 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752053Ab3GQPST (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Jul 2013 11:18:19 -0400
In-Reply-To: <1374006725.12825.112.camel@envy.home>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 13-07-16 04:32 PM, Darren Hart wrote:
> On Mon, 2013-07-15 at 22:59 -0400, Paul Gortmaker wrote:
>> Hi Dave,
>>
>> I was wondering if you think there is value in having a netdev-faq type
>> document available -- perhaps as a vger mailout to new subscribers or
>> similar?  For example, I have lost count of the number of times that you
>> have had to tell people that net-next is closed during the merge window.
>> But you would probably be right in telling me that those same people don't
>> read documentation.  Well, that aside, I suppose answering my question
>> is easier when there is a proposed starting point for content.
>>
>> To that end, I've tried to collect a starting point based on repeated
>> questions/corrections that I've seen over the years.  I've added Greg to
>> the Cc: in order to ensure I've captured the netdev-stable interaction
>> correctly, and I've thrown Darren under the bus as a random content
>> reviewer, since he has expressed an interest in documentation recently.
> 
> And I'm going to learn how to properly interract on netdev while I'm at
> it.  It's a win win :-)
> 
>>
>> Below is a possible starting point for content.  Many answers I have
>> written are from memory, long after losing links to netdev threads that
>> served as evidence for the answers, so apologies in advance if I have
>> failed to recall correctly the specific details in which you would like
>> to see things done.
>>
>> Thanks,
>> Paul.
>> --
>>
>> Information you need to know about netdev
>> -----------------------------------------
>>
>> Q: What is netdev?
>>
>> A: It is a mailing list for all network related linux stuff.  This includes
>>    anything found under net/  (i.e. core code like IPv6) and drivers/net
>>    (i.e. hardware specific drivers) in the linux source tree.
>>
>>    Note that some subsystems (e.g. wireless drivers) which have a high volume
>>    of traffic have their own specific mailing lists.
>>
>>    The netdev list is managed (like many other linux mailing lists) through
>>    VGER ( http://vger.kernel.org/ ) and archives can be found below:
>>
>> 	http://marc.info/?l=linux-netdev
>> 	http://www.spinics.net/lists/netdev/
>>
>>    Aside from subsystems like that mentioned above, all network related linux
>>    development (i.e. RFC, review, comments, etc) takes place on netdev.
>>
> 
> 
> Should LKML be Cc'd? I assume so...

No, not unless there is a good reason to do so.

> 
> 
>> Q: How do the changes posted to netdev make their way into linux?
>>
>> A: There are always two trees (git repositories) in play.  Both are driven
>>    by David Miller, the main network maintainer.  There is the "net" tree,
>>    and the "net-next" tree.  As you can probably guess from the names, the
>>    net tree is for fixes to existing code already in the mainline tree from
>>    Linus, and net-next is where the new code goes for the future release.
>>    You can find the trees here:
>>
>> 	http://git.kernel.org/?p=linux/kernel/git/davem/net.git
>> 	http://git.kernel.org/?p=linux/kernel/git/davem/net-next.git
>>
>> Q: How often do changes from these trees make it to the mainline Linus tree?
>>
>> A: To understand this, you need to know a bit of background information
>>    on the cadence of linux development.  Each new release starts off with
>>    a two week "merge window" where the main maintainers feed their new
>>    stuff to Linus for merging into the mainline tree.  After the two weeks,
>>    the merge window is closed, and it is called/tagged "-rc1".  No new
>>    features get mainlined after this -- only fixes to the rc1 content
>>    are expected.  After roughly a week of collecting fixes to the rc1
>>    content, rc2 is released.  This repeats on a roughly weekly basis
>>    until rc7 (typically; sometimes rc6 if things are quiet, or rc8 if
>>    things are in a state of churn), and a week after the last vX.Y-rcN
>>    was done, the official "vX.Y" is released.
>>
>>    Relating that to netdev:  At the beginning of the 2wk merge window,
> 
> 
> Best not to abbreviate, we can spare the 3 bytes for " week" :-)

Will fix.

> 
> 
>>    the net-next tree will be closed - no new changes/features.  The
>>    accumulated new content of the past ~10 weeks will be passed onto
>>    mainline/Linus via a pull request for vX.Y -- at the same time,
>>    the "net" tree will start accumulating fixes for this pulled content
>>    relating to vX.Y
>>
>>    An announcement indicating when net-next has been closed is usually
>>    sent to netdev, but knowing the above, you can predict that in advance.
>>
>>    IMPORTANT:  Do not send new net-next content to netdev during the
>>    period during which net-next tree is closed.
> 
> 
> It would be handy to have a netdev-next bot that responded to "~/^
> \[PATCH/" email (off list) during the merge window with a reminder of
> this point. Not everyone is active enough in kernel development be
> always aware of where we are in the cycle. Greg has a bot deal with
> common mistakes, so there is precedent.

Perhaps, but that is outside of the scope of this document.

> 
> 
>>
>>    Shortly after the two weeks have passed, (and vX.Y-rc1 is released) the
>>    tree for net-next reopens to collect content for the next (vX.Y+1) release.
>>
>>    The "net" tree continues to collect fixes for the vX.Y content, and
>>    is fed back to Linus at regular (~weekly) intervals.  Meaning that the
>>    focus for "net" is on stablilization and bugfixes.
>>
>>    Finally, the vX.Y gets released, and the whole cycle starts over.
>>
>> Q: So where are we now in this cycle?
>>
>> A: Load the mainline (Linus) page here:
>>
>> 	http://git.kernel.org/?p=linux/kernel/git/torvalds/linux.git
>>
>>    and note the top of the "tags" section.  If it is rc1, it is early
>>    in the dev cycle.  If it was tagged rc7 a week ago, then a release
>>    is probably imminent.
>>
> 
> 
> How does one determine if we are in the merge window? I wonder if we
> could have DEV_CYCLE file in the linux git repository which read:
> 
> MERGE WINDOW
> BUG FIX ONLY (-rc1+)
> CRITICAL FIXES ONLY (-rc4+)
> 
> That would make it trivial to know from right there in the sources where
> we are.

Again, outside the scope of this document.

> 
> 
>> Q: How do I indicate which tree (net vs. net-next) my patch should be in?
>>
>> A: Firstly, think whether you have a bug fix or new "next-like" content.
>>    Then once decided, assuming that you use git, use the prefix flag, i.e.
>>
>> 	git format-patch --subject-prefix='PATCH net-next' start..finish
>>
>>    Use "net" instead of "net-next" in the above for bug-fix net content.
>>    If you don't use git, then note the only magic in the above is just
>>    the subject text of the outgoing e-mail, and you can manually change
>>    it yourself with whatever MUA you are comfortable with.
>>
>> Q: I sent a patch and I'm wondering what happened to it.  How can I tell
>>    whether it got merged?
>>
>> A: Start by looking at the main patchworks queue for netdev:
>>
>> 	http://patchwork.ozlabs.org/project/netdev/list/
>>
>>    The "State" field will tell you exactly where things are at with
>>    your patch.
>>
>> Q: The above only says "Under Review".  How can I find out more?
>>
>> A: Generally speaking, the patches get triaged quickly (in less than 48h).
>>    So be patient.  Asking the maintainer for status updates on your
>>    patch is a good way to ensure your patch is ignored or pushed to
>>    the bottom of the priority list.
>>
>> Q: How can I tell what patches are queued up for backporting to the 
>>    various stable releases?
>>
>> A: Normally Greg Kroah-Hartman collects stable commits himself, but
>>    for networking, Dave collects up patches he deems critical for the
>>    networking subsystem, and then hands them off to Greg.
>>
>>    There is a patchworks queue that you can see here:
>> 	http://patchwork.ozlabs.org/bundle/davem/stable/?state=*
>>
>>    It contains the patches which Dave has selected, but not yet handed
>>    off to Greg.  If Greg already has the patch, then it will be here:
>> 	http://git.kernel.org/cgit/linux/kernel/git/stable/stable-queue.git
>>
>>    A quick way to find whether the patch is in this stable-queue is
>>    to simply clone the repo, and then git grep the mainline commit ID, e.g.
>>
>> 	stable-queue$ git grep -l 284041ef21fdf2e
>> 	releases/3.0.84/ipv6-fix-possible-crashes-in-ip6_cork_release.patch
>> 	releases/3.4.51/ipv6-fix-possible-crashes-in-ip6_cork_release.patch
>> 	releases/3.9.8/ipv6-fix-possible-crashes-in-ip6_cork_release.patch
>> 	stable/stable-queue$ 
>>
> 
> 
> This needs a reference to stable_kernel_rules.txt IMO, and possibly less
> content here.

The question is about finding whether a patch is queued, which comes
up quite often, so I think the detail is warranted.  The rules file
is more about requirements for getting a patch _in_ stable, so the
reference addition below makes sense.
> 
> 
>> Q: I see a network patch and I think it should be backported to stable.
>>    Should I request it via "stable@vger.kernel.org" like the references in
>>    the kernel's Documentation/ directory say?
> 
> stable_kernel_rules.txt specifically

Will add that.

> 
>>
>> A: No, not for networking.  Check the stable queues as per above 1st to see
>>    if it is already queued.  If not, then send a mail to netdev, listing
>>    the upstream commit ID and why you think it should be a stable candidate.
> 
> 
> I had no idea as an infrequent contributor to netdev!
> stable_kernel_rules.txt needs some exceptions noted and a reference to
> this.

Send Greg a patch.  :)

> 
> 
>>
>>    Before you jump to go do the above, do note that the normal stable rules
>>    in Documentation/stable_kernel_rules.txt still apply.  So you need to 
>>    explicitly indicate why it is a critical fix and exactly what users are
>>    impacted.  In addition, you need to convince yourself that you _really_
>>    think it has been overlooked, vs. having been considered and rejected.
>>
>>    Generally speaking, the longer it has had a chance to "soak" in mainline,
>>    the better the odds that it is an OK candidate for stable.  So scrambling
>>    to request a commit be added the day after it appears should be avoided.
>>
>> Q: I have created a network patch and I think it should be backported to
>>    stable.  Should I add a "Cc: stable@vger.kernel.org" like the references
>>    in the kernel's Documentation/ directory say?
>>
>> A: No.  See above answer.  In short, if you think it really belongs in
>>    stable, then ensure you write a decent commit log that describes who
>>    gets impacted by the bugfix and how it manifests itself, and when the
>>    bug was introduced.  If you do that properly, then the commit will
>>    get handled appropriately and most likely get put in the patchworks
>>    stable queue if it really warrants it.
>>
>>    If you think there is some valid information relating to it being in
>>    stable that does _not_ belong in the commit log, then use the three
>>    dash marker line as described in Documentation/SubmittingPatches to 
>>    temporarily embed that information into the patch that you send.
>>
>> Q: Someone said that the comment style and coding convention is different
>>    for the networing content.  Is this true?
> 
> 
> networking

fixed.

> 
>>
>> A: Yes, in a largely trivial way.  Instead of this:
>>
>> 	/*
>> 	 * foobar blah blah blah
>> 	 * another line of text
>> 	 */
>>
>>    it is requested that you make it look like this:
>>
>> 	/* foobar blah blah blah
>> 	 * another line of text
>> 	 */
> 
> 
> This is.... unfortunate. I see the warnings from checkpatch.pl and I
> have to choose between adhering to that or keeping a file which is in
> complete violation to that consistent. I risk flaming either way.
> 
> Do we really need different coding styles for different sub directories
> of the same source tree? I won't say anything more on this or try to
> argue the point, it isn't my call. Just seems.... strange to me.

It is what it is; I'm just documenting it here.

> 
> 
>>
>> Q: I am working in existing code that has the former comment style and not the
>>    latter.  Should I submit new code in the former style or the latter?
>>
>> A: Make it the latter style, so that eventually all code in the domain of
>>    netdev is of this format.
> 
> 
> :-) OK
> 
> 
>>
>> Q: I found a bug that might have possible security implications or similar.
>>    Should I mail the main netdev maintainer off-list?
>>
>> A: No. The current netdev maintainer has consistently requested that people
>>    use the mailing lists and not reach out directly.  If you aren't OK with
>>    that, then perhaps consider using "security@kernel.org" instead.
>>
>> Q: What level of testing is expected before I submit my change?
>>
>> A: If your changes are against net-next, then the expectation is that
> 
> s/then//

Fixed.

> 
>>    you have tested by layering your changes on top of net-next.  Ideally
>>    you will have done run-time testing specific to your change, but
>>    at a minimum, your changes should survive an "allyesconfig" and an
>>    "allmodconfig" build without new warnings or failures.
>>
>> Q: Any other tips to help ensure my net/net-next patch gets OK'd?
>>
>> A: Attention to detail.  You can start with checkpatch.pl, but do not
>>    be mindlessly robotic in doing so.  Re-read your own work as if you were
>>    the reviewer.  If your change is a bug-fix, make sure your commit log
>>    indicates the end-user visible symptom, the underlying reason as
>>    to why it happens, and then if necessary, explain why the fix proposed
>>    is the best way to get things done.   Don't mangle whitespace, and as
>>    is common, don't mis-indent function arguments that span multiple lines.
> 
> 
> This needs a reference to SubmittingPatches

Sure, that can't hurt either.  Will add it.

Paul.
--

> 
> This is great Paul, thank you for taking the time.
> 
