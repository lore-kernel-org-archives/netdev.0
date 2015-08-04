From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH] netfilter: ipt_SYNPROXY: fix sending window update to
 client
Date: Tue, 4 Aug 2015 19:53:02 +0200
Message-ID: <20150804175302.GA19650@salvia>
References: <1438037606-5462-1-git-send-email-phil@nwl.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, netfilter-devel@vger.kernel.org
To: Phil Sutter <phil@nwl.cc>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1438037606-5462-1-git-send-email-phil@nwl.cc>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Jul 28, 2015 at 12:53:26AM +0200, Phil Sutter wrote:
> Upon receipt of SYNACK from the server, ipt_SYNPROXY first sends back an ACK to
> finish the server handshake, then calls nf_ct_seqadj_init() to initiate
> sequence number adjustment of forwarded packets to the client and finally sends
> a window update to the client to unblock it's TX queue.
> 
> Since synproxy_send_client_ack() does not set synproxy_send_tcp()'s nfct
> parameter, no sequence number adjustment happens and the client receives the
> window update with incorrect sequence number. Depending on client TCP
> implementation, this leads to a significant delay (until a window probe is
> being sent).

Could you also fix the IPv6 side to get both codes in sync? Thanks.

