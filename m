From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [Patch net] rtnetlink: call rtnl_lock_unregistering() in rtnl_link_unregister()
Date: Sun, 11 May 2014 22:17:11 -0700
Message-ID: <CAM_iQpVYwx175-qbo4g80nHKbJ3XPYD5Py409Tmyt=zaJqgZ-Q@mail.gmail.com>
References: <1399657653-4909-1-git-send-email-xiyou.wangcong@gmail.com>
	<20140509110345.417d2b90@nehalam.linuxnetplumber.net>
	<CAM_iQpUJ7q_RgFzJ7yu5F0aYSSCVAEu64UpwN=md0OyRGHBFAg@mail.gmail.com>
	<20140509120241.3b628dc1@nehalam.linuxnetplumber.net>
	<CAM_iQpWsbvC8nZd31n+akt2tQfCKvsHW6WAfjFdsgKNc5iiVig@mail.gmail.com>
	<87bnv6lfig.fsf@x220.int.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Stephen Hemminger <stephen@networkplumber.org>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	Cong Wang <cwang@twopensource.com>
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f175.google.com ([209.85.214.175]:38756 "EHLO
	mail-ob0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750721AbaELFRL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 May 2014 01:17:11 -0400
Received: by mail-ob0-f175.google.com with SMTP id wo20so7450394obc.20
        for <netdev@vger.kernel.org>; Sun, 11 May 2014 22:17:11 -0700 (PDT)
In-Reply-To: <87bnv6lfig.fsf@x220.int.ebiederm.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, May 9, 2014 at 4:05 PM, Eric W. Biederman <ebiederm@xmission.com> wrote:
> Cong Wang <xiyou.wangcong@gmail.com> writes:
>
>> On Fri, May 9, 2014 at 12:02 PM, Stephen Hemminger
>> <stephen@networkplumber.org> wrote:
>>> On Fri, 9 May 2014 11:10:36 -0700
>>> Cong Wang <xiyou.wangcong@gmail.com> wrote:
>>>
>>>>
>>>> This can't be done without a macro (at least for me). Or
>>>> we have to duplicate the code.
>>>
>>> macro method is too ugly, figure out a better way.
>>
>> That's what I am going to do for -net-next. This patch is for -net,
>> it's an ugly but minimum change I can find.
>>
>> Of course, if you insist we should clean up it for -net as well,
>> I can do that.
>
> It would be no worse to rename the existing function
> rtnl_lock_unregistering_list
>
> And add a second function rtnl_lock_unregistering that does
> the same thing but uses the global list.
>
> Of course this begs the question what happens if the network
> device we want to destroy is a network namespace that is currently
> exiting and not on the global list.
>

OK, so we have to duplicate the code.

> It looks like we need to grab the net_mutex to get a state where network
> namespaces are not exiting...
>

Hmm, for me it looks like we need net_mutex only we change pernet ops,
here rtnl lock is enough. No?
