From: Julian Anastasov <ja@ssi.bg>
Subject: Re: [Patch net] ipv4: fib: check forwarding before checking
 send_redirects
Date: Wed, 9 Apr 2014 01:15:48 +0300 (EEST)
Message-ID: <alpine.LFD.2.11.1404090110500.3310@ja.home.ssi.bg>
References: <1396985482-30886-1-git-send-email-xiyou.wangcong@gmail.com> <20140408.164356.557108616710530006.davem@davemloft.net> <CAM_iQpXrmRNhQCWjiRSKwzxvtcq9XuT-cWS4vRxYVYxpUEN3qQ@mail.gmail.com> <20140408.172343.917107273854891906.davem@davemloft.net>
 <CAM_iQpXkmU9qw_KPeMPnE0KGbcCWo5R=Le7HsizyiuRJVkKshA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: David Miller <davem@davemloft.net>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	Cong Wang <cwang@twopensource.com>
To: Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ja.ssi.bg ([178.16.129.10]:33950 "EHLO ja.home.ssi.bg"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1756174AbaDHWQQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 8 Apr 2014 18:16:16 -0400
In-Reply-To: <CAM_iQpXkmU9qw_KPeMPnE0KGbcCWo5R=Le7HsizyiuRJVkKshA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


	Hello,

On Tue, 8 Apr 2014, Cong Wang wrote:

> I must miss something here. Looking at the code:
> 
>         int r = secpath_exists(skb) ? 0 : IN_DEV_RPFILTER(idev);
> 
>         if (!r && !fib_num_tclassid_users(dev_net(dev)) &&
>             (dev->ifindex != oif || !IN_DEV_TX_REDIRECTS(idev))) {
>                 *itag = 0;
>                 return 0;
>         }
> 
> r == 0 is true in our case since we disable rp_filter manually.
> And fib_num_tclassid_users() == 0 by default too.
> 
> Therefore, the only thing takes effect is if dev->ifindex == oif.
> Given the fact that disabling send_redirects makes the problem
> disappear, dev->ifindex != oif must be false, otherwise it doesn't
> even need to check TX_REDIRECTS.
> 
> The rx interface is loopback, so skb->dev == lo, and the oif we pass
> here must be LOOPBACK_IFINDEX, therefore the following code
> in ip_route_input_slow():

	Yes, the code will fail if input route is
tried on loopback device. My first thought was that
you forgot to 'ip route flush cache' after clearing
rp_filter.

> which looks good to me too, since the packet has src addr == dst addr.
> 
> Which part am I missing?

	What kind of packet is that and why the skb lost its
output route and now it is trying for input route?

Regards

--
Julian Anastasov <ja@ssi.bg>
