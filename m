From: Robin Holt <holt@sgi.com>
Subject: Re: Zero copy transmit
Date: Wed, 30 Apr 2003 10:05:33 -0500
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030430150533.GA8158@sgi.com>
References: <3EAEC7FF.4040504@sgi.com> <20030429192041.GC17413@Wotan.suse.de> <3EAED567.2090006@sgi.com> <20030429195924.GC349@Wotan.suse.de> <3EAEDBE9.1060405@sgi.com> <20030429203945.GD349@Wotan.suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com, modica@sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Andi Kleen <ak@suse.de>
Content-Disposition: inline
In-Reply-To: <20030429203945.GD349@Wotan.suse.de>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, Apr 29, 2003 at 10:39:46PM +0200, Andi Kleen wrote:
> > Don't get me wrong, we would certainly drop any notions of this if we 
> > found that it was slower and I will be glad to post any results. The 
> > goal is to take advantage of the hardware to make things faster.
> 
> You have no hardware to make the remote TLB flushes fast ;)
> 
> I'm sure you can show it being an advantage with a single threaded process.
> But when you run it on a multithreaded application just with two threads
> it may look very different.
> 
Last time I checked, the IA64 processor provides a ptc.g instruction for
exactly this.  The only hit we take from using it is Intel limits it to
a single outstanding ptc.g pending machine wide.  This is accomplished with
a global spinlock.  I would love to convince Intel to change this instruction,
but that probably will not happen any time soon.

I will concede that the ptc.g instruction takes a considerable period of
time on our 64 processor machines, but that comes out to a lot of local
TLB coherence domains that need to be updated.

I believe there is a similar instruction for x86.  Could someone verify
this?
