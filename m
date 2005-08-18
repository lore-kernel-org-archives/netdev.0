From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH] fix dst_entry leak in icmp_push_reply()
Date: Thu, 18 Aug 2005 20:42:52 +0200
Message-ID: <4304D6AC.4060606__6504.84098955548$1124390873$gmane$org@trash.net>
References: <43039C3F.2000207@rincewind.tv> <4303CEC5.3010502@trash.net> <43042D94.4030303@rincewind.tv>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, Maillist netdev <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Ollie Wild <aaw@rincewind.tv>
In-Reply-To: <43042D94.4030303@rincewind.tv>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Ollie Wild wrote:
> Patrick McHardy wrote:
> 
>> Ollie Wild wrote:
>>
>>> If the ip_append_data() call in icmp_push_reply() fails,
>>> ip_flush_pending_frames() needs to be called.  Otherwise, ip_rt_put()
>>> is never called on inet_sk(icmp_socket->sk)->cork.rt, which prevents
>>> the route (and net_device) from ever being freed.
>>
>> Your patch doesn't fit your description, the else-condition you're
>> adding triggers when the queue is empty, so what is the point?
> 
> Since we're only calling ip_append_data() once here, the two conditions
> are identical.

You're right, I misread your patch. It would be easier to understand
if you just checked the return value of ip_append_data, as done in
udp.c or raw.c.
