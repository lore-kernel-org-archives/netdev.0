From: Peter Hurley <peter@hurleysoftware.com>
Subject: Re: pppd service crash in linux-3.13.6
Date: Fri, 14 Mar 2014 16:28:18 -0400
Message-ID: <53236662.3020707@hurleysoftware.com>
References: <531A37FF.4000509@totakura.in> <531DEEA6.4090808@totakura.in> <531E111A.8040207@hurleysoftware.com> <20140313170622.GA31206@redhat.com> <5321F113.7090000@hurleysoftware.com> <53230FE5.9020204@hurleysoftware.com> <20140314192346.GA14823@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Sree Harsha Totakura <sreeharsha@totakura.in>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	"Eric W. Biederman" <ebiederm@xmission.com>
To: Oleg Nesterov <oleg@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20140314192346.GA14823@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 03/14/2014 03:23 PM, Oleg Nesterov wrote:
> On 03/14, Peter Hurley wrote:
>>
>>> On 03/13/2014 01:06 PM, Oleg Nesterov wrote:
>>>>
>>>> OTOH, why we should delay disassociate_ctty? IOW, do you see any
>>>> potential problem with the trivial patch below?
>>
>> Won't work.
>>
>> cgroup_exit() can exec a userspace process (the notify_on_exit() facility)
>                                                    ^^^^^^^^^^^^^^^^
>
> can't find anything named notify_on_exit, perhap you meant
> cgroup_release_agent? Although I guess this should not matter.

Sorry, I meant the notify_on_release() facility as discussed in the
function header comments of cgroup_exit().

Yes, cgroup_release_agent() is the work function that is scheduled.

>> which requires both namespace and tty facilities.
>
> Hmm... why?
>
> The exiting task obviously can't exec. The only way to spawn a userspace
> process is call_usermodehelper(), it should work just fine, no?

You're correct, in the immediate sense that the user command exec'd will
not inherit open file descriptors.

But what if it expects to be able to find the intact children of
the foreground process group, and can't because the controlling tty
has already been torn down and all the children already sent SIGHUP.

I know that's not what the user command is intended for, but
userspace can be enterprising for establishing dependencies on
kernel constructs.

Or what if the user command expects to find and join the user namespace
of the dying process but now it's already been freed?

Regards,
Peter Hurley
