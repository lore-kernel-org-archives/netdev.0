From: Jerry Chu <hkchu@google.com>
Subject: Re: [PATCH] TCP_FAILFAST: a new socket option to timeout/abort a
 connection quicker
Date: Tue, 24 Aug 2010 13:47:11 -0700
Message-ID: <AANLkTimsVzH_aNkN3ZS+AuzvJBTVea8GKLPXanWYMe3t@mail.gmail.com>
References: <1282630819-23104-1-git-send-email-hkchu@google.com>
	<1282632262.2378.1681.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: ilpo.jarvinen@helsinki.fi, davem@davemloft.net,
	netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([216.239.44.51]:4538 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753110Ab0HXUr2 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Aug 2010 16:47:28 -0400
Received: from kpbe14.cbf.corp.google.com (kpbe14.cbf.corp.google.com [172.25.105.78])
	by smtp-out.google.com with ESMTP id o7OKlRih027645
	for <netdev@vger.kernel.org>; Tue, 24 Aug 2010 13:47:27 -0700
Received: from gwb15 (gwb15.prod.google.com [10.200.2.15])
	by kpbe14.cbf.corp.google.com with ESMTP id o7OKlPc3016915
	for <netdev@vger.kernel.org>; Tue, 24 Aug 2010 13:47:26 -0700
Received: by gwb15 with SMTP id 15so173510gwb.40
        for <netdev@vger.kernel.org>; Tue, 24 Aug 2010 13:47:25 -0700 (PDT)
In-Reply-To: <1282632262.2378.1681.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Aug 23, 2010 at 11:44 PM, Eric Dumazet <eric.dumazet@gmail.com>=
 wrote:
> Le lundi 23 ao=FBt 2010 =E0 23:20 -0700, H.K. Jerry Chu a =E9crit :
>> From: Jerry Chu <hkchu@google.com>
>>
>> This is a TCP level socket option that takes an unsigned int to spec=
ify
>> how long in ms TCP should resend a lost data packet before giving up
>> and returning ETIMEDOUT. The normal TCP retry/abort timeout limit st=
ill
>> applies. In other words this option is only meant for those applicat=
ions
>> that need to "fail faster" than the default TCP timeout. The latter
>> may take upto 20 minutes in a normal WAN environment.
>>
>> The option is disabled (by default) when set to 0. Also it does not
>> apply during the connection establishment phase.
>>
>> Signed-off-by: H.K. Jerry Chu <hkchu@google.com>
>
> TCP_FAILFAST might be misleading. It reads as a boolean option, while
> its an option to cap the timeout, with a time unit, instead of the us=
ual
> "number of retransmits".

I'm open to better names. Perhaps it can be combined with TCP_UTO
mentioned in subsequent reply?

>
> Its also funny you dont ask for a default value, given by a sysctl
> tunable ;)

This socket option takes time unit directly. The other sysctls
use # of retries and max_rto. (Not sure if that's what you asked.)

>
>
>
>
