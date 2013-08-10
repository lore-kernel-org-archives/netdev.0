From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH] netfilter: nf_conntrack: fix tcp_in_window for Fast Open
Date: Sat, 10 Aug 2013 18:38:47 +0200
Message-ID: <20130810163847.GA4365@localhost>
References: <1376094087-17700-1-git-send-email-ycheng@google.com>
 <alpine.DEB.2.00.1308101501070.5256@blackhole.kfki.hu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Yuchung Cheng <ycheng@google.com>, netfilter-devel@vger.kernel.org,
	netdev@vger.kernel.org, edumazet@google.com
To: Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.00.1308101501070.5256@blackhole.kfki.hu>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, Aug 10, 2013 at 03:01:36PM +0200, Jozsef Kadlecsik wrote:
> On Fri, 9 Aug 2013, Yuchung Cheng wrote:
> 
> > Currently the conntrack checks if the ending sequence of a packet
> > falls within the observed receive window. However it does so even
> > if it has not observe any packet from the remote yet and uses an
> > uninitialized receive window (td_maxwin).
> > 
> > If a connection uses Fast Open to send a SYN-data packet which is
> > dropped afterward in the network. The subsequent SYNs retransmits
> > will all fail this check and be discarded, leading to a connection
> > timeout. This is because the SYN retransmit does not contain data
> > payload so
> > 
> > end == initial sequence number (isn) + 1
> > sender->td_end == isn + syn_data_len
> > receiver->td_maxwin == 0
> > 
> > The fix is to only apply this check after td_maxwin is initialized.
> > 
> > Reported-by: Michael Chan <mcfchan@stanford.edu>
> > Signed-off-by: Yuchung Cheng <ycheng@google.com>
> 
> Acked-by: Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>

Applied, thanks everyone.
