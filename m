From: "Serge E. Hallyn" <serue@us.ibm.com>
Subject: Re: [TOMOYO #7 30/30] Hooks for SAKURA and TOMOYO.
Date: Wed, 9 Apr 2008 08:22:38 -0500
Message-ID: <20080409132238.GB8489@sergelap.austin.ibm.com>
References: <20080404122242.867070732@I-love.SAKURA.ne.jp> <20080404122408.986477936@I-love.SAKURA.ne.jp> <200804071140.59247.paul.moore@hp.com> <47FC8052.9070409@nttdata.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Paul Moore <paul.moore@hp.com>,
	Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>,
	akpm@linux-foundation.org, linux-kernel@vger.kernel.org,
	linux-security-module@vger.kernel.org,
	Kentaro Takeda <takedakn@nttdata.co.jp>,
	linux-fsdevel <linux-fsdevel@vger.kernel.org>,
	linux-netdev <netdev@vger.kernel.org>
To: Toshiharu Harada <haradats@nttdata.co.jp>
Return-path: <linux-fsdevel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <47FC8052.9070409@nttdata.co.jp>
Sender: linux-fsdevel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Quoting Toshiharu Harada (haradats@nttdata.co.jp):
> On 4/8/2008 12:40 AM, Paul Moore wrote:
>> On Friday 04 April 2008 8:23:12 am Tetsuo Handa wrote:
>>> This file contains modifications against kernel source code
>>> needed to use TOMOYO Linux 1.6.
>>>
>>> Although LSM hooks are provided for performing access control,
>>> TOMOYO Linux 1.6 doesn't use LSM because of the following reasons.
>> Hello,
>> I understand your frustration with the existing LSM hooks/API and your 
>> reasoning for abandoning LSM in favor of a new set of hooks, however, I 
>> think this sets a dangerous precedence which could result in an abundance 
>> of security related hooks scattered throughout the kernel.  I would much 
>> rather see the LSM API extended/tweaked to support the needs of SAKURA and 
>> TOMOYO than ignored and duplicated; I suspect several others will say the 
>> same.
>> You have made good progress with TOMOYO so far and if I can remember 
>> correctly you really only have one hurdle left, the VFS portion.  Please 
>> continue to seek a solution to this that fits within the LSM framework.
>> Thank you.
>
> Thank you for your comments and concern.
>
> I realized that we should have included the reason why we decided to
> post non-LSM version.

First let me point out that reviewing patches is always a lot of work.
What you've done here by posting an entirely new 30-patch implementation
of tomoyo when (I hope) you're not even serious about that is to
basically tell us our time means nothing to you...

If you *are* serious about it, than to whatever extent I can, which
isn't very much, I say nack.

Like you say there appear to be no real remaining objections to the LSM,
only to the VFS part.  You're going to try to get around the VFS
objections by not being an LSM?

Look right now TOMOYO is an out of tree patch.  You want to get it in
tree.  Don't be too hung up on getting it all in at once.  Why not
push a subset of the patch without the vfs controls, which will help
to motivate the vfs controls you need?  You can (1) keep a much smaller
out of tree patch with your implementation of the vfs controls for your
current customrs/installations, and/or (2) implement a temporary
non-pathname-based alternative, say using xattrs to tag files at setup
time - probably insufficient, but sufficient for people to play.

The smaller patch would also be easier to review.

> Let me explain the reason and the history.

We remember the history.  On the one hand we feel for you, but on the
other hand many of us have gone through the same thing, and if you'll
notice Casey went through the same thing and persisted.

> We started developing TOMOYO Linux as original patch sets against
> 2.4 vanilla kernel. We understand the role of LSM, so we ported
> TOMOYO Linux to use LSM and submitted it to the LKML on 13 June 2007.
> We kept working to reflect feedbacks from the community and believe
> no critical Nack remains.

Right, at this point it's mainly a question of finding a way to upstream
tomoyo.  (That's mainly *your* burden, but we do try to help :)

> http://lwn.net/Articles/238049/
> http://lwn.net/Articles/246930/
> http://lwn.net/Articles/252652/
> http://lwn.net/Articles/254503/
> http://lwn.net/Articles/258905/
> http://lwn.net/Articles/263179/
> http://lwn.net/Articles/264187/
> http://lwn.net/Articles/276603/
>
> Still there remains an issue of LSM limitation (vfsmount parameter
> isn?t passed to LSM).
>
> LWN article 239962 says, "At the 2006 summit, Linus took a clear
> position that the use of pathnames for security policies seemed
> reasonable to him".

Yes, but he didn't say you could implement it in a way that offends the
affected maintainers.  Nor did he say it's those maintainers'
responsibility to find you an acceptable solution.  They are in fact
being very nice by offering you suggestions.

Also, isn't Miklos helping you to try and find an acceptable approach?

> Current LSM implementation is sufficient for SELinux
> and other label based MACs but not for pathname-based MACs.
> This has been argued in the AppAmor thread for quite a long time.
> Though proposals had been posted by AppArmor and TOMOYO Linux project,
> none has been merged until now.

You're trying to make it sound like you've spent night and day for years
trying to work with the relevant people to come up with something
reasonable.  Yet for instance in the thread 
	"vfs: add helpers to check r/o bind mounts"
(april 2) where iiuc two reasonable approaches are discussed, you don't
even take part.

> We apologize for the confusion we caused in the last posting,
> but we don't want to give up returning our work to the mainline. 

I'm glad to hear that.  Please keep trying.

> We cordially request LSM changes to pass vfsmount parameters.

Again let me point out there is a difference between saying "Linus said
we can have pathname-based access control, but you won't implement it
for me" and doing the hard work to come up with something reasonable.
I know you've tried a few times, but from what I've seen your impression
of the work you've put into it is far different from my impression of
it.

-serge
