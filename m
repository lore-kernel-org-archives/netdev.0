From: Mahesh Bandewar <maheshb@google.com>
Subject: Re: [PATCH 3/5] net: add udp limit to net cgroup
Date: Mon, 15 Aug 2016 12:16:17 -0700
Message-ID: <CAF2d9jiq=MpT71Pzd5AdDbvnEaA3BD6pa_Ov6NZOFrQiHK5i4w@mail.gmail.com>
References: <1470876798-4024-1-git-send-email-anaravaram@google.com>
 <1470876798-4024-4-git-send-email-anaravaram@google.com> <20160813043535.GB55856@ast-mbp.thefacebook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Anoop Naravaram <anaravaram@google.com>, corbet@lwn.net,
	tj@kernel.org, lizefan@huawei.com, hannes@cmpxchg.org,
	David Miller <davem@davemloft.net>, kuznet@ms2.inr.ac.ru,
	jmorris@namei.org, yoshfuji@linux-ipv6.org, kaber@trash.net,
	linux-doc@vger.kernel.org, cgroups@vger.kernel.org,
	linux-netdev <netdev@vger.kernel.org>,
	Eric Dumazet <edumazet@google.com>,
	Wei Wang <weiwan@google.com>, tom@herbertland.com
To: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Return-path: <linux-doc-owner@vger.kernel.org>
In-Reply-To: <20160813043535.GB55856@ast-mbp.thefacebook.com>
Sender: linux-doc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Aug 12, 2016 at 9:35 PM, Alexei Starovoitov
<alexei.starovoitov@gmail.com> wrote:
[...]
>> * 'net.udp_usage': Reading this file gives the number of udp ports used by
>> processes in this cgroup and all its descendants.
>> * 'net.udp_limit': Writing this file sets the total number of udp ports
>> that can be used by processes in this cgroup and all
>> its descendants. This file can also be read.
>> * 'net.udp_maxusage': Reading this file gives the highest value of
>> net.udp_usage that has been seen for this cgroup.
>> * 'net.udp_failcnt': Reading this file gives the number of times a
>> process in this cgroup or one of its descendants has attempted to acquire
>> a udp port but failed because the limit of this cgroup was reached.
>> * 'net.udp_underflowcnt': Reading this file gives the number of times a
>> process in this cgroup or one of its descendants released a udp port when
>> the usage value of this cgroup was 0.
>
> I have similar concern here. I don't think we should bloat the kernel by
> trying implement every possible port restriction combination and count.
> For the same reasons we don't do all possible tcp stats that research
> community finds useful. This additional code is a maintenance headache.
>
At this moment if a rampant process decides to just open a datagram
socket and just binds (does not listen) and does this for all
available ports, you are guaranteed to have machine becoming useless
for some (totally unrelated) legitimate process trying to do useful
things.

>From kernel we can't control such user-space behavior, but at least
restrict the damage to "a specific set of processes". This code
provides that feature to restrict the damage.

Additional code is always a maintenance headache but that doesn't stop
us from adding new code, isn't it? :)
