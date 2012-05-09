From: Oskar Berggren <oskar.berggren@gmail.com>
Subject: Re: ipctl - new tool for efficient read/write of net related sysctl
Date: Wed, 9 May 2012 07:22:39 +0200
Message-ID: <CAHOuc7Nd_=H6UVUYbjvy9cjYHu+x4kcGm8qTZqyb8dQu5tyR-g@mail.gmail.com>
References: <CAHOuc7MQiquWxMZ4YApXXKdsRY_StrTfAK9r_DdkstyYe+kCPQ@mail.gmail.com>
 <9241f146-d0f7-415b-a652-acd1bf34e95a@tahiti.vyatta.com> <CAHOuc7PjmcF=EhEUDEqfF_RShezxDqzc+53frNwWqhww8YQ+mA@mail.gmail.com>
 <20120507061422.GA21089@canuck.infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
To: Oskar Berggren <oskar.berggren@gmail.com>,
	Stephen Hemminger <stephen.hemminger@vyatta.com>,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f174.google.com ([209.85.214.174]:57754 "EHLO
	mail-ob0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751365Ab2EIFXA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 May 2012 01:23:00 -0400
Received: by obbtb18 with SMTP id tb18so10783818obb.19
        for <netdev@vger.kernel.org>; Tue, 08 May 2012 22:23:00 -0700 (PDT)
In-Reply-To: <20120507061422.GA21089@canuck.infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2012/5/7 Thomas Graf <tgraf@infradead.org>:
> On Sun, May 06, 2012 at 02:46:01PM +0200, Oskar Berggren wrote:
>> 2012/5/6 Stephen Hemminger <stephen.hemminger@vyatta.com>:
>> >
>> >>
>> >> In a project of mine I need to read (and possibly set) many of the
>> >> properties
>> >> found under /proc/sys/net/ipv4/conf/. This is simple enough, except
>> >> that
>> >> when you have hundreds of interfaces, it is really slow. In my tests
>> >> it takes
>> >> about 4 seconds to read a single variable for 700 interfaces. For a
>> >> while I
>> >> worked around this using the binary sysctl() interface, but this is
>> >> deprecated.
>> >>
>> >
>> > What about exposing these as NETLINK attributes? That would be faster
>> > and you could do bulk updates.
>>
>>
>> This is my first attempt at using NETLINK, so could you please elaborate?
>> Below is the generic netlink interface I implemented so far. Any pointers
>> on how I should do this differently?
>
> What Stephen means is to use the existing message types RTM_SETLINK
> and RTM_GETLINK in the NETLINK_ROUTE family.
>
> This is already partially implemented. See the IFLA_AF_SPEC attribute
> carrying IPV4_DEVCONF_ and DEVCONF_ (IPv6). Grep for rtnl_af_register()
> and you will find the corresponding implementations.
>
> Feel free to complete these existing interfaces, such as adding write
> support to IPv6 or adding support to iproute2 which is currently
> lacking.


Cool, this seems to be exactly what I need. I'll experiment with it
when I get the time.

/Oskar
