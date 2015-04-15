From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH stable 3.10-3.16] tcp: Fix crash in TCP Fast Open
Date: Wed, 15 Apr 2015 14:33:50 -0400 (EDT)
Message-ID: <20150415.143350.1405489800706487173.davem@davemloft.net>
References: <1429120832.3211.91.camel@decadent.org.uk>
	<1429122164.7346.139.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ben@decadent.org.uk, stable@vger.kernel.org,
	netdev@vger.kernel.org, 782515@bugs.debian.org
To: eric.dumazet@gmail.com
Return-path: <stable-owner@vger.kernel.org>
In-Reply-To: <1429122164.7346.139.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: stable-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Wed, 15 Apr 2015 11:22:44 -0700

> On Wed, 2015-04-15 at 19:00 +0100, Ben Hutchings wrote:
>> Commit 355a901e6cf1 ("tcp: make connect() mem charging friendly")
>> changed tcp_send_syn_data() to perform an open-coded copy of the 'syn'
>> skb rather than using skb_copy_expand().
>> 
>> The open-coded copy does not cover the skb_shared_info::gso_segs
>> field, so in the new skb it is left set to 0.  When this commit was
>> backported into stable branches between 3.10.y and 3.16.7-ckty
>> inclusive, it triggered the BUG() in tcp_transmit_skb().
>> 
>> Since Linux 3.18 the GSO segment count is kept in the
>> tcp_skb_cb::tcp_gso_segs field and tcp_send_syn_data() does copy the
>> tcp_skb_cb structure to the new skb, so mainline and newer stable
>> branches are not affected.
>> 
>> Set skb_shared_info::gso_segs to the correct value of 1.
>> 
>> Signed-off-by: Ben Hutchings <ben@decadent.org.uk>
 ...
> Looks goot to me, thanks Ben !
> 
> Acked-by: Eric Dumazet <edumazet@google.com>

Ben, thanks for taking care of this.
