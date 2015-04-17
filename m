From: Greg KH <gregkh@linuxfoundation.org>
Subject: Re: [PATCH stable 3.10-3.16] tcp: Fix crash in TCP Fast Open
Date: Fri, 17 Apr 2015 11:43:27 +0200
Message-ID: <20150417094327.GA29571@kroah.com>
References: <1429120832.3211.91.camel@decadent.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: stable <stable@vger.kernel.org>, netdev <netdev@vger.kernel.org>,
	Eric Dumazet <eric.dumazet@gmail.com>, 782515@bugs.debian.org
To: Ben Hutchings <ben@decadent.org.uk>
Return-path: <stable-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1429120832.3211.91.camel@decadent.org.uk>
Sender: stable-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Apr 15, 2015 at 07:00:32PM +0100, Ben Hutchings wrote:
> Commit 355a901e6cf1 ("tcp: make connect() mem charging friendly")
> changed tcp_send_syn_data() to perform an open-coded copy of the 'syn'
> skb rather than using skb_copy_expand().
> 
> The open-coded copy does not cover the skb_shared_info::gso_segs
> field, so in the new skb it is left set to 0.  When this commit was
> backported into stable branches between 3.10.y and 3.16.7-ckty
> inclusive, it triggered the BUG() in tcp_transmit_skb().
> 
> Since Linux 3.18 the GSO segment count is kept in the
> tcp_skb_cb::tcp_gso_segs field and tcp_send_syn_data() does copy the
> tcp_skb_cb structure to the new skb, so mainline and newer stable
> branches are not affected.
> 
> Set skb_shared_info::gso_segs to the correct value of 1.
> 
> Signed-off-by: Ben Hutchings <ben@decadent.org.uk>
> ---
>  net/ipv4/tcp_output.c | 1 +
>  1 file changed, 1 insertion(+)

Thanks for working on this and sending the patch out.

greg k-h
