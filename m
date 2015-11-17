From: Stefan Priebe <s.priebe@profihost.ag>
Subject: Re: Asterisk deadlocks since Kernel 4.1
Date: Tue, 17 Nov 2015 20:27:25 +0100
Message-ID: <564B7F9D.5060701@profihost.ag>
References: <564B3D35.50004@profihost.ag>
 <alpine.DEB.2.11.1511171936030.3761@nanos>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-fsdevel@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Thomas Gleixner <tglx@linutronix.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <alpine.DEB.2.11.1511171936030.3761@nanos>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Am 17.11.2015 um 20:15 schrieb Thomas Gleixner:
> On Tue, 17 Nov 2015, Stefan Priebe - Profihost AG wrote:
>> since Upgrading our Asterisk System from Kernel 3.18.17 to 4.1.13 it
>> deadlocks every few hours (kill -9 is the only thing working). Booting
>> with 3.18 again let it run smooth again.
>>
>> An strace shows asterisk is looping like this:
>>
>> [pid  6068] timerfd_gettime(8, , {it_interval={0, 20000000},
>> it_value={0, 140592906050976}}) = 0
>> [pid  6068] read(8, "\1\0\0\0\0\0\0\0", 8) = 8
>> [pid  6068] poll([{fd=9, events=POLLIN}, {fd=8, events=POLLIN|POLLPRI}],
>> 2, 1000) = 1 ([{fd=8, revents=POLLIN}])
>> [pid  6068] timerfd_gettime(8, , {it_interval={0, 20000000},
>> it_value={0, 140592906050976}}) = 0
>> [pid  6068] read(8, "\1\0\0\0\0\0\0\0", 8) = 8
>>
>> fd 8 is:
>>
>> lrwx------ 1 root root 64 Nov 17 15:27 /proc/6025/fd/8 ->
>> anon_inode:[timerfd]
>>
>>
>> # cat /proc/6025/stack
>> [<ffffffff941d60e9>] poll_schedule_timeout+0x49/0x70
>> [<ffffffff941d76c7>] do_sys_poll+0x3d7/0x590
>> [<ffffffff941d78bc>] do_restart_poll+0x3c/0x70
>> [<ffffffff9408e7ff>] sys_restart_syscall+0x1f/0x30
>> [<ffffffff9463f1ee>] system_call_fastpath+0x12/0x71
>> [<ffffffffffffffff>] 0xffffffffffffffff
>>
>> Any ideas how to debug this?
>
> fd 8 is probably not really interesting. That looks like a interval
> timer firing periodically. So it probably waits for fd 9 ...

I've now also two gdb backtraces from two crashes:
http://pastebin.com/raw.php?i=yih5jNt8

http://pastebin.com/raw.php?i=kGEcvH4T

Stefan

>
> Thanks,
>
> 	tglx
>
