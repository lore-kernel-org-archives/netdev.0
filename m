From: Ben Greear <greearb@candelatech.com>
Subject: Re: MAC-VLANS
Date: Tue, 05 Aug 2003 21:10:47 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <3F307FC7.10908@candelatech.com>
References: <3F304CBF.6050902@candelatech.com> <20030805204028.644895dc.davem@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
In-Reply-To: <20030805204028.644895dc.davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

David S. Miller wrote:
> On Tue, 05 Aug 2003 17:33:03 -0700
> Ben Greear <greearb@candelatech.com> wrote:
> 
> 
>>In order to get MAC-VLANs to work, the only way I can see to make
>>it happen is to put a hook into dev.c in the:
> 
> 
> Why not do it the same we do normal VLAN's?  Ie. directly
> in the device driver receive method via something akin to
> the vlan_hwaccel_*() routines.

You mean in eth.c or something?  I don't want to have to put
identical code in all drivers, if that's what you're suggesting.
It could be done to common drivers if the feature is used enough
to warrant it, but we definately need a fallback case to work with
all generic drivers, just as .1q does.

802.1q works because we have an extra shim header in there..but
MAC-vlans have no extra header info.  It would be nice to have
a separate 'protocol' list that was able to consume the pkt: that
would allow this to work w/out additional hacks, and could work for
pktgen rx and even bridging.  Of course, not all could be active
at once, but that is no worse than 'hooks' in that regard.  And,
evil ppl could re-write the IP stack, of course, but that doesn't
bother me as much as some folks :)

Ben

-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com
