From: Ben Greear <greearb@candelatech.com>
Subject: Re: An interface goes away while a socket is bound to it..what happens?
Date: Mon, 17 Jan 2005 22:44:43 -0800
Message-ID: <41ECB05B.8060207@candelatech.com>
References: <41EC825B.4030603@candelatech.com> <20050117193945.3d3b1860.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
In-Reply-To: <20050117193945.3d3b1860.davem@davemloft.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

David S. Miller wrote:
> On Mon, 17 Jan 2005 19:28:27 -0800
> Ben Greear <greearb@candelatech.com> wrote:
> 
> 
>>The interesting part to me is that I do not appearantly see any errors
>>while continuing to send UDP packets on the socket that was bound to the
>>original ppp0 interface, and yet no packets are ever routed over the new
>>ppp0 interface.  I would expect it to either fail the write, or to just
>>magically keep working.
> 
> 
> If you have bound to the local IP address, when your T1 goes down
> that local IP address should no longer be assosciated with the
> system even when the PPP interface comes back up, so what should
> happen is that the route lookup in udp_sendmsg() will fail and sendmsg()
> will return with that error code.

Well, the new interface will come back with the same name, and same IP.

Also, I bind to the local interface with BIND_TO_DEVICE.  I can imagine
how that might confuse things...

I will do some double-checking to make sure I'm not missing an error
code on the sendmsg call...

Ben


-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com
