From: "David S. Miller" <davem@davemloft.net>
Subject: Re: Raylink/WebGear testing - ray_cs.c iomem bug?
Date: Wed, 6 Oct 2004 11:14:31 -0700
Sender: linux-kernel-owner@vger.kernel.org
Message-ID: <20041006111431.442ff47e.davem@davemloft.net>
References: <Pine.LNX.4.58.0410061032410.8290@ppc970.osdl.org>
	<20041006105453.5f7d1888.davem@davemloft.net>
	<Pine.LNX.4.58.0410061102590.8290@ppc970.osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: jgarzik@pobox.com, acme@conectiva.com.br, corey@world.std.com,
	netdev@oss.sgi.com, linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel=40m.gmane.org-S269328AbUJFSP3@vger.kernel.org>
To: Linus Torvalds <torvalds@osdl.org>
In-Reply-To: <Pine.LNX.4.58.0410061102590.8290@ppc970.osdl.org>
List-Id: netdev.vger.kernel.org

On Wed, 6 Oct 2004 11:06:45 -0700 (PDT)
Linus Torvalds <torvalds@osdl.org> wrote:

> > NUMBER_OF_CCS is 64, and the difference between CCS_BASE and RCS_BASE
> > is 0x400 so this really doesn't account for anything.
> 
> It does, though: as I noted in my second mail (after trying to figure it
> out some more) the size of both ccs and rcs is 16 bytes, so when you
> offset by 64, so the difference between RCS_BASE and CCS_BASE ends up 
> being exactly "NUMBER_OF_CCS*sizeof(struct ccs/rcs)", which explains how 
> the base is the same, and the _index_ ends up being the one that selects 
> between the two.

Right, that makes perfect sense.  I missed how it was doing structure
pointer arithmetic when offsetting by the index.
