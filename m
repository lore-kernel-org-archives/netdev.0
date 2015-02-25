From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: [PATCH v2 0/3] net: Linn Ethernet Packet Sniffer driver
Date: Wed, 25 Feb 2015 10:50:56 +0100
Message-ID: <20150225095056.GB4293@localhost.localdomain>
References: <cover.1424181053.git.stathis.voukelatos@linn.co.uk>
 <20150218210830.GA7778@localhost.localdomain>
 <54EAF4D4.4090505@linn.co.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, devicetree@vger.kernel.org,
	netdev@vger.kernel.org, abrestic@chromium.org
To: Stathis Voukelatos <stathis.voukelatos@linn.co.uk>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <54EAF4D4.4090505@linn.co.uk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Feb 23, 2015 at 09:37:24AM +0000, Stathis Voukelatos wrote:
> Hi Richard,
> 
> On 18/02/15 21:08, Richard Cochran wrote:
> >On Tue, Feb 17, 2015 at 02:03:30PM +0000, Stathis Voukelatos wrote:
> >>The command string for packet matching is stored in module RAM
> >>and consists of a sequence of 16-bit entries. Each entry includes
> >>an 8-bit command code and and 8-bit data value. Valid command
> >>codes are:
> >>0 - Don't care
> >>1 - Match: packet data must match command string byte
> >>2 - Copy: packet data will be copied to FIFO
> >>3 - Match/Stamp: if packet data matches string byte, a timestamp
> >>                  is copied into the FIFO
> >>4 - Copy/Done: packet data will be copied into the FIFO.
> >>                This command terminates the command string.
> >
> >Why do you need to expose this interface to user space at all?  Why
> >not just time stamp every frame?
> 
> To put this into context with an example, the use case this H/W
> module was originally developed for was to allow multiple audio
> receivers to synchronize with a single transmitter, eg. multi-room
> synchronised audio.

The Linux kernel already fully supports this kind of application via
the SIOCSHWTSTAMP, SO_TIMESTAMPING, and PHC mechanisms.  We certainly
don't need another another interface just for someone's warped
hardware design.

I suggest that you find a way to make your HW work within the existing
frame work.

> The interface needs to be public so that a user-space application
> can program a command string that will match packets that belong to
> the audio stream of interest, for this example.

Let the user program simply use a BPF for that.

> In addition returning just a timestamp would not be enough in many
> cases. In the audio streaming use case mentioned above some
> additional
> bytes from the packet payload need to be returned (with Copy
> commands) in order to associate the timestamp with a certain point
> in the audio stream.

The time stamp is *already* associated with a particular frame.

Just tell your driver to program the hardware to:

1. time stamp every frame
2. deliver every frame

Thats all you need.

> >How does the "Match" command work?  The frame must have one particular
> >byte?  That can't be right.  Please explain.
> 
> Actually, that is how the H/W works. Each Match command is followed by
> a data value which must match the packet data byte at the corresponding
> location. If there is no match processing of the packet stops.

And just what is the "corresponding location"?

Thanks,
Richard
