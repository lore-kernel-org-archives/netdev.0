From: Andi Kleen <ak@suse.de>
Subject: Re: Using netconsole for debugging suspend/resume
Date: Tue, 13 Jun 2006 05:47:49 +0200
Message-ID: <200606130547.49624.ak@suse.de>
References: <44886381.9050506@goop.org> <200606121746.34880.ak@suse.de> <448DDBD9.6030900@goop.org>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: Mark Lord <lkml@rtr.ca>, Matt Mackall <mpm@selenic.com>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	netdev@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S932852AbWFMDwB@vger.kernel.org>
To: Jeremy Fitzhardinge <jeremy@goop.org>
In-Reply-To: <448DDBD9.6030900@goop.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Monday 12 June 2006 23:25, Jeremy Fitzhardinge wrote:
> Andi Kleen wrote:
> > On Monday 12 June 2006 17:38, Mark Lord wrote:
> >   
> >> Okay, so I'm daft.  But.. *what* is "it" ??
> >>
> >> We have two machines:  target (being debugged), and host (anything).
> >> Sure, the target has to have ohci1394 loaded, and firescope running.
> >> But what about the *other* end of the connection?  What commands?
> >>     
> >
> > From the same manpage:
> > "The raw1394 module must be loaded and its device node
> >  be writable (this normally requires root)" 
> >
> > Ok it doesn't say you need ohci1394 too and doesn't say that's the target.
> > If I do a new revision I'll perhaps expand the docs a bit.
> >
> > So load ohci1394/raw1394 and run firescope as root. Your distribution
> > will hopefully take care of the device nodes. Usually you want 
> > something like firescope -Au System.map  
> >   
> 
> I think the confusion here is that the target doesn't need to be running 
> anything; you can DMA chunks of memory with the OHCI controller with no 
> need for any software support.  

You need ohci1394 loaded at least once. That is why it only works
in relatively late boot.

I've been playing with the idea of writing "early1394" that just
turns the DMA controller on as early as possible similar to earlyprintk
on the target. Then it would be possible to use it for early
debugging too. But so far it's not done yet.

I'll try to write better docs next time.

BTW Bernd did a gdbstub based on the firescope
so you can even examine all kernel variables symbolically.  It can
even write variables, but not change the flow of the CPU.
Standard firescope can just hexdump read/write symbols. With gdb 
it's also possible to do a core file of the kernel.

-Andi
