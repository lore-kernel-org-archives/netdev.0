From: Nicolas Cavallari <Nicolas.Cavallari@lri.fr>
Subject: Re: Throughput regression with `tcp: refine TSO autosizing`
Date: Fri, 06 Feb 2015 10:39:34 +0100
Message-ID: <54D48BD6.2060202@lri.fr>
References: <CA+BoTQkVu23P3EOmY_Q3E1GJnWsyF==Pawz4iPOS_Bq5dvfO5Q@mail.gmail.com>	 <CA+BoTQmvUuFdfYF=wVMYxrf_nQZB5GCV=LvDZVvfs-3hAE4WKw@mail.gmail.com>	 <1423051045.907.108.camel@edumazet-glaptop2.roam.corp.google.com>	 <CA+BoTQ=BDcQ779uKCuX+f40=4npXVF4MTQnpjKimNYAxPsxBoQ@mail.gmail.com>	 <1423053531.907.115.camel@edumazet-glaptop2.roam.corp.google.com>	 <CA+BoTQ=qmCZz4CmSOvCOzMLowrDEG12XBffkTcYxjGqVD9604g@mail.gmail.com>	 <1423055810.907.125.camel@edumazet-glaptop2.roam.corp.google.com>	 <1423056591.907.130.camel@edumazet-glaptop2.roam.corp.google.com>	 <1423084303.31870.15.camel@edumazet-glaptop2.roam.corp.google.com>	 <CA+BoTQnnwrv0nrKyGyQNvosz_E4e5fBa9iN8fpeqcd-iRfi17g@mail.gmail.com>	 <1423141038.31870.38.camel@edumazet-glaptop2.roam.corp.google.com>	 <1423142342.31870.49.camel@edumaze
 t-glaptop2.roam.corp.google.com>	 <CA+BoTQmcShK0U_cXvEOLY_8y7LH8x3taTgjcyMzv0MLVn4UtCA@mail.gmail.com> <1423147722.31870.65.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: Neal Cardwell <ncardwell@google.com>,
	linux-wireless <linux-wireless@vger.kernel.org>,
	Network Development <netdev@vger.kernel.org>,
	eyalpe@dev.mellanox.co.il
To: Eric Dumazet <eric.dumazet@gmail.com>,
	Michal Kazior <michal.kazior@tieto.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.kundenserver.de ([212.227.17.10]:63931 "EHLO
	mout.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750751AbbBFJjy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Feb 2015 04:39:54 -0500
In-Reply-To: <1423147722.31870.65.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 05/02/2015 15:48, Eric Dumazet wrote:
> On Thu, 2015-02-05 at 14:44 +0100, Michal Kazior wrote:
> 
>> I do get your point. But 1.5ms is really tough on Wi-Fi.
>>
>> Just look at this:
>>
>> ; ping 192.168.1.2 -c 3
>> PING 192.168.1.2 (192.168.1.2) 56(84) bytes of data.
>> 64 bytes from 192.168.1.2: icmp_seq=1 ttl=64 time=1.83 ms
>> 64 bytes from 192.168.1.2: icmp_seq=2 ttl=64 time=2.02 ms
>> 64 bytes from 192.168.1.2: icmp_seq=3 ttl=64 time=1.98 ms
> 
> Thats a different point.
> 
> I dont care about rtt but TX completions. (usually much much lower than
> rtt)

On wired network perhaps, but definitely not on Wi-Fi.

With aggregation, you may send up to 4ms of data before the receiver
can acknowledge anything. But you have to gain access to the channel
first, so you may wait while others finish off their 4ms
transmissions. And this does not account for retransmissions.

And aggregation is not the only problem as far as bufferbloat is
concerned. I don't even want to think about powersave.
