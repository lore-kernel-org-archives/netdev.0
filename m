From: Colin Walters <walters@verbum.org>
Subject: Re: [PATCH v2 00/10] userns: sysctl limits for namespaces
Date: Fri, 22 Jul 2016 09:33:19 -0400
Message-ID: <1469194399.3817016.673814953.7581706C@webmail.messagingengine.com>
References: <8737n5dscy.fsf@x220.int.ebiederm.org>
 <87d1m754jc.fsf@x220.int.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Andy Lutomirski <luto@amacapital.net>, Jann Horn <jann@thejh.net>,
	Kees Cook <keescook@chromium.org>,
	Nikolay Borisov <kernel@kyup.com>,
	"Serge E. Hallyn" <serge@hallyn.com>,
	Seth Forshee <seth.forshee@canonical.com>,
	linux-fsdevel@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, linux-api@vger.kernel.org
To: "Eric W. Biederman" <ebiederm@xmission.com>,
	Linux Containers <containers@lists.linux-foundation.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <87d1m754jc.fsf@x220.int.ebiederm.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Jul 21, 2016, at 12:39 PM, Eric W. Biederman wrote:
> 
> This patchset addresses two use cases:
> - Implement a sane upper bound on the number of namespaces.
> - Provide a way for sandboxes to limit the attack surface from
>   namespaces.

Perhaps this is obvious, but since you didn't quite explicitly state it;
do you see this as obsoleting the existing downstream patches
mentioned in:
https://lwn.net/Articles/673597/
It seems conceptually similar to Kees' original approach, right?

The high level makes sense to me...most interesting is
per-userns sysctls.  I'll note most current container managers
mount /proc/sys read-only, and Docker specifically drops
CAP_SYS_RESOURCE by default, so they'd likely need to learn
how to undo that if one wanted to support recursive container usage.
We'd probably need to evaluate the safety of having /proc/sys
writable generally.  (Also it's rather common to filter out CLONE_NEWUSER
via seccomp, but that's easy to undo)

But that's the flip side - if we're aiming primarily for an upstreamable
way to *limit* namespace usage, it seems sane to me.
