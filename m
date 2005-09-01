From: Ralf Baechle <ralf@linux-mips.org>
Subject: Re: Netdevice reference leak in af_ax25.c ??
Date: Thu, 1 Sep 2005 20:30:08 +0100
Message-ID: <20050901193008.GA13363@linux-mips.org>
References: <43174B67.9030109@candelatech.com> <43174ED3.6040106@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Ben Greear <greearb@candelatech.com>, linux-hams@vger.kernel.org,
	netdev@vger.kernel.org
Return-path: <linux-hams-owner@vger.kernel.org>
To: Patrick McHardy <kaber@trash.net>
Content-Disposition: inline
In-Reply-To: <43174ED3.6040106@trash.net>
Sender: linux-hams-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Sep 01, 2005 at 08:56:19PM +0200, Patrick McHardy wrote:

> > I believe the SO_BINDTODEVICE case in net/ax25/af_x25.c  (line 613 or so)
> > leaks a reference to a net device.  It does a dev_get_by_name,
> > which holds a reference, but since it never assigns the pointer
> > anywhere, I do not see how it can ever free it later.
> > 
> > Please clue me in as to where it's released if it actually is.
> 
> I can't find the code you're talking about, there's no dev_get* in my
> version of af_x25.c. Please paste the code you're talking about in
> your bugreports, thanks.

Ben meant net/ax25/af_ax25.  The dev value is stored in the ax25_cb
indirectly after converting it to an ax25dev pointer and will be freed
what that ax25_cb (which really is the protocol-specific part of the
socket) is going to be closed.

You poked my nose at a bug though - it is possible to leak references by
performing multiple SO_BINDTODEVICE operations; we should either only
permit the first one to succeed or to drop the reference of the old
device in case of a repeated SO_BINDTODEVICE.  After the weekend ...

  Ralf
