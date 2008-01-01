From: Theodore Tso <tytso@mit.edu>
Subject: Re: [PATCH] Force UNIX domain sockets to be built in
Date: Tue, 1 Jan 2008 00:01:54 -0500
Message-ID: <20080101050154.GG11776@mit.edu>
References: <alpine.LSU.0.999.0712311300020.3686@be1.lrz> <20071231.042055.145660385.davem@davemloft.net> <alpine.LSU.0.999.0712311426520.3761@be1.lrz> <20071231193848.GQ27894@ZenIV.linux.org.uk> <alpine.LSU.0.999.0801010418260.2337@be1.lrz>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Al Viro <viro@ZenIV.linux.org.uk>,
	David Miller <davem@davemloft.net>, jengelh@computergmbh.de,
	devzero@web.de, linux-kernel@vger.kernel.org, bunk@kernel.org,
	netdev@vger.kernel.org
To: Bodo Eggert <7eggert@gmx.de>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1752757AbYAAFjf@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <alpine.LSU.0.999.0801010418260.2337@be1.lrz>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Jan 01, 2008 at 04:45:21AM +0100, Bodo Eggert wrote:
> > udev-free != embedded.
> 
> But UNIX=m == waste RAM and have an effectively b0rken system until the 
> module is loaded. 

Well, the system isn't necessarily totally broken.  If you don't use
udev, then system will be crippled, but not totally broken.  Then
again, besides udev, packages such as dbus, gdm, and acpid all use
Unix Domain Sockets --- not to mention cups, avahi-daemon, bluez,
emacsclient, and any X program when the DISPLAY is :0.0.

The question is whether the size of the Unix domain sockets support is
worth the complexity of yet another config option that we expose to
the user.  For the embedded world, OK, maybe they want to save 14k of
non-swappable memory.  But for the non-embedded world, given the 117k
mandatory memory usage of sysfs, or the 124k memory usage of the core
networking stack, never mind the 3 megabytes of memory used by objects
in the kernel subdirectory, it's not clear that it's worth worrying
over 14k of memory, especially when many Unix programs assume
that Unix Domain Sockets are present.

						- Ted
