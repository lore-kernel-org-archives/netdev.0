From: David Decotigny <ddecotig@gmail.com>
Subject: Re: [ethtool PATCH v4 11/11] ethtool.c: support absence of v4 sockets
Date: Tue, 15 Mar 2016 16:19:11 -0700
Message-ID: <CAG88wWbKagbn7yUVVi2GW8t1amMWZOsCdNqmB_-mZuozXQfkVA@mail.gmail.com>
References: <1457719104-39188-1-git-send-email-ddecotig@gmail.com>
 <1457719104-39188-12-git-send-email-ddecotig@gmail.com> <1457889843.3331.36.camel@decadent.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Jeff Garzik <jgarzik@pobox.com>,
	David Miller <davem@redhat.com>,
	Vidya Sagar Ravipati <vidya@cumulusnetworks.com>,
	Joe Perches <joe@perches.com>
To: Ben Hutchings <ben@decadent.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f51.google.com ([74.125.82.51]:35382 "EHLO
	mail-wm0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S964832AbcCOXTd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Mar 2016 19:19:33 -0400
Received: by mail-wm0-f51.google.com with SMTP id l68so168942931wml.0
        for <netdev@vger.kernel.org>; Tue, 15 Mar 2016 16:19:32 -0700 (PDT)
In-Reply-To: <1457889843.3331.36.camel@decadent.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

will send a v5 shortly without this patch: question below.

about this patch: this is in prevision of a world where INET can be
compiled out. So it is not something that matters today with current
kernels.

Now, as you mentioned in another patch, the only socket that survives
various reasonable CONFIG_* gymnastics is netlink. So even though
non-IPv4 kernels with IP support is not feasible today, I believe
there is some logic to using netlink sockets for ethtool purposes,
instead of IPv4 or IPv6 sockets. Shall I propose a patch to add
ethtool support on AF_NETLINK sockets, and update the tool to try
AF_INET first for backward compatibility reasons, then fallback to
AF_NETLINK?

On Sun, Mar 13, 2016 at 10:24 AM, Ben Hutchings <ben@decadent.org.uk> wrote:
> On Fri, 2016-03-11 at 09:58 -0800, David Decotigny wrote:
>> From: David Decotigny <decot@googlers.com>
>>
>>
>> Signed-off-by: David Decotigny <decot@googlers.com>
>> ---
>>  ethtool.c | 3 +++
>>  1 file changed, 3 insertions(+)
>>
>> diff --git a/ethtool.c b/ethtool.c
>> index 761252f..f9336e3 100644
>> --- a/ethtool.c
>> +++ b/ethtool.c
>> @@ -4615,6 +4615,9 @@ opt_found:
>>               /* Open control socket. */
>>               ctx.fd = socket(AF_INET, SOCK_DGRAM, 0);
>>               if (ctx.fd < 0) {
>> +                     ctx.fd = socket(AF_UNIX, SOCK_DGRAM, 0);
>> +             }
>
> You still haven't answered whether this is a real problem on Linux.
>
> Ben.
>
>> +             if (ctx.fd < 0) {
>>                       perror("Cannot get control socket");
>>                       return 70;
>>               }
> --
> Ben Hutchings
> If at first you don't succeed, you're doing about average.
