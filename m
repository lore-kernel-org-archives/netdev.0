From: Dave Dillow <dave@thedillows.org>
Subject: Re: [0/3] mc_filter on big-endian arch
Date: Thu, 10 Jun 2004 09:37:59 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1086874679.23004.17.camel@dillow.idleaire.com>
References: <20040607115921.GB32569@k3.hellgate.ch>
	 <OFCBC67DF9.898B09C6-ON88256EAF.001BFC9E-88256EAF.001C4AB8@us.ibm.com>
	 <20040610102045.GA11616@k3.hellgate.ch>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: David Stevens <dlstevens@us.ibm.com>, Andrew Morton <akpm@osdl.org>,
        Jeff Garzik <jgarzik@pobox.com>, Netdev <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Roger Luethi <rl@hellgate.ch>
In-Reply-To: <20040610102045.GA11616@k3.hellgate.ch>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, 2004-06-10 at 06:20, Roger Luethi wrote:
> Multicast Driver Testing Quick How-To (version 0.2)
> =====================================

Thank you guys for all the info. I've done some testing, and sure
enough, there are some problems in typhoon, which I'll fix this weekend.
But I think the cpu_to_le32() calls are correct -- it would seem that
crc32_be() is needed rather than ether_crc() (which does little endian).
I'm assuming the results will be different, but I haven't done the math,
nor am I very familiar with the properties of the crc.

Even then, I'm not sure that's my real problem -- if it was setting the
wrong bits in the hash -- my working hypothesis -- I shouldn't be
receiving the 224.0.0.1 frames. I am.

I am also seeing 224.1.1.37 frames come up the stack in tcpdump (with
-p), before running "ip maddr ..." so something seems wonky. It seems to
be getting into ALL_MULTI mode, but I don't see how in the driver. I'm
going to add some printks and see what's going on.
-- 
Dave Dillow <dave@thedillows.org>
