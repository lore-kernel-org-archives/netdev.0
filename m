From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: [Bug 3610] New: kernel-2.6.9 breaks Amanda
Date: Thu, 21 Oct 2004 15:10:15 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20041021151015.10738f8a@zqx3.pdx.osdl.net>
References: <20041021133752.67a386fb@zqx3.pdx.osdl.net>
	<20041021142335.54f088ad.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
In-Reply-To: <20041021142335.54f088ad.davem@davemloft.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, 21 Oct 2004 14:23:35 -0700
"David S. Miller" <davem@davemloft.net> wrote:

> On Thu, 21 Oct 2004 13:37:52 -0700
> Stephen Hemminger <shemminger@osdl.org> wrote:
> 
> >            Summary: kernel-2.6.9 breaks Amanda
> 
> Unfortunately, he failed to show the tcpdump traces of the UDP
> traffic as he did in his lkml postings.  There you will find
> checksum errors mentioned in the tcpdump output for the last
> few consequetive UDP packets and I think that is a good clue
> as to what may be the problem here.
> 
> I have to trust that the user did try, as Andrew Morton suggested,
> the 2.6.8.1 3c59x driver copied into the 2.6.9 kernel.  He said
> the problem persists.
> 
> He also states he disabled netfilter (although I would have liked
> him to also make sure that no netfilter modules were loaded as well).
> 
> That basically leaves us with ipv4/udp changes to look at.  There
> are two potentially problem causing changesets.  That would be:
> 
> ChangeSet 1.1832.88.1 2004/09/13 20:05:28 acme@conectiva.com.br
> 
> and
> 
> ChangeSet 1.1803.16.6 2004/07/21 13:51:01 Samuel.Thibault@ens-lyon.fr
> 
> I'm mostly suspicious of the latter, because it changes the
> behvaior of UDP sockets when MSG_TRUNC is specified.  Can
> someone check if Amanda uses MSG_TRUNC on UDP sockets?

No, not in current source.

> If the bug reporter had provided an strace of the Amanda userland
> components, we'd know this already.

Reading the current source code: 
	http://prdownloads.sourceforge.net/amanda/amanda-2.4.4p3.tar.gz?download

It does sendto() then close() in the udp_send path.
Also, it suffers from the select() and blocking rcvfrom() problem.
