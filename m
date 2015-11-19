From: Stefan Priebe - Profihost AG <s.priebe@profihost.ag>
Subject: Re: Asterisk deadlocks since Kernel 4.1
Date: Thu, 19 Nov 2015 10:56:54 +0100
Message-ID: <564D9CE6.2090104@profihost.ag>
References: <564B3D35.50004@profihost.ag>
 <alpine.DEB.2.11.1511171936030.3761@nanos> <564B7F9D.5060701@profihost.ag>
 <alpine.DEB.2.11.1511172041480.3761@nanos> <564CDE2F.8000201@profihost.ag>
 <564CEB0C.40006@redhat.com> <564CEF5D.3080005@profihost.ag>
 <564D9A17.6080305@redhat.com> <564D9B21.302@profihost.ag>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: Thomas Gleixner <tglx@linutronix.de>, netdev@vger.kernel.org,
	linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org
To: Florian Weimer <fweimer@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <564D9B21.302@profihost.ag>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

OK it had a livelock again. It just took more time.

So here is the data:

# la /proc/2598/fd
total 0
dr-x------ 2 root       root        0 Nov 19 06:53 .
dr-xr-xr-x 7 callweaver callweaver  0 Nov 18 22:38 ..
lrwx------ 1 root       root       64 Nov 19 06:54 0 -> /dev/null
lrwx------ 1 root       root       64 Nov 19 06:54 1 -> /dev/null
lrwx------ 1 root       root       64 Nov 19 06:54 10 -> socket:[12066]
lr-x------ 1 root       root       64 Nov 19 06:54 11 -> anon_inode:inotify
lr-x------ 1 root       root       64 Nov 19 06:54 12 -> pipe:[12181]
l-wx------ 1 root       root       64 Nov 19 06:54 13 -> pipe:[12181]
lrwx------ 1 root       root       64 Nov 19 10:56 14 -> socket:[510853]
lrwx------ 1 root       root       64 Nov 19 10:56 15 -> socket:[510854]
lrwx------ 1 root       root       64 Nov 19 10:56 16 ->
anon_inode:[timerfd]
lr-x------ 1 root       root       64 Nov 19 10:56 17 -> pipe:[510856]
l-wx------ 1 root       root       64 Nov 19 10:56 18 -> pipe:[510856]
lrwx------ 1 root       root       64 Nov 19 10:56 19 -> socket:[208723]
lrwx------ 1 root       root       64 Nov 19 06:54 2 -> /dev/null
l-wx------ 1 root       root       64 Nov 19 10:56 20 ->
/var/log/asterisk/queue_log
lrwx------ 1 root       root       64 Nov 19 10:56 21 -> socket:[199595]
lrwx------ 1 root       root       64 Nov 19 10:56 22 -> socket:[510873]
lr-x------ 1 root       root       64 Nov 19 10:56 23 -> anon_inode:inotify
lrwx------ 1 root       root       64 Nov 19 10:56 24 -> socket:[525349]
lrwx------ 1 root       root       64 Nov 19 10:56 25 -> socket:[525350]
lrwx------ 1 root       root       64 Nov 19 10:56 26 -> socket:[510874]
lrwx------ 1 root       root       64 Nov 19 10:56 27 ->
anon_inode:[timerfd]
lr-x------ 1 root       root       64 Nov 19 10:56 28 -> pipe:[510876]
l-wx------ 1 root       root       64 Nov 19 10:56 29 -> pipe:[510876]
lr-x------ 1 root       root       64 Nov 19 06:54 3 -> /dev/urandom
lrwx------ 1 root       root       64 Nov 19 10:56 30 -> socket:[527569]
lrwx------ 1 root       root       64 Nov 19 10:56 31 -> socket:[527570]
lrwx------ 1 root       root       64 Nov 19 10:56 32 -> socket:[528123]
lrwx------ 1 root       root       64 Nov 19 10:56 33 -> socket:[528124]
lrwx------ 1 root       root       64 Nov 19 10:56 34 -> socket:[530711]
lrwx------ 1 root       root       64 Nov 19 10:56 35 -> socket:[530712]
lrwx------ 1 root       root       64 Nov 19 10:56 36 -> socket:[533366]
lrwx------ 1 root       root       64 Nov 19 10:56 37 -> socket:[533367]
lrwx------ 1 root       root       64 Nov 19 10:56 38 -> socket:[535390]
lrwx------ 1 root       root       64 Nov 19 10:56 39 -> socket:[531056]
lrwx------ 1 root       root       64 Nov 19 06:54 4 -> socket:[11726]
lrwx------ 1 root       root       64 Nov 19 10:56 40 -> socket:[531057]
lrwx------ 1 root       root       64 Nov 19 10:56 41 -> socket:[535391]
lrwx------ 1 root       root       64 Nov 19 10:56 42 -> socket:[537751]
lrwx------ 1 root       root       64 Nov 19 10:56 43 -> socket:[533468]
lrwx------ 1 root       root       64 Nov 19 10:56 44 -> socket:[531154]
lrwx------ 1 root       root       64 Nov 19 10:56 45 -> socket:[531155]
lrwx------ 1 root       root       64 Nov 19 10:56 46 -> socket:[533469]
lrwx------ 1 root       root       64 Nov 19 10:56 47 -> socket:[536172]
lrwx------ 1 root       root       64 Nov 19 10:56 48 -> socket:[536173]
lrwx------ 1 root       root       64 Nov 19 10:56 49 -> socket:[537877]
l-wx------ 1 root       root       64 Nov 19 06:54 5 ->
/var/log/asterisk/messages
lrwx------ 1 root       root       64 Nov 19 10:56 50 -> socket:[537752]
lrwx------ 1 root       root       64 Nov 19 10:56 51 -> socket:[539817]
lrwx------ 1 root       root       64 Nov 19 10:56 52 -> socket:[537878]
lrwx------ 1 root       root       64 Nov 19 10:56 53 -> socket:[539818]
lrwx------ 1 root       root       64 Nov 19 10:56 54 -> socket:[541781]
lrwx------ 1 root       root       64 Nov 19 10:56 55 -> socket:[541782]
lrwx------ 1 root       root       64 Nov 19 10:56 56 -> socket:[543462]
lrwx------ 1 root       root       64 Nov 19 10:56 57 -> socket:[545171]
lrwx------ 1 root       root       64 Nov 19 10:56 58 -> socket:[537432]
lrwx------ 1 root       root       64 Nov 19 10:56 59 -> socket:[537433]
l-wx------ 1 root       root       64 Nov 19 06:54 6 ->
/var/log/asterisk/debug.log
lrwx------ 1 root       root       64 Nov 19 10:56 60 -> socket:[545172]
lrwx------ 1 root       root       64 Nov 19 10:56 61 ->
anon_inode:[timerfd]
lrwx------ 1 root       root       64 Nov 19 10:56 62 -> socket:[541196]
lrwx------ 1 root       root       64 Nov 19 10:56 63 -> socket:[538319]
lrwx------ 1 root       root       64 Nov 19 10:56 64 -> socket:[538320]
lrwx------ 1 root       root       64 Nov 19 10:56 65 -> socket:[474586]
lrwx------ 1 root       root       64 Nov 19 10:56 66 -> socket:[541197]
lrwx------ 1 root       root       64 Nov 19 10:56 67 -> socket:[542437]
lrwx------ 1 root       root       64 Nov 19 10:56 68 -> socket:[542438]
lr-x------ 1 root       root       64 Nov 19 10:56 69 -> pipe:[545174]
lrwx------ 1 root       root       64 Nov 19 06:54 7 ->
/var/lib/asterisk/astdb
lrwx------ 1 root       root       64 Nov 19 10:56 70 -> socket:[543463]
l-wx------ 1 root       root       64 Nov 19 10:56 71 -> pipe:[545174]
lrwx------ 1 root       root       64 Nov 19 10:56 76 -> socket:[543659]
lrwx------ 1 root       root       64 Nov 19 10:56 77 -> socket:[543660]
lrwx------ 1 root       root       64 Nov 19 10:56 78 ->
anon_inode:[timerfd]
lr-x------ 1 root       root       64 Nov 19 10:56 79 -> pipe:[543662]
lrwx------ 1 root       root       64 Nov 19 06:54 8 -> anon_inode:[timerfd]
l-wx------ 1 root       root       64 Nov 19 10:56 80 -> pipe:[543662]
lrwx------ 1 root       root       64 Nov 19 06:54 9 -> socket:[12052]

