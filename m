From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [Patch net] rtnetlink: call rtnl_lock_unregistering() in rtnl_link_unregister()
Date: Fri, 09 May 2014 16:05:27 -0700
Message-ID: <87bnv6lfig.fsf@x220.int.ebiederm.org>
References: <1399657653-4909-1-git-send-email-xiyou.wangcong@gmail.com>
	<20140509110345.417d2b90@nehalam.linuxnetplumber.net>
	<CAM_iQpUJ7q_RgFzJ7yu5F0aYSSCVAEu64UpwN=md0OyRGHBFAg@mail.gmail.com>
	<20140509120241.3b628dc1@nehalam.linuxnetplumber.net>
	<CAM_iQpWsbvC8nZd31n+akt2tQfCKvsHW6WAfjFdsgKNc5iiVig@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Stephen Hemminger <stephen@networkplumber.org>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	Cong Wang <cwang@twopensource.com>
To: Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out02.mta.xmission.com ([166.70.13.232]:55312 "EHLO
	out02.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756295AbaEIXGL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 May 2014 19:06:11 -0400
In-Reply-To: <CAM_iQpWsbvC8nZd31n+akt2tQfCKvsHW6WAfjFdsgKNc5iiVig@mail.gmail.com>
	(Cong Wang's message of "Fri, 9 May 2014 12:22:14 -0700")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Cong Wang <xiyou.wangcong@gmail.com> writes:

> On Fri, May 9, 2014 at 12:02 PM, Stephen Hemminger
> <stephen@networkplumber.org> wrote:
>> On Fri, 9 May 2014 11:10:36 -0700
>> Cong Wang <xiyou.wangcong@gmail.com> wrote:
>>
>>>
>>> This can't be done without a macro (at least for me). Or
>>> we have to duplicate the code.
>>
>> macro method is too ugly, figure out a better way.
>
> That's what I am going to do for -net-next. This patch is for -net,
> it's an ugly but minimum change I can find.
>
> Of course, if you insist we should clean up it for -net as well,
> I can do that.

It would be no worse to rename the existing function
rtnl_lock_unregistering_list

And add a second function rtnl_lock_unregistering that does
the same thing but uses the global list.

Of course this begs the question what happens if the network
device we want to destroy is a network namespace that is currently
exiting and not on the global list.

It looks like we need to grab the net_mutex to get a state where network
namespaces are not exiting...

Eric
