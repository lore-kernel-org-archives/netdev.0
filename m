From: Ben Greear <greearb@candelatech.com>
Subject: Re: af_packet.c bug?
Date: Mon, 28 Mar 2005 12:33:41 -0800
Message-ID: <42486A25.7080001@candelatech.com>
References: <424858D4.8060604@candelatech.com> <20050328195557.GF3086@postel.suug.ch> <4248642E.40304@candelatech.com> <20050328201738.GG3086@postel.suug.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "'netdev@oss.sgi.com'" <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Thomas Graf <tgraf@suug.ch>
In-Reply-To: <20050328201738.GG3086@postel.suug.ch>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Thomas Graf wrote:
> * Ben Greear <4248642E.40304@candelatech.com> 2005-03-28 12:08
> 
>>>Seems so, please adopt the size of spkt_device in struct sockaddr_pkt
>>
>>you mean adapt maybe?
> 
> 
> Of course, stupid typo. ;->
> 
>>I was also wondering why we couldn't hold a reference to the net-device
>>instead of just it's ifindex when dealing with a bound raw socket.
> 
> 
> Saving a netdevice handle in the packet socket is not a problem but
> doing the same for the packet socket address seems to be non trivial.

Yes.  But assuming you bind the socket, you use the device saved in the packet
socket.  If you are sending to a particular device for each send(), then you'll
just have to pay the lookup costs.  I haven't looked recently, but didn't someone
finally hash the device lookup so that it's not a linear walk of the device
list now?

Ben



-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com