[asterisksnom: ~]# cat /proc/net/netlink
sk       Eth Pid    Groups   Rmem     Wmem     Dump     Locks     Drops
    Inode
ffff8800bac17000 0   0      00000000 0        0        0 2        0
   3
ffff8800b5ef8000 4   0      00000000 0        0        0 2        0
   6201
ffff8800b71cf000 10  0      00000000 0        0        0 2        0
   5455
ffff8800b7176000 11  0      00000000 0        0        0 2        0
   12
ffff8800b1169000 15  4294962899 00000000 0        0        0 2        0
       7979
ffff8800b16cf000 15  441    00000001 0        0        0 2        0
   1542
ffff8800b1168800 15  4294962900 00000000 0        0        0 2        0
       7978
ffff8800b7088800 15  0      00000000 0        0        0 2        0
   5
ffff8800b71c9800 16  0      00000000 0        0        0 2        0
   15
ffff8800b16ca000 16  2362   00000002 0        0        0 2        0
   12313

Stefan

Am 19.11.2015 um 10:49 schrieb Stefan Priebe - Profihost AG:
> 
> Am 19.11.2015 um 10:44 schrieb Florian Weimer:
>> On 11/18/2015 10:36 PM, Stefan Priebe wrote:
>>
>>>> please try to get a backtrace with debugging information.  It is likely
>>>> that this is the make_request/__check_pf functionality in glibc, but it
>>>> would be nice to get some certainty.
>>>
>>> sorry here it is. What I'm wondering is why is there ipv6 stuff? I don't
>>> have ipv6 except for link local.
>>
>> glibc needs to know if the system has global unicast addresses if it
>> receives AAAA records.
>>
>> It's curious that net.ipv6.conf.all.disable_ipv6=1 makes the problem go
>> away.  Even with that setting, the kernel seems to send two Netlink
>> responses.  So either this is enough to narrow the window for the race
>> so that no longer triggers, or there is a genuine kernel issue with
>> supplying the requested IPv6 Netlink response.
> 
> No idea it also goes away by downgrading to 3.18 again.
> 
> Stefan
> 
>>> Could it be this one?
>>>
>>> https://bugzilla.redhat.com/show_bug.cgi?id=505105#c79
>>
>> No, that's on the DNS/UDP side, not in the Netlink code.
>>
>> Florian
>>
