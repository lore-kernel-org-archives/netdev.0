From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: POHMELFS high performance network filesystem. Transactions, failover, performance.
Date: Thu, 15 May 2008 02:50:08 +0400
Message-ID: <20080514225008.GB3739@2ka.mipt.ru>
References: <20080513174523.GA1677@2ka.mipt.ru> <4829E752.8030104@garzik.org> <20080513205114.GA16489@2ka.mipt.ru> <Pine.LNX.4.64.0805140623001.14334@cobra.newdream.net> <20080514135156.GA23131@2ka.mipt.ru> <482B378C.5070807@garzik.org> <20080514193843.GB10165@2ka.mipt.ru> <20080514215704.GE23758@shareable.org> <482B6259.3070507@garzik.org> <20080514224132.GB19570@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jamie Lokier <jamie@shareable.org>, Sage Weil <sage@newdream.net>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	linux-fsdevel@vger.kernel.org
To: Jeff Garzik <jeff@garzik.org>
Return-path: <linux-fsdevel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20080514224132.GB19570@2ka.mipt.ru>
Sender: linux-fsdevel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, May 15, 2008 at 02:41:33AM +0400, Evgeniy Polyakov (johnpol@2ka.mipt.ru) wrote:
> > This is the core reason why I am so interested in distributed storage... 
> >  a single storage device is usually slower than network wire speed. 
> > Multiple nodes helps remove that limitation and max out the network.
> > 
> > I want to be able to stream data _faster_ than a single hard drive can 
> > handle :)
> 
> In that case yes, network will _not_ be saturated and multiple
> simultaneous streams will have a win, but POHMELFS client design was
> specially created to increase network performance as much as possible,
> since we can increase storage speed (add more drives, more RAM
> for caches, better hardware), but can not easily increase network
> bandwidth.

Actually experiments with async processing in POHMELFS lead to the
conclusion, that if protocol waits until request is completed and does
not proceed with the next one (like CIFS and somewhat NFS), such design
does not scale to multiple parallel IOs.
That from different angle shows benefits of caching and aiming at
getting as much performance as possible from single node connection :)

-- 
	Evgeniy Polyakov
