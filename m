From: Tom Herbert <tom@herbertland.com>
Subject: Re: [PATCH RFC 0/2] kproxy: Kernel Proxy
Date: Thu, 29 Jun 2017 16:21:32 -0700
Message-ID: <CALx6S37ZnymFfXWAV34iXbZd_XA3QeC+rQ+RnSVNi_Mg5eHhyg@mail.gmail.com>
References: <1498760825-8516-1-git-send-email-tom@herbertland.com> <CACby=pnLJRawb40Ym1_85+8P7vmkwLJqfsv=bYyeHHa8KWPwNA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: netdev <netdev@vger.kernel.org>,
        "David S. Miller" <davem@davemloft.net>
To: Thomas Graf <tgraf@suug.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f171.google.com ([209.85.128.171]:36147 "EHLO
        mail-wr0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751537AbdF2XVe (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 29 Jun 2017 19:21:34 -0400
Received: by mail-wr0-f171.google.com with SMTP id c11so196489195wrc.3
        for <netdev@vger.kernel.org>; Thu, 29 Jun 2017 16:21:34 -0700 (PDT)
In-Reply-To: <CACby=pnLJRawb40Ym1_85+8P7vmkwLJqfsv=bYyeHHa8KWPwNA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jun 29, 2017 at 3:04 PM, Thomas Graf <tgraf@suug.ch> wrote:
> Hi Tom
>
> On 29 June 2017 at 11:27, Tom Herbert <tom@herbertland.com> wrote:
>> This is raw, minimally tested, and error hanlding needs work. Posting
>> as RFC to get feedback on the design...
>>
>> Sidecar proxies are becoming quite popular on server as a means to
>> perform layer 7 processing on application data as it is sent. Such
>> sidecars are used for SSL proxies, application firewalls, and L7
>> load balancers. While these proxies provide nice functionality,
>> their performance is obviously terrible since all the data needs
>> to take an extra hop though userspace.
>
Hi Thomas,

> I really appreciate this work. It would have been nice to at least
> attribute me in some way as this is exactly what I presented at
> Netconf 2017 [0].
>
Sure, will do that!

> I'm also wondering why this is not built on top of KCM which you
> suggested to use when we discussed this.
>

I think the main part of that discussion was around stream parser
which is needed for message delineation. For a 1:1 proxy,  KCM is
probably overkill (the whole KCM data path and lock becomes
superfluous). Also, there's no concept of creating a whole message
before routing it, in the 1:1 case we should let the message pass
through once it's cleared by the filter (this is the strparser change
I referred to). As I mentioned, for L7 load balancing we would want a
multiplexor probably also M:N, but the structure is different since
there's still no user facing sockets, they're all TCP for instance.
IMO, the 1:1 proxy case is compelling to solve in itself...

Tom



> [0] https://docs.google.com/presentation/d/1dwSKSBGpUHD3WO5xxzZWj8awV_-xL-oYhvqQMOBhhtk/edit#slide=id.g203aae413f_0_0
