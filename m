From: Tom Herbert <therbert@google.com>
Subject: Re: [PATCH v5] rfs: Receive Flow Steering
Date: Tue, 20 Apr 2010 08:04:34 -0700
Message-ID: <t2y65634d661004200804r15427f19k9d58862f05df94aa@mail.gmail.com>
References: <1271452358.16881.4486.camel@edumazet-laptop>
	 <1271520633.16881.4754.camel@edumazet-laptop>
	 <20100419.130905.210660275.davem@davemloft.net>
	 <20100419.132318.192086187.davem@davemloft.net>
	 <1271709121.3845.94.camel@edumazet-laptop>
	 <y2u412e6f7f1004191638mee9206dfoab7482bbff83e38d@mail.gmail.com>
	 <1271743164.3845.128.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Changli Gao <xiaosuo@gmail.com>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([216.239.44.51]:23489 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751214Ab0DTPEj convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Apr 2010 11:04:39 -0400
Received: from wpaz29.hot.corp.google.com (wpaz29.hot.corp.google.com [172.24.198.93])
	by smtp-out.google.com with ESMTP id o3KF4aEF018935
	for <netdev@vger.kernel.org>; Tue, 20 Apr 2010 08:04:37 -0700
Received: from pvc21 (pvc21.prod.google.com [10.241.209.149])
	by wpaz29.hot.corp.google.com with ESMTP id o3KF4Z44030078
	for <netdev@vger.kernel.org>; Tue, 20 Apr 2010 08:04:35 -0700
Received: by pvc21 with SMTP id 21so48426pvc.41
        for <netdev@vger.kernel.org>; Tue, 20 Apr 2010 08:04:34 -0700 (PDT)
In-Reply-To: <1271743164.3845.128.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Apr 19, 2010 at 10:59 PM, Eric Dumazet <eric.dumazet@gmail.com>=
 wrote:
> Le mardi 20 avril 2010 =E0 07:38 +0800, Changli Gao a =E9crit :
>
>> Does this problem has relationship with your patch? No. If the rxhas=
h
>> isn't provided by hardware, we can get more throughput from you patc=
h,
>> and on the other side, we don't lose anything but potential more has=
h
>> collision.
>>
>
> I am not sure what you call hash collision. There is no hash chain he=
re.
>
> This 32bit hash is a jhash one, and we only need 1 to 12 bits in it, =
I
> am pretty sure its OK.
>
Maybe for the purposes of RPS, but hash collisions could definitely be
an issue in RFS.  If two active connections hit the same rps_flow
entry this may cause thrashing of those connections between CPUs.  I
think your patch may increase the probability of this happening.

>
>
>
