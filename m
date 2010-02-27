From: Pavel Emelyanov <xemul-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>
Subject: Re: [RFC][PATCH] ns: Syscalls for better namespace sharing control.
Date: Sat, 27 Feb 2010 12:21:53 +0300
Message-ID: <4B88E431.6040609@parallels.com>
References: <4B4F24AC.70105@trash.net>
	<1263481549.23480.24.camel@bigi>	<4B4F3A50.1050400@trash.net>
	<1263490403.23480.109.camel@bigi>	<4B50403A.6010507@trash.net>
	<1263568754.23480.142.camel@bigi>	<m13a0tf17t.fsf@fess.ebiederm.org>
	<1266875729.3673.12.camel@bigi>	<m1wry46es9.fsf@fess.ebiederm.org>
	<1266931623.3973.643.camel@bigi>	<m1iq9ocafv.fsf@fess.ebiederm.org>
	<1266934817.3973.654.camel@bigi>	<m1r5obbu2w.fsf@fess.ebiederm.org>
	<1266966581.3973.675.camel@bigi>	<m1pr3t2fvl.fsf_-_@fess.ebiederm.org>
	<4B883987.6090408@parallels.com>	<m1bpfbwuze.fsf@fess.ebiederm.org>
	<4B883E6F.1060907@parallels.com>	<m13a0nwu6p.fsf@fess.ebiederm.org>
	<4B88D80A.8010701@parallels.com> <m1mxyvrqvk.fsf@fess.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Ben Greear <greearb-my8/4N5VtI7c+919tysfdA@public.gmane.org>,
        Linux Netdev List <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org,
        Netfilter Development Mailinglist <netfilter-devel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        Daniel Lezcano <dlezcano-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>
To: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <m1mxyvrqvk.fsf-+imSwln9KH6u2/kzUuoCbdi2O/JbrIOy@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: netdev.vger.kernel.org

Eric W. Biederman wrote:
> Pavel Emelyanov <xemul-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org> writes:
> 
>> Eric W. Biederman wrote:
>>> Pavel Emelyanov <xemul-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org> writes:
>>>
>>>>>> Yet another set of per-namespace IDs along with CLONE_NEWXXX ones?
>>>>>> I currently have a way to create all namespaces we have with one
>>>>>> syscall. Why don't we have an ability to enter them all with one syscall?
>>>>> The CLONE_NEWXXX series of bits has been an royal pain to work with,
>>>>> and it appears to be unnecessary complications for no gain.
>>>> That's the answer for the "Yet another set..." question.
>>>> How about the "Why don't we have..." one?
>>> I am not certain which question you are asking:
>>>
>>> Why don't we have an ability to enter all namespaces with one syscall
>>> invocation?
>> Exactly. Please add at least the NSTYPE_NSPROXY or whatever, that will
>> pin all namespaces of a given pid from the very beginning.
> 
> For nsfd(2) that is doable.  At least for now setns can't restore it.

Thanks. What's the problem with setns?

>>> Why don't we have a syscall that allows us to enter every namespace?
>> This one is done in the patch, no?
>>
>> Although the approach is OK for me, there's one design issue, that came
>> up to my mind recently: can we use this fd to wail for a namespace to 
>> stop? I currently don't see this ability, but this is something I require
>> badly.
> 
> I have designed these file descriptors to pin the namespaces, so
> waiting for them to exit isn't something they can do now.  It makes a
> lot of sense to have similar ones that take  weak references to the namespaces
> that we can use to wait for a namespace to exit.

Yes, I saw this from patches. Eric, I'd very much appreciate if we
workout a solution that will allow us to kill two birds with one stone.
I do not want to invent yet another bunch of system calls for "taking
weak reference".

As a "brain storm" start up. Can we use inotify/dnotify for this? 
Or maybe we should better equip the nsfd call with flags argument and 
add a flag for weak reference? In that case - how shall we get a 
notification about namespace is dead? With poll? Maybe worth making
the sys_close return only when the namespace is dead (by providing a
proper ->release callback of a file)?

> Eric
> 
