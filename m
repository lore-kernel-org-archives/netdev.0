From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [PATCH 2/7] ns: Introduce the setns syscall
Date: Sat, 07 May 2011 06:57:06 -0700
Message-ID: <m1bozepqa5.fsf@fess.ebiederm.org>
References: <m1tyd7p7tq.fsf@fess.ebiederm.org>
	<1304735101-1824-1-git-send-email-ebiederm@xmission.com>
	<1304735101-1824-2-git-send-email-ebiederm@xmission.com>
	<201105071101.10950.remi@remlab.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-arch@vger.kernel.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, linux-fsdevel@vger.kernel.org,
	jamal <hadi@cyberus.ca>, Daniel Lezcano <daniel.lezcano@free.fr>,
	Linux Containers <containers@lists.osdl.org>,
	Renato Westphal <renatowestphal@gmail.com>
To: =?utf-8?Q?R=C3=A9mi_Denis-Courmont?= <remi@remlab.net>
Return-path: <linux-fsdevel-owner@vger.kernel.org>
In-Reply-To: <201105071101.10950.remi@remlab.net> (=?utf-8?Q?=22R=C3=A9mi?=
 Denis-Courmont"'s
	message of "Sat, 7 May 2011 11:01:08 +0300")
Sender: linux-fsdevel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

"R=C3=A9mi Denis-Courmont" <remi@remlab.net> writes:

> Le samedi 7 mai 2011 05:24:56 Eric W. Biederman, vous avez =C3=A9crit=
 :
>> Pieces of this puzzle can also be solved by instead of
>> coming up with a general purpose system call coming up
>> with targed system calls perhaps socketat that solve
>> a subset of the larger problem.  Overall that appears
>> to be more work for less reward.
>
> socketat() is still required for multithreaded namespace-aware usersp=
ace, I=20
> believe.

The network namespace is a per task property so there are no problems
with multithreaded network namespace aware userspace applications.  The
implementation of a userspace socketat will still need to disable signa=
l
handling around the network namespace switch to be signal safe.  Which
means that ultimately a kernel version of socketat may be desirable,
for performance reasons but I know of know correctness reasons to need
it.

=46or the time being I have simply removed socketat from what I plan to
merge because it is not strictly needed, I don't yet have a test case
for socketat, and I don't have as much time to work on this as I
would like.

There is one bug a multi-threaded network namespace aware user space
application might run into, and that is /proc/net is a symlink to
/proc/self.  Which means that if you open /proc/net/foo from a task wit=
h
a different network namespace than your the task whose tid equals your
tgid, the /proc/net will return the wrong file.  Still you can
avoid even that silliness by opening /proc/<tid>/net.

Eric
--
To unsubscribe from this list: send the line "unsubscribe linux-fsdevel=
" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
