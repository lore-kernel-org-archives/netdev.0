From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: Re: [RFC PATCH 00/29] net: VRF support
Date: Mon, 09 Feb 2015 21:48:15 +0100
Message-ID: <54D91D0F.9080003@6wind.com>
References: <1423100070-31848-1-git-send-email-dsahern@gmail.com>	<20150205173334.08248382@uryu.home.lan> <54D4227B.6080709@gmail.com>	<87r3u3vfpr.fsf@x220.int.ebiederm.org> <54D45C15.7090602@gmail.com> <87iofe7n1x.fsf@x220.int.ebiederm.org>
Reply-To: nicolas.dichtel@6wind.com
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Stephen Hemminger <stephen@networkplumber.org>,
	netdev@vger.kernel.org, roopa <roopa@cumulusnetworks.com>,
	hannes@stressinduktion.org,
	Dinesh Dutt <ddutt@cumulusnetworks.com>,
	Vipin Kumar <vipin@cumulusnetworks.com>
To: "Eric W. Biederman" <ebiederm@xmission.com>,
	David Ahern <dsahern@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f42.google.com ([74.125.82.42]:39327 "EHLO
	mail-wg0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759936AbbBIUsT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Feb 2015 15:48:19 -0500
Received: by mail-wg0-f42.google.com with SMTP id x13so29350657wgg.1
        for <netdev@vger.kernel.org>; Mon, 09 Feb 2015 12:48:17 -0800 (PST)
In-Reply-To: <87iofe7n1x.fsf@x220.int.ebiederm.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 06/02/2015 22:22, Eric W. Biederman a =C3=A9crit :
>
>
> Having looked at this problem, I am currently convinced that network
> namespaces can be improved to the point where they can reasonably
> act as VRFS.
We are using netns this way at 6WIND.

>
> Further I think code maintenance argues that this VRF proposal is a b=
ad
> direction to go.
>
> David Ahern <dsahern@gmail.com> writes:
>
>> On 2/5/15 9:14 PM, Eric W. Biederman wrote:
>>> David Ahern <dsahern@gmail.com> writes:
>>>
>>>> On 2/5/15 6:33 PM, Stephen Hemminger wrote:
>>>>> It is still not clear how adding another level of abstraction
>>>>> solves the scaling problem. Is it just because you can have one a=
pplication
>>>>> connect to multiple VRF's? so you don't need  N routing daemons?
>
>>>> All of those options are rather heavyweight and the number of 'thi=
ngs' is linear
>>>> with the number of VRFs. When multiplied by the number of services=
 needed for a
>>>> full-featured product the end result is a lot of wasted resources.
>>>
>>> If all you want is a single listening socket there are other
>>> implementation possibilities that are focused on solving just that
>>> problem, and would be much more generally applicable.
>>
>> These are examples of the higher level problem -- the current need f=
or
>> replicating processes/threads/sockets per namespace, not to mention =
the memory
>> consumed by the creation of the namespace itself which is fairly hig=
h. i.e., The
>> problem is more than just a listening socket of a single process.
>
> Sometimes replication is simpler and more efficient, so I do not beli=
eve
> this is a fundamental design problem.
>
> That said.  Having N listening sockets is arguably a mis-feature of t=
he
> berkely sockets layer, and is fixable by adding support for adding
> features for listening sockets to listen on more than one address.  S=
o
> by adding an feature to teach a listening socket how to listen on
> additional addresses that is fixable.  SCTP and MPTCP have even done
> some work in that area, so it may just be a matter of generalizing
> earlier solutions.  More likely we would want to build on Nicolas
> Dichtels work on adding ids to other network namespaces and have
> our VRF any sockets listen on any network namespace that we an for.
I agree, it would be great to have this kind of feature. Any help to
achieve it is welcomed :)

>
> Similarly we can build on Nicolas Dichtel's work of implementing in
> kernel ids for other network namespaces to provide proc files or
> netlink messages that report on multiple network namespaces at once.
> Assuming of course that such interfaces are shown to be worth
> implementing.
Same here. At least, we should have a try to have a status or to see wh=
ich
problems can block.

>
> I believe that with small focused changes we can make the existing
> userspace API efficient to work with for programs that want to work
> with multiple network namespaces (or VRFs) at once.
Yes, some work remains into this area.


Regards,
Nicolas
