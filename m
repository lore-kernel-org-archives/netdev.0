From: Ben Greear <greearb@candelatech.com>
Subject: Re: How to count tx and rx bytes?
Date: Mon, 15 Dec 2003 15:17:29 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <3FDE4109.7090603@candelatech.com>
References: <3FDE13AE.3050402@candelatech.com>	<20031215141729.15387fc1.davem@redhat.com>	<3FDE39E3.4000408@candelatech.com> <20031215145422.58a78551.davem@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
In-Reply-To: <20031215145422.58a78551.davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

David S. Miller wrote:
> On Mon, 15 Dec 2003 14:46:59 -0800
> Ben Greear <greearb@candelatech.com> wrote:
> 
> 
>>Maybe the stats-polling code in the driver could do the necessary subtraction
>>to remove the FCS from the results (ie, subtract (packets-since-last-sample * 4) bytes.
> 
> 
> The whole reason to use the chip internally computed stats is to avoid
> having to do "stats->foo++" at all, your suggestion basically eliminates
> this purpose.

Well, I was assuming that the stats polling is a fixed cost O(1), where-as the per-packet
calculation is O(n).  I am quite sure this assumption is true for e1000,
but I have not looked at tg3.  So, for e1000, the cost of subtracting out the FCS
would be basically free.

All that said, from Randy's email, it appears we should be including the FCS
anyway...

Ben

-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com
