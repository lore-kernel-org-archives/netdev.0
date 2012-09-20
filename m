From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [PATCH] userns: Add basic quota support v4
Date: Wed, 19 Sep 2012 18:28:06 -0700
Message-ID: <87vcf91o0p.fsf@xmission.com>
References: <87lih2h6i4.fsf@xmission.com> <87harqecvk.fsf@xmission.com>
	<20120827085034.GA8998@quack.suse.cz> <87wr0j7u3j.fsf_-_@xmission.com>
	<20120828090544.GC5146@quack.suse.cz> <87a9xe7wfn.fsf@xmission.com>
	<20120828175101.GF5146@quack.suse.cz> <87y5ky6dff.fsf_-_@xmission.com>
	<20120829021029.GC13691@dastard> <87r4qqnixd.fsf@xmission.com>
	<20120831011758.GH15292@dastard>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Jan Kara <jack@suse.cz>, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, linux-fsdevel@vger.kernel.org,
	"Serge E. Hallyn" <serge@hallyn.com>,
	David Miller <davem@davemloft.net>,
	Steven Whitehouse <swhiteho@redhat.com>,
	Mark Fasheh <mfasheh@suse.com>,
	Joel Becker <jlbec@evilplan.org>, Ben Myers <bpm@sgi.com>,
	Alex Elder <elder@kernel.org>,
	Dmitry Monakhov <dmonakhov@openvz.org>,
	Abhijith Das <adas@redhat.com>
To: Dave Chinner <david@fromorbit.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20120831011758.GH15292@dastard> (Dave Chinner's message of "Fri,
	31 Aug 2012 11:17:58 +1000")
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Dave thank you earlier taking some time to do review.  It made me
realize that my code was not as mature as it needed to be.

That said you missed a lot of important details, and I will aim at
to address some of the highlights.

Precedent in naming. <uidgid.h> that has been merged since 3.5, earlier
there is make_pte.   Much of your review sounds like you are unhappy
with the general infrastructure that was built for user namespaces,
and already merged.  Short of an overwhelmingly better suggestion
at this point I am not going to revisit naming.

Passing structures by value is a core part of the design and a necessity
for strong type safety in C, and again already in common use in the
kernel.

Using BUG on code paths that can not be triggered, simply means that
in that rare and unlikely event there is a clear trace to follow,
and xfs already has plenty of invocations of BUG, some of which
I managed to trigger with the xfs test suite.  So I can not find
much sense in your arguments about being clear that something is a BUG.

Your comments on where xfs uses projid are just laughable.

>> So I am inclined to rename this field projid, but I don't know if it is
>> worth respinning the patch for something so trivial.
>
> I'd like to think you are joking, given that the patch series is all
> about using consistent, verifiable identifiers... :/

The patch series is all about implementing the user namespace.

To make it hard to miss places where conversions need to between the
internal kernel form and the form stored in filesystems or the form that
userspace uses I use types that are not assignment compatible.  Pushing
the types deeper in the code keeps me honest and let's me find cases
I was not expecting like the ioctl interface of xfs that largely
duplicates much of the vfs functionality.

Eric
