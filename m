From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: Re: [PATCH v2 00/10] userns: sysctl limits for namespaces
Date: Fri, 22 Jul 2016 21:11:05 -0500
Message-ID: <87h9bhqf2e.fsf@x220.int.ebiederm.org>
References: <8737n5dscy.fsf@x220.int.ebiederm.org>
	<87d1m754jc.fsf@x220.int.ebiederm.org>
	<1469194399.3817016.673814953.7581706C@webmail.messagingengine.com>
	<87poq5y0jw.fsf@x220.int.ebiederm.org>
	<CAGXu5j+X7eWggkwpBpABsFe4hqK5LN1mYJ2TH91qj3iSe6rtcQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Colin Walters <walters-gPq2gbYjIk8dnm+yROfE0A@public.gmane.org>,
	Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>,
	Andy Lutomirski <luto-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org>,
	Jann Horn <jann-XZ1E9jl8jIdeoWH0uzbU5w@public.gmane.org>, Nikolay Borisov <kernel-6AxghH7DbtA@public.gmane.org>,
	"Serge E. Hallyn" <serge-A9i7LUbDfNHQT0dZR+AlfA@public.gmane.org>,
	Seth Forshee <seth.forshee-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>,
	"linux-fsdevel\@vger.kernel.org" <linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Network Development <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	LKML <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Linux API <linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Kees Cook <keescook-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>
Return-path: <linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <CAGXu5j+X7eWggkwpBpABsFe4hqK5LN1mYJ2TH91qj3iSe6rtcQ-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
	(Kees Cook's message of "Fri, 22 Jul 2016 14:46:52 -0700")
Sender: linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Kees Cook <keescook-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org> writes:

> On Fri, Jul 22, 2016 at 11:45 AM, Eric W. Biederman
> <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org> wrote:
>> Colin Walters <walters-gPq2gbYjIk8dnm+yROfE0A@public.gmane.org> writes:
>>
>>> On Thu, Jul 21, 2016, at 12:39 PM, Eric W. Biederman wrote:
>>>>
>>>> This patchset addresses two use cases:
>>>> - Implement a sane upper bound on the number of namespaces.
>>>> - Provide a way for sandboxes to limit the attack surface from
>>>>   namespaces.
>>>
>>> Perhaps this is obvious, but since you didn't quite explicitly state it;
>>> do you see this as obsoleting the existing downstream patches
>>> mentioned in:
>>> https://lwn.net/Articles/673597/
>>> It seems conceptually similar to Kees' original approach, right?
>>
>> Similar yes, and I expect it fills the need.  My primary difference is
>> that I believe this approach makes sense from a perspective of assuming
>> that user namespaces or other namespaces are not any buggier than any
>> other piece of kernel code and that people will use them.
>>
>> I don't see these limits making sense from a perspective that user
>> namespaces are flawed and distro kernels should not have enabled them in
>> the first place.  That was my perception right or wrong of Kees patches
>> and the related patches that landed in Ubuntu and Debian.
>>
>> With Kees approach I could not see how to handle the case where some
>> applications on the system wanted user namespaces and others don't.
>> Which made it very nasty for future evolution and more deployment of
>> user namespaces.  Being per user namespace these limits can be used to
>> sandbox applications without affecting the rest of the system.
>
> While it certainly works for my use-case (init ns
> max_usernamespaces=0), I don't see how this helps the case of "let
> user foobar open 1 userns, but everyone else is 0", which is likely
> the middle ground between "just turn it off" and "everyone gets to
> create usernamespaces". I'm personally not interested in that level of
> granularity, but in earlier discussions it sounded like this was
> something you wanted?

So the case I really care about is when there is limited use, so people
don't have to redesign their applications.  In this case if you want to
disable things in a sandbox like way you just create a user namespace
and set the count to 0 in that user namespace.

A whole system disable I tend to think is a stupid configuration for a
new system.  It gets into people negotiating for what they need, and I
don't see that as sustainable.  I prefer good usable defaults.

I would have loved to have done something with per user limits so it
could be disabled for a selection of users, but it turns out the kernel
doesn't have appropriate data structures for to hold limits for users
that have not logged in.

And in practice I don't care the case where 1 user is allowed but not
the others, I care about disallow this user/program that is in a
sandbox.  I also seem to recall people have problems with using seccomp
to disable things.  All of that said a per user policy is easily
implemented in pam by setting the size count for a specific user to 0.

I do think a limit to catch applications that go crazy is very sane, and
that is primarily what is implemented here.

Eric
