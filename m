From: Ben Greear <greearb@candelatech.com>
Subject: Re: 2.6.7 tulip performance (with NAPI)
Date: Wed, 06 Oct 2004 14:37:11 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <41646587.7070401@candelatech.com>
References: <41633174.7070805@candelatech.com> <16740.17875.574967.11417@robur.slu.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "'netdev@oss.sgi.com'" <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Robert Olsson <Robert.Olsson@data.slu.se>
In-Reply-To: <16740.17875.574967.11417@robur.slu.se>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Robert Olsson wrote:
> Ben Greear writes:
> 
>  > I tried setting the NICE level of pktgen to -10 and softirq to -18.  I
>  > still see way more packets transmitted than received.
> 
>  If you have "max_before_softirq" in your version pktgen you can try it
>  to balance your load. HZ=1000 in 2.6 can make scheduling different.

Yes, I was able to get it to smooth out by doing something like that.  I
also got better desktop performance by simply decreasing the niceness of
the pktgen thread to 0 instead of -10.

On a related note, I am now working on a way to use a hook in the
netif_wake_queue callback to wake up pktgen.  This should allow me to
have a pktgen that does not need to spin in a tight loop like it does
now.  So far, I was able to saturate two GigE ports using about 3% of
the CPU (as reported by top), using 1514 byte pkts.  Still tweaking
to fix some corner cases...

Thanks,
Ben

-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com
