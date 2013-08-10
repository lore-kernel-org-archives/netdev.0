From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] netfilter: nf_conntrack: fix tcp_in_window for Fast Open
Date: Fri, 09 Aug 2013 17:25:45 -0700
Message-ID: <1376094345.20509.17.camel@edumazet-glaptop>
References: <1376094087-17700-1-git-send-email-ycheng@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: pablo@netfilter.org, netfilter-devel@vger.kernel.org,
	netdev@vger.kernel.org
To: Yuchung Cheng <ycheng@google.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1376094087-17700-1-git-send-email-ycheng@google.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 2013-08-09 at 17:21 -0700, Yuchung Cheng wrote:
> Currently the conntrack checks if the ending sequence of a packet
> falls within the observed receive window. However it does so even
> if it has not observe any packet from the remote yet and uses an
> uninitialized receive window (td_maxwin).
> 
> If a connection uses Fast Open to send a SYN-data packet which is
> dropped afterward in the network. The subsequent SYNs retransmits
> will all fail this check and be discarded, leading to a connection
> timeout. This is because the SYN retransmit does not contain data
> payload so
> 
> end == initial sequence number (isn) + 1
> sender->td_end == isn + syn_data_len
> receiver->td_maxwin == 0
> 
> The fix is to only apply this check after td_maxwin is initialized.
> 
> Reported-by: Michael Chan <mcfchan@stanford.edu>
> Signed-off-by: Yuchung Cheng <ycheng@google.com>
> ---

Acked-by: Eric Dumazet <edumazet@google.com>



