From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: Re: [PATCH v2 00/10] userns: sysctl limits for namespaces
Date: Tue, 26 Jul 2016 10:06:59 -0500
Message-ID: <87shuwtp4c.fsf@x220.int.ebiederm.org>
References: <8737n5dscy.fsf@x220.int.ebiederm.org>
	<87d1m754jc.fsf@x220.int.ebiederm.org>
	<6be70177-a81d-7ed8-d2c9-a596d4d6a165@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>,
	Andy Lutomirski <luto-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org>,
	Jann Horn <jann-XZ1E9jl8jIdeoWH0uzbU5w@public.gmane.org>, Kees Cook <keescook-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>,
	Nikolay Borisov <kernel-6AxghH7DbtA@public.gmane.org>,
	"Serge E. Hallyn" <serge-A9i7LUbDfNHQT0dZR+AlfA@public.gmane.org>,
	Seth Forshee <seth.forshee-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>,
	linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: "Michael Kerrisk \(man-pages\)" <mtk.manpages-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <6be70177-a81d-7ed8-d2c9-a596d4d6a165-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> (Michael
	Kerrisk's message of "Tue, 26 Jul 2016 12:30:10 +0200")
Sender: linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

"Michael Kerrisk (man-pages)" <mtk.manpages-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> writes:

> Hello Eric,
>
> I realized I had a question after the last mail.
>
> On 07/21/2016 06:39 PM, Eric W. Biederman wrote:
>>
>> This patchset addresses two use cases:
>> - Implement a sane upper bound on the number of namespaces.
>> - Provide a way for sandboxes to limit the attack surface from
>>   namespaces.
>
> Can you say more about the second point? What exactly is the
> problem that is being addressed, and how does the patch series
> address it? (It would be good to have those details in the
> revised commit message...)

At some point it was reported that seccomp was not sufficient to disable
namespace creation.  I need to go back and look at that claim to see
which set of circumstances that was referring to.  Seccomp doesn't stack
so I can see why it is an issue.

The general problem is that namespaces by their nature (and especially
in combination with the user namespaces) allow unprivileged users to use
more of the kernel than a user would have access to without them.  This
in turn allows malicious users more kernel calls they can use in attempt
to find an exploitable bug.

So if you are building a sandbox/chroot jail/chromium tab or anything
like that and you know you won't be needing a kernel feature having an
easy way to disable the feature is useful for making the kernel
marginally more secure, as certain attack vectors are no longer
possible.

Eric
