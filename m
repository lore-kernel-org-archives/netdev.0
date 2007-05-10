From: "Injong Rhee" <rhee@eos.ncsu.edu>
Subject: Re: 2.6.20.7 TCP cubic (and bic) initial slow start way too slow?
Date: Thu, 10 May 2007 16:57:04 -0400
Message-ID: <002301c79345$c45ffd00$4a580e98@ncsu2cc0c3fa00>
References: <20070509023131.70e2cc45.billfink@mindspring.com><20070510113215.f5ff2d34.billfink@mindspring.com><2994.152.14.88.74.1178822365.squirrel@webmail.ncsu.edu><20070510.133522.99205764.davem@davemloft.net> <20070510134547.7ec30308@freepuppy>
Mime-Version: 1.0
Content-Type: text/plain;
	format=flowed;
	charset="ISO-8859-1";
	reply-type=original
Content-Transfer-Encoding: 7bit
Cc: <rhee@ncsu.edu>, <billfink@mindspring.com>, <sangtae.ha@gmail.com>,
	<netdev@vger.kernel.org>
To: "Stephen Hemminger" <shemminger@linux-foundation.org>,
	"David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from uni12mr.unity.ncsu.edu ([152.1.1.171]:55324 "EHLO
	uni12mr.unity.ncsu.edu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757046AbXEJVMa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 May 2007 17:12:30 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Oops. I thought Bill was using 2.6.20 instead of 2.6.22 which should contain 
our latest update.

Regarding slow start behavior, the latest version should not change though. 
I think it would be ok to change the slow start of bic and cubic to the 
default slow start. But what we observed is that when BDP is large, 
increasing cwnd by two times is really an overkill. consider increasing from 
1024 into 2048 packets..maybe the target is somewhere between them. We have 
potentially a large number of packets flushed into the network. That was the 
original motivation to change slow start from the default into a more gentle 
version. But I see the point that Bill is raising. We are working on 
improving this behavior in our lab. We will get back to this topic in a 
couple of weeks after we finish our testing and produce a patch.


----- Original Message ----- 
From: "Stephen Hemminger" <shemminger@linux-foundation.org>
To: "David Miller" <davem@davemloft.net>
Cc: <rhee@ncsu.edu>; <billfink@mindspring.com>; <sangtae.ha@gmail.com>; 
<netdev@vger.kernel.org>
Sent: Thursday, May 10, 2007 4:45 PM
Subject: Re: 2.6.20.7 TCP cubic (and bic) initial slow start way too slow?


> On Thu, 10 May 2007 13:35:22 -0700 (PDT)
> David Miller <davem@davemloft.net> wrote:
>
>> From: rhee@ncsu.edu
>> Date: Thu, 10 May 2007 14:39:25 -0400 (EDT)
>>
>> >
>> > Bill,
>> > Could you test with the lastest version of CUBIC? this is not the 
>> > latest
>> > version of it you tested.
>>
>> Rhee-sangsang-nim, it might be a lot easier for people if you provide
>> a patch against the current tree for users to test instead of
>> constantly pointing them to your web site.
>> -
>
> The 2.6.22 version should have the latest version, that I know of.
> There was small patch from 2.6.21 that went in.
> 


