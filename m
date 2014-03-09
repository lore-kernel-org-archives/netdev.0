From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: [PATCH net-next v4 1/4] ieee802154: add
 generic header handling routines
Date: Sun, 09 Mar 2014 18:49:17 -0400 (EDT)
Message-ID: <20140309.184917.1068147707004916460.davem@davemloft.net>
References: <cc9ba7943aebff9ba87b60778b62f1a8.squirrel@webmail.itwm.fhg.de>
	<20140304.172025.2034977449200344617.davem@davemloft.net>
	<1394387943.15968.1.camel@deadeye.wl.decadent.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: linux-zigbee-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: ben-/+tVBieCtBitmTQ+vhA3Yw@public.gmane.org
Return-path: <linux-zigbee-devel-bounces-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
In-Reply-To: <1394387943.15968.1.camel-nDn/Rdv9kqW9Jme8/bJn5UCKIB8iOfG2tUK59QYPAWc@public.gmane.org>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/linux-zigbee-devel>,
	<mailto:linux-zigbee-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=linux-zigbee-devel>
List-Post: <mailto:linux-zigbee-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
List-Help: <mailto:linux-zigbee-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/linux-zigbee-devel>,
	<mailto:linux-zigbee-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=subscribe>
Errors-To: linux-zigbee-devel-bounces-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Ben Hutchings <ben-/+tVBieCtBitmTQ+vhA3Yw@public.gmane.org>
Date: Sun, 09 Mar 2014 17:59:03 +0000

> On Tue, 2014-03-04 at 17:20 -0500, David Miller wrote:
>> From: "Phoebe Buckheister" <phoebe.buckheister-mPn0NPGs4xGatNDF+KUbs4QuADTiUCJX@public.gmane.org>
>> Date: Tue, 4 Mar 2014 23:16:31 +0100
>> 
>> > I see some value in being able to memcpy() to/from those fields directly
>> > when building/reading headers, but I also think that not having to do
>> > endianness conversion everywhere for a struct that cannot ever be a valid
>> > header as is outweighs this.
>> 
>> Why have an intermediate copy when that's not necessary at all?  It
>> seems like pure overhead to be.
>> 
>> Furthermore, cpu's have byte-shifting load and store instructions
>> which will be used if you make use of the 'p' versions of the endian
>> swap functions, such as cpu_to_le16p().
>> 
>> So it's going to cost basically nothing.
> 
> The real frame headers don't have naturally aligned fields, so if the
> structures are to mirror them they would need to be __packed.  I'm sure
> you realise what that does for performance.

Ok.  There is always the option of recording the translated values
in the SKB control block like TCP does for sequence numbers and
such.

------------------------------------------------------------------------------
Subversion Kills Productivity. Get off Subversion & Make the Move to Perforce.
With Perforce, you get hassle-free workflows. Merge that actually works. 
Faster operations. Version large binaries.  Built-in WAN optimization and the
freedom to use Git, Perforce or both. Make the move to Perforce.
http://pubads.g.doubleclick.net/gampad/clk?id=122218951&iu=/4140/ostg.clktrk
