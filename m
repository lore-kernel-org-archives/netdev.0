From: "David S. Miller" <davem@davemloft.net>
Subject: Re: Raylink/WebGear testing - ray_cs.c iomem bug?
Date: Wed, 6 Oct 2004 10:54:53 -0700
Sender: linux-kernel-owner@vger.kernel.org
Message-ID: <20041006105453.5f7d1888.davem@davemloft.net>
References: <Pine.LNX.4.58.0410061032410.8290@ppc970.osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: jgarzik@pobox.com, acme@conectiva.com.br, corey@world.std.com,
	netdev@oss.sgi.com, linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel=40m.gmane.org-S269324AbUJFR4G@vger.kernel.org>
To: Linus Torvalds <torvalds@osdl.org>
In-Reply-To: <Pine.LNX.4.58.0410061032410.8290@ppc970.osdl.org>
List-Id: netdev.vger.kernel.org

On Wed, 6 Oct 2004 10:43:50 -0700 (PDT)
Linus Torvalds <torvalds@osdl.org> wrote:

> That cleanup in turn seems to show that the driver was fundamentally buggy
> in a way that really surprises me: it adds "CCS_BASE" to the PCI window
> base in order to get to both the "struct ccs" pointer _and_ to the "struct
> rcs" pointer.

In the spot where this occurs, it adds both CCS_BASE and
'rcsindex' to the sram base, and only when rcsindex >= NUMBER_OF_CCS.

NUMBER_OF_CCS is 64, and the difference between CCS_BASE and RCS_BASE
is 0x400 so this really doesn't account for anything.

I can't see how you've changed the behavior, so it should work as well
as it did before your changes.

Sorry, I don't have a ray_cs handy :)
