From: "Andrew Grover" <andy.grover@gmail.com>
Subject: Re: [PATCH 1/8] [I/OAT] DMA memcpy subsystem
Date: Wed, 29 Mar 2006 15:05:42 -0800
Message-ID: <c0a09e5c0603291505h10f062d5qd6e1861ef052d07b@mail.gmail.com>
References: <20060311022759.3950.58788.stgit@gitlost.site>
	 <20060311022919.3950.43835.stgit@gitlost.site>
	 <2FF801BB-F96C-4864-AC44-09B4B92531F7@kernel.crashing.org>
	 <c0a09e5c0603281044i57730c66ye08c45aadd352cf8@mail.gmail.com>
	 <D760971F-3C6A-400B-99EA-E95358B37F82@kernel.crashing.org>
	 <c0a09e5c0603281401uaeea6aci57054aef444a5e1@mail.gmail.com>
	 <3B202D51-1683-465D-AE3D-DE301017BD69@kernel.crashing.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: "Chris Leech" <christopher.leech@intel.com>,
	"linux kernel mailing list" <linux-kernel@vger.kernel.org>,
	netdev@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1751218AbWC2XFo@vger.kernel.org>
To: "Kumar Gala" <galak@kernel.crashing.org>
In-Reply-To: <3B202D51-1683-465D-AE3D-DE301017BD69@kernel.crashing.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 3/28/06, Kumar Gala <galak@kernel.crashing.org> wrote:
> Do you only get callback when a channel is available?

Yes

> How do you
> decide to do to provide PIO to the client?

The client is responsible for using any channels it gets, or falling
back to memcpy() if it doesn't get any. (I don't understand how PIO
comes into the picture..?)

> A client should only request multiple channel to handle multiple
> concurrent operations.

Correct, if there aren't any CPU concurrency issues then 1 channel
will use the device's full bandwidth (unless some other client has
acquired the other channels and is using them, of course.)

> > This gets around the problem of DMA clients registering (and therefore
> > not getting) channels simply because they init before the DMA device
> > is discovered.
>
> What do you expect to happen in a system in which the channels are
> over subscribed?
>
> Do you expect the DMA device driver to handle scheduling of channels
> between multiple clients?

It does the simplest thing that could possibly work right now:
channels are allocated first come first serve. When there is a need,
it should be straightforward to allow multiple clients to share DMA
channels.

Regards -- Andy
