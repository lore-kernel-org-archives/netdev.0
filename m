From: Kees Cook <keescook@chromium.org>
Subject: Re: [PATCH v2 00/10] userns: sysctl limits for namespaces
Date: Fri, 22 Jul 2016 14:46:52 -0700
Message-ID: <CAGXu5j+X7eWggkwpBpABsFe4hqK5LN1mYJ2TH91qj3iSe6rtcQ@mail.gmail.com>
References: <8737n5dscy.fsf@x220.int.ebiederm.org> <87d1m754jc.fsf@x220.int.ebiederm.org>
 <1469194399.3817016.673814953.7581706C@webmail.messagingengine.com> <87poq5y0jw.fsf@x220.int.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Colin Walters <walters@verbum.org>,
	Linux Containers <containers@lists.linux-foundation.org>,
	Andy Lutomirski <luto@amacapital.net>,
	Jann Horn <jann@thejh.net>, Nikolay Borisov <kernel@kyup.com>,
	"Serge E. Hallyn" <serge@hallyn.com>,
	Seth Forshee <seth.forshee@canonical.com>,
	"linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>,
	Network Development <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>,
	Linux API <linux-api@vger.kernel.org>
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <87poq5y0jw.fsf@x220.int.ebiederm.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Jul 22, 2016 at 11:45 AM, Eric W. Biederman
<ebiederm@xmission.com> wrote:
> Colin Walters <walters@verbum.org> writes:
>
>> On Thu, Jul 21, 2016, at 12:39 PM, Eric W. Biederman wrote:
>>>
>>> This patchset addresses two use cases:
>>> - Implement a sane upper bound on the number of namespaces.
>>> - Provide a way for sandboxes to limit the attack surface from
>>>   namespaces.
>>
>> Perhaps this is obvious, but since you didn't quite explicitly state it;
>> do you see this as obsoleting the existing downstream patches
>> mentioned in:
>> https://lwn.net/Articles/673597/
>> It seems conceptually similar to Kees' original approach, right?
>
> Similar yes, and I expect it fills the need.  My primary difference is
> that I believe this approach makes sense from a perspective of assuming
> that user namespaces or other namespaces are not any buggier than any
> other piece of kernel code and that people will use them.
>
> I don't see these limits making sense from a perspective that user
> namespaces are flawed and distro kernels should not have enabled them in
> the first place.  That was my perception right or wrong of Kees patches
> and the related patches that landed in Ubuntu and Debian.
>
> With Kees approach I could not see how to handle the case where some
> applications on the system wanted user namespaces and others don't.
> Which made it very nasty for future evolution and more deployment of
> user namespaces.  Being per user namespace these limits can be used to
> sandbox applications without affecting the rest of the system.

While it certainly works for my use-case (init ns
max_usernamespaces=0), I don't see how this helps the case of "let
user foobar open 1 userns, but everyone else is 0", which is likely
the middle ground between "just turn it off" and "everyone gets to
create usernamespaces". I'm personally not interested in that level of
granularity, but in earlier discussions it sounded like this was
something you wanted?

-Kees

-- 
Kees Cook
Chrome OS & Brillo Security
