From: Peter Zijlstra <a.p.zijlstra@chello.nl>
Subject: Re: [RFC][PATCH 0/9] Network receive deadlock prevention for NBD
Date: Thu, 10 Aug 2006 08:06:28 +0200
Message-ID: <1155189988.12225.100.camel@twins>
References: <1155127040.12225.25.camel@twins>
	 <20060809130752.GA17953@2ka.mipt.ru> <1155130353.12225.53.camel@twins>
	 <20060809.165431.118952392.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: johnpol@2ka.mipt.ru, linux-mm@kvack.org,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	phillips@google.com
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1161061AbWHJGLH@vger.kernel.org>
To: David Miller <davem@davemloft.net>
In-Reply-To: <20060809.165431.118952392.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2006-08-09 at 16:54 -0700, David Miller wrote:
> From: Peter Zijlstra <a.p.zijlstra@chello.nl>
> Date: Wed, 09 Aug 2006 15:32:33 +0200
> 
> > The idea is to drop all !NFS packets (or even more specific only
> > keep those NFS packets that belong to the critical mount), and
> > everybody doing critical IO over layered networks like IPSec or
> > other tunnel constructs asks for trouble - Just DON'T do that.
> 
> People are doing I/O over IP exactly for it's ubiquity and
> flexibility.  It seems a major limitation of the design if you cancel
> out major components of this flexibility.

We're not, that was a bit of my own frustration leaking out; I think 
this whole push to IP based storage is a bit silly. I'm just not going 
to help the admin who's server just hangs because his VPN key expired.

Running critical resources remotely like this is tricky, and every 
hop/layer you put in between increases the risk of something going bad.
The only setup I think even remotely sane is a dedicated network in the
very same room - not unlike FC but cheaper (which I think is the whole
push behind this, eth is cheap)
