From: "David S. Miller" <davem@davemloft.net>
Subject: Re: A case AGAINST checksum offload
Date: Fri, 12 Nov 2004 15:49:45 -0800
Message-ID: <20041112154945.63da5103.davem@davemloft.net>
References: <Pine.LNX.4.58.0411121644150.8989@dexter.psc.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: John Heffner <jheffner@psc.edu>
In-Reply-To: <Pine.LNX.4.58.0411121644150.8989@dexter.psc.edu>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, 12 Nov 2004 18:46:11 -0500 (EST)
John Heffner <jheffner@psc.edu> wrote:

> Though I don't have any definitive references, I've heard stories that Sun
> turned off UDP checksums on LANs to increase NFS performance, only to
> re-enable checksumming by default after problems similar to mine caused
> corruptions of some critical databases.

That story about Sun is true.  But it is an entirely different matter
to disable checksums altogether vs. disabling HW assisted checksumming.

> Since TCP checksum offload should only really helps the zero-copy case in
> terms of performance, it seems safer to turn off hardware checksumming by
> default, or perhaps only enable it if an application is doing a zero-copy
> send.

I disagree.

What is the difference between the CPU (a bus agent with computational
abilities), and a networking card (again, a bus agent with computational
abilities) computing the checksums?

In your listed case you found a bug, and it appears that what happened
is that the DMA transfer got corrupted to the networking card yet a
properly checksummed packet went out because the card computed the
checksum.

What would happen if this happened on a block device?  Your filesystem
would get corrupted, perhaps irreparably.

How is this any different?  It's a hard error for the DMA data to be
corrupted.

The data could just as easily be corrupted on the way to the CPU when
doing a copy+checksum operation.  It's the same problem you say exists
with your networking card case except the path of the corruption is
RAM-->CPU instead of RAM-->PCI Controller-->Networking Card

I really don't buy this. :-)
