From: Ben Greear <greearb@candelatech.com>
Subject: Re: PATCH Re: udp weirdness
Date: Wed, 02 Oct 2002 08:25:37 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <3D9B0FF1.1070203@candelatech.com>
References: <3D99B6C7.3010302@nortelnetworks.com> <200210011531.TAA19943@sex.inr.ac.ru> <20021002111326.GG357@hookipa>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: kuznet@ms2.inr.ac.ru, Chris Friesen <cfriesen@nortelnetworks.com>,
   hadi@cyberus.CA, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Eric Lemoine <Eric.Lemoine@ens-lyon.fr>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Eric Lemoine wrote:
>>>I may have to poke around...if nothing else I'll learn more about the 
>>>networking code...
>>
>>It is difficult task, if possible at all.
>>
>>The main obstacle is that we must not block after select() succeeded,
>>otherwise applications will lockup. Taking into account nature of datagram
>>services (and generally of networking services, where routes change et al.)
>>you do not know at time of select(), where the datagram will go.
>>So, blocking can be made only based on a criterium not depending on this.
>>problems with silent losses. People just do not care about this, so
>>they get the thing which they deserve.
> 
> 
> Alexey,
> 
> Would you mind explaining a bit more why apps will lockup if we block
> after select() succeeded. Or anyone?

Actually, I'm more interested to know why we would **need** to block after
select has succeeded.  It would seem to me that select is busted in this
case.  For the case of a very large UDP packet and a small send buffer,
select gets confused, but at least when the send buffer is > 128k, it should
be right...


> 
> Thx.
> 
> 	Eric.
> 


-- 
Ben Greear <greearb@candelatech.com>       <Ben_Greear AT excite.com>
President of Candela Technologies Inc      http://www.candelatech.com
ScryMUD:  http://scry.wanfear.com     http://scry.wanfear.com/~greear
