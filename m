From: "Dushan Tcholich" <dusanc@gmail.com>
Subject: Re: ksoftirqd high cpu load on kernels 2.6.24 to 2.6.27-rc1-mm1
Date: Sat, 30 Aug 2008 03:48:39 +0200
Message-ID: <a08621850808291848q5660148fx57d576ecfcbfce8@mail.gmail.com>
References: <fa.wTMiBcGRgw2fBtdHwtX7y0lkc8s@ifi.uio.no>
	 <48975BD3.6040709@shaw.ca>
	 <a08621850808041337k1d1deb6fk78098d9fcd4930dd@mail.gmail.com>
	 <20080807185802.GA16327@electric-eye.fr.zoreil.com>
	 <a08621850808101200n220afd2dve58abe67830b7a4f@mail.gmail.com>
	 <a08621850808110053j5cbf23e6xdf52c9e7440abf19@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: "Robert Hancock" <hancockr@shaw.ca>, netdev@vger.kernel.org,
	LKML <linux-kernel@vger.kernel.org>
To: "Francois Romieu" <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wa-out-1112.google.com ([209.85.146.176]:61181 "EHLO
	wa-out-1112.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753003AbYH3Bsk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 Aug 2008 21:48:40 -0400
Received: by wa-out-1112.google.com with SMTP id j37so618105waf.23
        for <netdev@vger.kernel.org>; Fri, 29 Aug 2008 18:48:39 -0700 (PDT)
In-Reply-To: <a08621850808110053j5cbf23e6xdf52c9e7440abf19@mail.gmail.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello again


On Mon, Aug 11, 2008 at 9:53 AM, Dushan Tcholich <dusanc@gmail.com> wrote:
> Hi
>
> On Sun, Aug 10, 2008 at 9:00 PM, Dushan Tcholich <dusanc@gmail.com> wrote:
>> Hi
>> Sorry for answering this late, but I was short on time and couldn't
>> get reiser4 to work with 2.6.27-rc2
>>
>> On Thu, Aug 7, 2008 at 8:58 PM, Francois Romieu <romieu@fr.zoreil.com> wrote:
>>> Dushan Tcholich <dusanc@gmail.com> :
>>> [...]
>>>> I googled a little and found out that oprofile is a little above my head.
>>>> So as I thought that some driver or HW might be responsible for this I
>>>> tried to disable various onboard HW and found out that if I disable
>>>> onboard ethernet problem dissapears, so now I've added netdev and
>>>> maintainer of R8169 driver to cc.
>>>
>>> Can you try 2.6.27-rc2 and send the content of /proc/interrupts, dmesg,
>>> ifconfig as well as a capture of the strange output from top ?
>>>
>
> I tried some more kernels and I had the same problem with 2.6.23.17
> and 2.6.27-rc1-mm1, but I couldn't reproduce it with kernel from
> sysresccd 1.0.1 http://www.sysresccd.org/ which is a patched version
> of 2.6.24 i think .7 when I booted it to change fs.
> Could it be that something in userspace is creating this?
>

I dug a little more and found out some new info.
Unsolved bugreport with same symptoms:
http://marc.info/?l=linux-kernel&m=119613299024398&w=2
Problems appear if I start br0 interface, as context switch rate
increases 200 times. If I start eth0 instead everything looks ok.
The bugreport above had bridging enabled too.

When using eth0 I get:
 vmstat -n 1 10
procs -----------memory---------- ---swap-- -----io---- -system-- ----cpu----
 r  b   swpd   free   buff  cache   si   so    bi    bo   in   cs us sy id wa
 2  0  17720 162288  25024 576852    0    0    21    22    6    9 10  4 85  0
 0  0  17720 162196  25024 576880    0    0     0     0   13  473  0  0 99  0
 0  0  17720 162196  25028 576880    0    0     0     4   36 1122  1  0 99  0
 0  0  17720 162196  25028 576880    0    0     0     0   83  844  0  0 99  0
 0  0  17720 162196  25028 576880    0    0     0     0   55  691  1  0 99  0
 0  0  17720 162556  25028 576880    0    0     0     0   13  490  1  0 100  0
 0  0  17720 162100  25028 576880    0    0     0     0   39  561  6  0 94  0
 1  0  17720 162028  25028 576880    0    0     0     0   16 1030  4  0 96  0
 0  0  17720 162028  25028 576880    0    0     0     0   40  597  1  0 99  0
 0  0  17720 162028  25028 576880    0    0     0     0   12  512  2  0 97  0

 top

top - 03:30:07 up 6 days,  5:40,  4 users,  load average: 0.02, 0.11, 0.28
Tasks: 149 total,   2 running, 147 sleeping,   0 stopped,   0 zombie
Cpu(s): 12.1%us,  3.3%sy,  0.0%ni, 84.6%id,  0.0%wa,  0.0%hi,  0.0%si,  0.0%st
Mem:   1033388k total,   871336k used,   162052k free,    25016k buffers
Swap:   610460k total,    17720k used,   592740k free,   576852k cached

  PID USER      PR  NI  VIRT  RES  SHR S %CPU %MEM    TIME+  COMMAND

    4 root      15  -5     0    0    0 S    0  0.0 554:23.44 ksoftirqd/0

If I use br0 I get:
 vmstat -n 1 10
procs -----------memory---------- ---swap-- -----io---- -system-- ----cpu----
 r  b   swpd   free   buff  cache   si   so    bi    bo   in   cs us sy id wa
 0  0  17720 162112  25048 577120    0    0    21    22    6   11 10  4 86  0
 0  0  17720 162152  25048 577120    0    0     0     0   14 111082  0  3 97  0
 0  0  17720 162152  25048 577120    0    0     0     0   23 107134  1  3 96  0
 1  0  17720 160148  25048 577120    0    0     0     0   11 109888  2  3 95  0
 0  0  17720 162032  25048 577120    0    0     0     0   33 108163  1  2 97  0
 0  0  17720 162032  25048 577120    0    0     0     0    7 104642  2  2 95  0
 0  0  17720 162020  25048 577120    0    0     0     0   41 109135  0  2 98  0
 0  0  17720 162036  25048 577120    0    0     0     0    9 105133  0  3 96  0
 0  0  17720 162020  25048 577120    0    0     0     0   42 107605  1  2 97  0
 1  0  17720 162032  25048 577120    0    0     0     0    5 110768  0  2 98  0

top

top - 03:32:03 up 6 days,  5:41,  4 users,  load average: 0.09, 0.10, 0.26
Tasks: 148 total,   2 running, 146 sleeping,   0 stopped,   0 zombie
Cpu(s):  4.8%us,  2.0%sy,  0.0%ni, 93.0%id,  0.0%wa,  0.0%hi,  0.2%si,  0.0%st
Mem:   1033388k total,   871564k used,   161824k free,    25048k buffers
Swap:   610460k total,    17720k used,   592740k free,   577120k cached

  PID USER      PR  NI  VIRT  RES  SHR S %CPU %MEM    TIME+  COMMAND
11489 dusan     20   0  235m  85m  24m R    6  8.5   1:03.51 firefox
    4 root      15  -5     0    0    0 S   7  0.0 554:24.04 ksoftirqd/0

I start br0 like this in /etc/conf.d/net

bridge_br0="eth0"
config_eth0=( "null" )
config_br0=( "192.168.1.3/24" )
RC_NEED_br0="net.eth0"
brctl_br0=( "setfd 0" "sethello 0" "stp off" )
#routes_br0=( "default gw 192.168.1.3" )
depend_br0() {
        need net.eth0
}

I start eth0 like this in /etc/conf.d/net
config_eth0=( "192.168.1.3/24" )

>> I've copied my root to ext3 partition and with vanilla 2.6.27-rc2 I got:
>> -With my .config problem is still here
>> -With only rtl8169 removed from config there is no problem
>>
>>> It seems rather benign though.
>>>
>> Well I wouldn't agree from power managment standpoint :). This nic is
>> in a lot of laptops.
>> 8% of 2.13GHz Core2Duo CPU is a lot :)
>>
>> Btw. should LKML be removed from cc?
>> If you need any more help please ask.
>> I hope I'm not harrasing you too much :)
>>> --
>>> Ueimor
>>>
>> Have a nice day
>> Dushan
>>
> ...
>
Have a nice day
Dushan
