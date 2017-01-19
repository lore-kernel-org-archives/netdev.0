From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Inconsistency in packet drop due to MTU (eth vs veth)
Date: Thu, 19 Jan 2017 10:53:47 -0800
Message-ID: <1484852027.16328.33.camel@edumazet-glaptop3.roam.corp.google.com>
References: <159b79aa979.e23be6a5186096.2767722456700391441@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>, Evan Jones <ej@evanjones.ca>,
        "David S. Miller" <davem@davemloft.net>,
        Cong Wang <cwang@twopensource.com>,
        Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
        Vijay Pandurangan <vijayp@vijayp.ca>,
        linux-kernel <linux-kernel@vger.kernel.org>
To: Fredrik Markstrom <fredrik.markstrom@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <159b79aa979.e23be6a5186096.2767722456700391441@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2017-01-19 at 17:41 +0100, Fredrik Markstrom wrote:
> Hello,
> 
> I've noticed an inconsistency between how physical ethernet and veth handles mtu.
> 
> If I setup two physical interfaces (directly connected) with different mtu:s, only the size of the outgoing packets are limited by the mtu. But with veth a packet is dropped if the mtu of the receiving interface is smaller then the packet size. 
> 
> This seems inconsistent to me, but maybe there is a reason for it ? 
> 
> Can someone confirm if it's a deliberate inconsistency or just a side effect of using dev_forward_skb() ?

It looks this was added in commit
38d408152a86598a50680a82fe3353b506630409
("veth: Allow setting the L3 MTU")

But what was really needed here was a way to change MRU :(
