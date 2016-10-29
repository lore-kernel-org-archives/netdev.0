From: Xin Long <lucien.xin@gmail.com>
Subject: Re: [PATCH net 2/3] sctp: return back transport in __sctp_rcv_init_lookup
Date: Sun, 30 Oct 2016 01:29:07 +0800
Message-ID: <CADvbK_cwNsqFiHhWQM1g4XhK4v4rjZ7gEvtcYWKdZDnZmfeEnQ@mail.gmail.com>
References: <cover.1477649076.git.lucien.xin@gmail.com> <5ebf537ea021af594ca1b2538d28a3080d5c3ee7.1477649076.git.lucien.xin@gmail.com>
 <20161028194221.GC4193@localhost.localdomain> <20161028213943.GA14175@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: network dev <netdev@vger.kernel.org>, linux-sctp@vger.kernel.org,
        davem <davem@davemloft.net>, Vlad Yasevich <vyasevich@gmail.com>,
        Daniel Borkmann <daniel@iogearbox.net>
To: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qt0-f196.google.com ([209.85.216.196]:36742 "EHLO
        mail-qt0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751412AbcJ2R3I (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 29 Oct 2016 13:29:08 -0400
In-Reply-To: <20161028213943.GA14175@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Oct 29, 2016 at 5:39 AM, Marcelo Ricardo Leitner
<marcelo.leitner@gmail.com> wrote:
> On Fri, Oct 28, 2016 at 05:42:21PM -0200, Marcelo Ricardo Leitner wrote:
>> On Fri, Oct 28, 2016 at 06:10:53PM +0800, Xin Long wrote:
>> > Prior to this patch, it used a local variable to save the transport that is
>> > looked up by __sctp_lookup_association(), and didn't return it back. But in
>> > sctp_rcv, it is used to initialize chunk->transport. So when hitting this
>> > code, it was initializing chunk->transport with some random stack value
>> > instead.
here should be:
So when hitting this, even if it found the transport, it was still initializing
chunk->transport with null instead.

>> >
>> > This patch is to return the transport back through transport pointer
>> > that is from __sctp_rcv_lookup_harder().
>> >
>> > Signed-off-by: Xin Long <lucien.xin@gmail.com>
>>
>> Acked-by: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
>>
>> transport pointer in sctp_rcv() is initialized to null and there are
>> checks for it after this path, so this shouldn't be exploitable, just
>> malfunction.
>
> This actually sort of contradicts the changelog.
>
> Xin, did I miss something here? Seems we need to update the changelog if
> not.
>
You're right, thanks, will repost.
