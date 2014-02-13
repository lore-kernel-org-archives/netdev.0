From: Ilia Mirkin <imirkin@alum.mit.edu>
Subject: Re: ip_set: protocol %u message -- useful?
Date: Thu, 13 Feb 2014 13:58:02 -0500
Message-ID: <CAKb7UvjdPco0zrP9Ry4mPv40r-bnfNgKEfwcOvJb4JU-5XcTaw@mail.gmail.com>
References: <CAKb7UvhsLi2Sv4SWA2nVTgoFV8dzrY=3R1-SUk9D-aa0VdizSA@mail.gmail.com>
	<alpine.DEB.2.10.1402131117120.16734@blackhole.kfki.hu>
	<CAHA+R7MeEEfqz-7RhCUjsoWPx_BKHVXFV3Y32xjf0B1WwjNdRQ@mail.gmail.com>
	<20140213184254.GF14175@macbook.localnet>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Cong Wang <cwang@twopensource.com>,
	Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>,
	netdev <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	Vitaly Lavrov <lve@guap.ru>
To: Patrick McHardy <kaber@trash.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20140213184254.GF14175@macbook.localnet>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Feb 13, 2014 at 1:42 PM, Patrick McHardy <kaber@trash.net> wrote:
> On Thu, Feb 13, 2014 at 10:32:45AM -0800, Cong Wang wrote:
>> On Thu, Feb 13, 2014 at 2:30 AM, Jozsef Kadlecsik
>> <kadlec@blackhole.kfki.hu> wrote:
>> > On Thu, 13 Feb 2014, Ilia Mirkin wrote:
>> >> messages in my dmesg. This might be because of some local
>> >> configuration changes I've made, or perhaps a kernel upgrade. Either
>> >> way, it appears this message has been a pr_notice since the original
>> >> code added it in a7b4f989a62 ("netfilter: ipset: IP set core
>> >> support").
>> >>
>> >> Does this message provide a lot of value? Or could it be made into a pr_debug?
>> >
>> > That's a report message on the protocol version used by the ipset
>> > subsystem. There was (and possibly will be) multiple protocols, so it
>> > helps to catch basic userpsace/kernelspace communication issues.
>>
>> But still it doesn't deserve a pr_notice()... pr_info() should be enough.
>
> Maybe printing "using protocol version X" will make it appear less like
> a debugging message referring to packet contents or something similar.

With pr_info it'll still appear in dmesg, and it'll still be "random
non-sensical message appears over and over in dmesg" type of
situation, to the vast majority of users. Do we need a print every
time someone creates a new tcp connection too? I'm still not totally
clear on the cause of this message getting printed, but I was seeing
it a whole bunch in my configuration...

>
>> diff --git a/net/netfilter/ipset/ip_set_core.c
>> b/net/netfilter/ipset/ip_set_core.c
>> index de770ec..5ea063f 100644
>> --- a/net/netfilter/ipset/ip_set_core.c
>> +++ b/net/netfilter/ipset/ip_set_core.c
>> @@ -1945,7 +1945,7 @@ ip_set_net_init(struct net *net)
>>                 return -ENOMEM;
>>         inst->is_deleted = 0;
>>         rcu_assign_pointer(inst->ip_set_list, list);
>> -       pr_notice("ip_set: protocol %u\n", IPSET_PROTOCOL);
>> +       pr_info("ip_set: protocol %u\n", IPSET_PROTOCOL);
>>         return 0;
>>  }
