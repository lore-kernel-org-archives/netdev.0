From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH] Fix checksum bug for multicast/broadcast packets on
 postrouting hook
Date: Sat, 28 Feb 2004 21:50:13 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040228215013.28a61c76.davem@redhat.com>
References: <20040218172441.2eb117a7.davem@redhat.com>
	<Xine.LNX.4.44.0402231713310.21153-100000@thoron.boston.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: mika.penttila@kolumbus.fi, laforge@netfilter.org, netdev@oss.sgi.com,
        sds@epoch.ncsc.mil
Return-path: <netdev-bounce@oss.sgi.com>
To: James Morris <jmorris@redhat.com>
In-Reply-To: <Xine.LNX.4.44.0402231713310.21153-100000@thoron.boston.redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, 23 Feb 2004 17:19:03 -0500 (EST)
James Morris <jmorris@redhat.com> wrote:

> This does not seem to be the correct approach.  If you drop packets in 
> the ipsec cases at least, the retransmits just keep feeding packets back 
> in with hardware checksumming set.

Ok, so TCP retransmits do this.

There is a check missing somewhere in the TCP output path then.
Or maybe, it refuses to mess with checksum state after the SKB
has been created, even for further retransmits.

More brainpower needed...
