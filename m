From: Oleg Nesterov <oleg@redhat.com>
Subject: Re: pppd service crash in linux-3.13.6
Date: Fri, 14 Mar 2014 20:23:46 +0100
Message-ID: <20140314192346.GA14823@redhat.com>
References: <531A37FF.4000509@totakura.in> <531DEEA6.4090808@totakura.in> <531E111A.8040207@hurleysoftware.com> <20140313170622.GA31206@redhat.com> <5321F113.7090000@hurleysoftware.com> <53230FE5.9020204@hurleysoftware.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Sree Harsha Totakura <sreeharsha@totakura.in>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	"Eric W. Biederman" <ebiederm@xmission.com>
To: Peter Hurley <peter@hurleysoftware.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <53230FE5.9020204@hurleysoftware.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 03/14, Peter Hurley wrote:
>
>> On 03/13/2014 01:06 PM, Oleg Nesterov wrote:
>>>
>>> OTOH, why we should delay disassociate_ctty? IOW, do you see any
>>> potential problem with the trivial patch below?
>
> Won't work.
>
> cgroup_exit() can exec a userspace process (the notify_on_exit() facility)
                                                  ^^^^^^^^^^^^^^^^

can't find anything named notify_on_exit, perhap you meant
cgroup_release_agent? Although I guess this should not matter.

> which requires both namespace and tty facilities.

Hmm... why?

The exiting task obviously can't exec. The only way to spawn a userspace
process is call_usermodehelper(), it should work just fine, no?

Oleg.
