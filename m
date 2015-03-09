From: Scott Feldman <sfeldma@gmail.com>
Subject: Re: [PATCH net-next v4 2/8] netdevice: add IPv4 fib add/del ops
Date: Mon, 9 Mar 2015 01:38:05 -0700
Message-ID: <CAE4R7bAoB4tWt1PYwxdXOubigkatSs2j2Xo5oLiEk48_k5RwBQ@mail.gmail.com>
References: <1425619280-27492-1-git-send-email-sfeldma@gmail.com>
	<1425619280-27492-3-git-send-email-sfeldma@gmail.com>
	<54F9BFCB.5030100@mojatatu.com>
	<CAE4R7bAcfJ8M0eQMdZdS3aDgPVWSQznABZymGq+PU34vJx1suA@mail.gmail.com>
	<54FC5D56.3090702@cumulusnetworks.com>
	<CAE4R7bCzV5zG5XPpgDAhO41Ym19W7Jd+97CMcJzOwwxLNOhTzA@mail.gmail.com>
	<54FD3C23.2010002@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Jamal Hadi Salim <jhs@mojatatu.com>,
	Netdev <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	=?UTF-8?B?SmnFmcOtIFDDrXJrbw==?= <jiri@resnulli.us>,
	"alexander.h.duyck@redhat.com" <alexander.h.duyck@redhat.com>
To: roopa <roopa@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qc0-f178.google.com ([209.85.216.178]:44793 "EHLO
	mail-qc0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751430AbbCIIiG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Mar 2015 04:38:06 -0400
Received: by qcwr17 with SMTP id r17so317649qcw.11
        for <netdev@vger.kernel.org>; Mon, 09 Mar 2015 01:38:05 -0700 (PDT)
In-Reply-To: <54FD3C23.2010002@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Mar 8, 2015 at 11:22 PM, roopa <roopa@cumulusnetworks.com> wrote:
> On 3/8/15, 3:16 PM, Scott Feldman wrote:
>>
>> On Sun, Mar 8, 2015 at 7:31 AM, roopa <roopa@cumulusnetworks.com> wrote:
>>>
>>> On 3/6/15, 11:59 AM, Scott Feldman wrote:

[cut]

>> Can you show an working example of prepend/append case where
>> programming hardware would be different than the replace case?
>>
>>
> scott, I don't have an example of kernel vs hw right now. But, since we only
> want to know if the switch driver can figure out
> the kernel route ordering in case of append vs replace, below kernel append
> and replace examples
> might help (just pasting it from my notes and may contain unneeded
> information).
>
> Thanks,
> Roopa
>
> append:
>
> =====
>
> #ipv4
>
> ip route show
>
> 10.0.12.2
>
>     nexthop via 10.0.13.2  dev dummy0 weight 1
>
>     nexthop via 10.0.14.2  dev dummy1 weight 1
>
>
> ip route append 10.0.12.2 nexthop via 10.0.15.2 dev dummy2
>
>
> ip monitor route
>
> 10.0.12.2 via 10.0.15.2 dev dummy2
>
>
> # A new route was appended
>
> ip route show
>
> 10.0.12.2
>
>     nexthop via 10.0.13.2  dev dummy0 weight 1
>
>     nexthop via 10.0.14.2  dev dummy1 weight 1
>
> 10.0.12.2 via 10.0.15.2 dev dummy2

I think you're right that append will be different than replace.  And
we'll need to pass in the netlink NLM_F_xxx flags to the API, so the
driver can deal with it.

-scott
