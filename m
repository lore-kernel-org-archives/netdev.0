From: Daniel Borkmann <dborkman@redhat.com>
Subject: Re: [PATCH net] net: sctp: inherit auth_capable on INIT collisions
Date: Sat, 19 Jul 2014 01:23:08 +0200
Message-ID: <53C9AC5C.2090508@redhat.com>
References: <1405620319-2021-1-git-send-email-dborkman@redhat.com> <53C93157.1050002@gmail.com> <53C972BE.5090700@redhat.com> <53C998DE.2030805@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, jgunthorpe@obsidianresearch.com,
	netdev@vger.kernel.org, linux-sctp@vger.kernel.org
To: Vlad Yasevich <vyasevich@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:22230 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752278AbaGRXXU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 18 Jul 2014 19:23:20 -0400
In-Reply-To: <53C998DE.2030805@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 07/18/2014 11:59 PM, Vlad Yasevich wrote:
> On 07/18/2014 03:17 PM, Daniel Borkmann wrote:
>> On 07/18/2014 04:38 PM, Vlad Yasevich wrote:
>> ...
>>> Why is the original value of asoc->peer.auth_capable = 0?
>>> In case of collision, asoc is the old association that
>>> existed on the system.  That association was created as part of
>>> sending the INIT.  If it is processing a duplicate COOKIE-ECHO
>>> as you say, then it has already processed the INIT-ACK and
>>> should have determined that the peer is auth capable.
>>>
>>> Thus the capability of the new and the old associations should
>>> be same if we are in fact processing case B (collision).
>>>
>>> If not, then something else if wrong and my guess is that all
>>> other capabilities would be wrong too.
>>
>> I agree that they might likely also be flawed.
>>
>> Ok, let me dig further.
>
> So I think I know why case D ends up not authenticating the COOKIE-ACK.
> Most likely the reason is the following statement:
>   repl = sctp_make_cookie_ack(new_asoc, chunk);

That in fact lets COOKIE-ACK be AUTH'ed which weren't before,
so we should add that into the set. What happens though is
that subsequent AUTH+HBs from both sides remain unanswered,
so no AUTH+HB_ACK. This issue is independant of s/new_asoc/asoc/
though; disabling auth_enabled at both sides makes HB+HB_ACKs
work.

> Note that we use new_asoc, instead of current asoc.
>
> Not sure why case B is dumping core yet.
>
> -vlad
>
