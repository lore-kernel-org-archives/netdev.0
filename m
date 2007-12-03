From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: [1/4] dst: Distributed storage documentation.
Date: Mon, 3 Dec 2007 14:16:27 +0300
Message-ID: <20071203111626.GB5283@2ka.mipt.ru>
References: <11963408033624@2ka.mipt.ru> <11963408034050@2ka.mipt.ru> <20071203045059.GM17536@waste.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: lkml <linux-kernel@vger.kernel.org>, netdev@vger.kernel.org,
	linux-fsdevel@vger.kernel.org
To: Matt Mackall <mpm@selenic.com>
Return-path: <linux-fsdevel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20071203045059.GM17536@waste.org>
Sender: linux-fsdevel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Matt.

On Sun, Dec 02, 2007 at 10:50:59PM -0600, Matt Mackall (mpm@selenic.com) wrote:
> > Distributed storage documentation.
> > 
> > Algorithms used in the system, userspace interfaces
> > (sysfs dirs and files), design and implementation details
> > are described here.
> 
> Can you give us a summary of how this differs from using device mapper
> with NBD?

>From the higher point ov view it does not, but it operates quite differently:
it has async processing of the requests, thus not blocking, it has
different protocol with smaller overhead, supports strong checksums, has
in-kernel export server, which supports simple security attributes (i.e.
allow to connect, to read or write). It uses smaller amount of memory
(zero additional allocations in the common path for linear mapping,
not including network allocations, it uses smaller amount of additional
allocations for mirroring case).
DST supports failure recovery in case of dropped connection (core will
reconnect to the remote node when it is ready), thus it is possible to
turn off and on remote nodes without special administration steps. DST
has simple autoconfiguration at the startup time (support checksums and
storage size autonegotiation). It is possible to turn one of the mirror
nodes off and use it as a offline backup, since dst mirror node stores
data at the end of the storage, so it can be mounted locally.

-- 
	Evgeniy Polyakov
