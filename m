From: Iustin Pop <iusty@k1024.org>
Subject: Re: [RFD] Layering: Use-Case Composers (was: DRBD - what is it,
	anyways? [compare with e.g. NBD + MD raid])
Date: Sun, 12 Aug 2007 19:45:49 +0200
Message-ID: <20070812174549.GA2915@teal.hq.k1024.org>
References: <200708121335.17267.a1426z@gawab.com> <Pine.LNX.4.64.0708121325170.28963@fbirervta.pbzchgretzou.qr> <Pine.LNX.4.64.0708120933210.19502@asgard.lang.hm> <Pine.LNX.4.64.0708121901290.28963@fbirervta.pbzchgretzou.qr>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: david@lang.hm, Al Boldi <a1426z@gawab.com>,
	linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org,
	netdev@vger.kernel.org, linux-raid@vger.kernel.org
To: Jan Engelhardt <jengelh@computergmbh.de>
Return-path: <linux-fsdevel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0708121901290.28963@fbirervta.pbzchgretzou.qr>
Sender: linux-fsdevel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, Aug 12, 2007 at 07:03:44PM +0200, Jan Engelhardt wrote:
> 
> On Aug 12 2007 09:39, david@lang.hm wrote:
> >
> > now, I am not an expert on either option, but three are a couple things that I
> > would question about the DRDB+MD option
> >
> > 1. when the remote machine is down, how does MD deal with it for reads and
> > writes?
> 
> I suppose it kicks the drive and you'd have to re-add it by hand unless done by
> a cronjob.

>From my tests, since NBD doesn't have a timeout option, MD hangs in the
write to that mirror indefinitely, somewhat like when dealing with a
broken IDE driver/chipset/disk.

> > 2. MD over local drive will alternate reads between mirrors (or so I've been
> > told), doing so over the network is wrong.
> 
> Certainly. In which case you set "write_mostly" (or even write_only, not sure
> of its name) on the raid component that is nbd.
> 
> > 3. when writing, will MD wait for the network I/O to get the data saved on the
> > backup before returning from the syscall? or can it sync the data out lazily
> 
> Can't answer this one - ask Neil :)

MD has the write-mostly/write-behind options - which help in this case
but only up to a certain amount.


In my experience DRBD wins hands-down over MD+NBD because of MD doesn't
know (or handle) a component that never returns from a write, which is
quite different from returning with an error. Furthermore, DRBD was
designed to handle transient errors in the connection to the peer due to
its network-oriented design, whereas MD is mostly designed with local or
at least high-reliability disks (where disk can be SAN, SCSI, etc.) and
a failure is not normal for MD. Thus the need for manual reconnect in MD
case and the automated handling of reconnects in case of DRBD.

I'm just a happy user of both MD over local disks and DRBD for networked
raid.

regards,
iustin
