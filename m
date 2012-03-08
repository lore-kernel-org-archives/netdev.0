From: Richard Weinberger <richard@nod.at>
Subject: Re: [PATCH v6] Netfilter ring buffer support
Date: Thu, 08 Mar 2012 10:02:45 +0100
Message-ID: <4F5875B5.1090802@nod.at>
References: <1330989588-26833-1-git-send-email-richard@nod.at> <20120308012849.GA9164@1984>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: jengelh@medozas.de, eric.dumazet@gmail.com,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	netfilter-devel@vger.kernel.org, rostedt@goodmis.org
To: Pablo Neira Ayuso <pablo@netfilter.org>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20120308012849.GA9164@1984>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 08.03.2012 02:28, Pablo Neira Ayuso wrote:
> On Tue, Mar 06, 2012 at 12:19:42AM +0100, Richard Weinberger wrote:
>> This patch set merges ipt_LOG and ip6t_LOG and adds ring buffer support
>> to xt_LOG.
>>
>> Using "--ring" an user can create LOG rules which log messages into
>> one or more ring buffers.
>> Each ring buffer is represented as pipe-like file in
>> /proc/net/netfilter/nf_log_ring/.
>
> I've spent part of the evening testing this and checking its
> possibilities, the drawbacks that I see for this contribution are:
>
> * it uses the /proc entry, we have rejected similar add-ons in the
>    past that have used these interfaces.

My fist implementation used sysfs/debug.
I've switched to /proc/net/netfilter/ to make it consistent to the other
netfilter stuff...
Moving back to sysfs/debug/whatever can be done within minutes.

> * one single reader can be reading at a time.

In which use-cache you need two _consuming_ readers?
Steve's ring_buffer supports also concurrent non-consuming reads.
I can add support for this...

> Having said that, I still think that the feature that this provides
> is useful, but I think that implementing this in user-space over
> nfnetlink_log results in a much more flexible solution.
>
> I have made proof-of-concept daemon (it's a quick hack of several
> hours) that implements the similar feature over nfnetlink_log,
> advantages are:
>
> * You don't need to upgrade your kernel / iptables.
> * You only need to install libnfnetlink, libnetfilter_log and the
>    daemon.
> * It can be extended to support multiple readers.
>
> So my conclusion is that you can make this in userspace in a much more
> flexible way.
>
> You can find it here:
>
> http://1984.lsi.us.es/git/rlogd/
>
> The initial commit provides some description on how to use it:
>
> http://1984.lsi.us.es/git/rlogd/commit/?id=ccb88a8dc8ad674b860f2d3edabf07fe4830baf3
>
> I don't plan to develop / maintain that software. The last thing I
> want in my todo list is yet another thing to maintain. If someone is
> interested, please, feel free to grab it, make a nice website for it
> and maintain it.
>
> The repository also contains an unfinished patch to add LOG format
> support to libnetfilter_log.

I really don't like this rlogd thing.

1. It's yet another random netfilter userspace component.
Please don't fragment it more.
Installing iptables/conntrack/ulogd/etc... is already enough PITA 
because not all distros ship all this clustered components.

2. As I described in my very fist RLOG patch, NFLOG does not include the 
same information.
You cannot derive "PHYSIN" and "PHYSOUT" from the packet header.

3. rlogd needs NFLOG which copies every packet (header) to userspace.
What about performance...?

Thanks,
//richard
