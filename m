From: Ben Greear <greearb@candelatech.com>
Subject: Re: [PATCH]  e100: Enable receiving bogus packets, and transmitting
 bad/custom CRC
Date: Mon, 24 Nov 2003 15:48:25 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <3FC298C9.8080302@candelatech.com>
References: <3FC2931B.3070903@candelatech.com> <20031124152933.1420f6cf.davem@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, scott.feldman@intel.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
In-Reply-To: <20031124152933.1420f6cf.davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

David S. Miller wrote:
> On Mon, 24 Nov 2003 15:24:11 -0800
> Ben Greear <greearb@candelatech.com> wrote:
> 
> 
>>Jeff, Dave, et al, please let me know if this is of interest!
> 
> 
> I think the rx_all facility is very useful.
> 
> Secondarily, I think we should address the other features
> seperately.
> 
> What I think you should do is split out the rx_all functionality
> into a seperate patch, and once we've refined and integrated that
> we can work one-by-one on the CRC and other bits.


So, RX-ALL can be one flag, another for RX-FCS, and the TX-CUSTOM-FCS
can be a separate patch altogether?

It would also be possible to add individual 'rx-foo', ie long, bad-crc, bad-frame, etc.
But, I think that would probably be over-kill at this point.

Any problem with using the netdev->priv_flags to hold the RX-ALL and RX-FCS flags?

Btw, it's impossible (afaik) to see the CRC errors generically w/out accessing netlink
(which I assume works, but have never actually tried), ie
there is no column in /proc/net/dev for rx-crc-errors.  It would be an excellent
time to allow me to add the ethtool hook to read the net_device_stats struct via
a single ioctl call! :)


Thanks,
Ben

-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com
