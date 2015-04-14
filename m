From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [stable regression] tcp: make connect() mem charging friendly
Date: Tue, 14 Apr 2015 05:19:56 -0700
Message-ID: <1429013996.7346.5.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1428996723.3211.34.camel@decadent.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>, stable <stable@vger.kernel.org>,
	Eric Dumazet <edumazet@google.com>, 782515@bugs.debian.org
To: Ben Hutchings <ben@decadent.org.uk>
Return-path: <stable-owner@vger.kernel.org>
In-Reply-To: <1428996723.3211.34.camel@decadent.org.uk>
Sender: stable-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2015-04-14 at 08:32 +0100, Ben Hutchings wrote:
> Commit 355a901e6cf1b2b763ec85caa2a9f04fbcc4ab4a ("tcp: make connect()
> mem charging friendly") was backported to various stable branches:
> 
> v3.10.73: e64a85197b3f tcp: make connect() mem charging friendly
> v3.12.40: d06381e8aac5 tcp: make connect() mem charging friendly
> v3.14.37: 5a8e8f482b4a tcp: make connect() mem charging friendly
> v3.18.11: e8f117f002ca tcp: make connect() mem charging friendly
> v3.13.11-ckt19: de023863df9d tcp: make connect() mem charging friendly
> v3.16.7-ckt9: bea5f6ef9fcb tcp: make connect() mem charging friendly
> 
> On the 3.16 branch, this has resulted in a regression for TCP Fast Open:
> <https://bugs.debian.org/782515>.  The BUG() at the top of
> tcp_transmit_skb() fires as tcp_skb_pcount(skb) == 0.
> 
> tcp_send_syn_data() does:
> 
> 	memcpy(syn_data->cb, syn->cb, sizeof(syn->cb));
> 
> Since commit cd7d8498c9a5 ("tcp: change tcp_skb_pcount() location") this
> is sufficient to set the GSO segment count correctly.  But in older
> branches (< 3.18) the GSO segment count in skb_shared_info is used and
> is no longer copied by tcp_send_syn_data().
> 
> All the versions listed above, except v3.18.11, appear to have suffered
> this regression.
> 
> Ben.
> 

Hi Ben

Sorry to ear that. Have you already fixed this, or are you asking for
help ?
