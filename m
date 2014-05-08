From: Andy Lutomirski <luto@amacapital.net>
Subject: Re: [PATCH 5/5] net: Use netlink_ns_capable to verify the permisions
 of netlink messages
Date: Thu, 8 May 2014 14:54:01 -0700
Message-ID: <CALCETrUdhoNRf8xfXD9WXq6qk+oRy-BV0+T6fj0T3EQHMkO3Rg@mail.gmail.com>
References: <CALCETrVo7ducU3S25Z_4NDB1p72pSLU0oLQh-ppxEWMgqYyjqQ@mail.gmail.com>
 <20140507.194514.1312153135098382943.davem@davemloft.net> <20140508142121.2c68bcc3@nehalam.linuxnetplumber.net>
 <20140508.175203.407524650572709785.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: stephen@networkplumber.org,
	"Jorge Boncompte [DTI2]" <jorge@dti2.net>,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	Vivek Goyal <vgoyal@redhat.com>,
	Simo Sorce <ssorce@redhat.com>,
	"security@kernel.org" <security@kernel.org>,
	Network Development <netdev@vger.kernel.org>,
	"Serge E. Hallyn" <serge@hallyn.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ve0-f171.google.com ([209.85.128.171]:36094 "EHLO
	mail-ve0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753348AbaEHVyW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 May 2014 17:54:22 -0400
Received: by mail-ve0-f171.google.com with SMTP id oz11so4106317veb.16
        for <netdev@vger.kernel.org>; Thu, 08 May 2014 14:54:21 -0700 (PDT)
In-Reply-To: <20140508.175203.407524650572709785.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, May 8, 2014 at 2:52 PM, David Miller <davem@davemloft.net> wrote:
> From: Stephen Hemminger <stephen@networkplumber.org>
> Date: Thu, 8 May 2014 14:21:21 -0700
>
>> On Wed, 07 May 2014 19:45:14 -0400 (EDT)
>> David Miller <davem@davemloft.net> wrote:
>>
>>> From: Andy Lutomirski <luto@amacapital.net>
>>> Date: Wed, 7 May 2014 16:01:33 -0700
>>>
>>> > On Wed, May 7, 2014 at 3:52 PM, David Miller <davem@davemloft.net> wrote:
>>> >> From: Andy Lutomirski <luto@amacapital.net>
>>> >> Date: Wed, 7 May 2014 15:26:11 -0700
>>> >>
>>> >>> So what do we do?  Check permissions on connect and then use the
>>> >>> cached result for send on a connected socket?  Check permitted caps
>>> >>> instead of effective caps?
>>> >>
>>> >> It should create the socket after changing perms.
>>> >
>>> > I agree that it should, but it doesn't, and if these patches get
>>> > backported, things will break.  OTOH, if the patches don't get
>>> > backported, things may still break, and we have a possibly rather
>>> > severe unfixed vulnerability.
>>>
>>> I think the kernel change is justified as the privilege allowance
>>> that happened before was very much unintentional and as you've
>>> shown us countless times a very real problem that we must fix.
>>
>> One of the problems here is that Quagga may generate millions of
>> netlink messages to change routes in response to link flap.
>> Raising/lowering the permissions around each request would have
>> a significant performance impact.
>
> What we want to matter are the permissions the process had when the
> socket was created/bound, after that you can drop privs and send
> netlink requests as you like.

I would agree if this were a brand new interface.  Unfortunately,
there might be programs that assume it's okay to do things like
creating a non-O_CLOEXEC netlink socket, dropping privileges, and
execing.

--Andy
