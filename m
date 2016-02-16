From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] lwt: fix rx checksum setting for lwt devices
 tunneling over ipv6
Date: Tue, 16 Feb 2016 14:47:59 -0500 (EST)
Message-ID: <20160216.144759.1984502562641417028.davem@davemloft.net>
References: <8d2a6ece65b17ae61343dce27f3709d3cd249832.1455118911.git.pabeni@redhat.com>
	<20160211114124.17ae429a@griffin>
	<CAEh+42jyFVjM4A5HzJQ94xW+XZOTG5iBEFu2VHKCJU0sRwNgWA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jbenc@redhat.com, pabeni@redhat.com, netdev@vger.kernel.org,
	pshelar@nicira.com, tgraf@suug.ch
To: jesse@kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:39095 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751104AbcBPTsE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Feb 2016 14:48:04 -0500
In-Reply-To: <CAEh+42jyFVjM4A5HzJQ94xW+XZOTG5iBEFu2VHKCJU0sRwNgWA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jesse Gross <jesse@kernel.org>
Date: Tue, 16 Feb 2016 10:22:38 -0800

> On Thu, Feb 11, 2016 at 2:41 AM, Jiri Benc <jbenc@redhat.com> wrote:
> There's a bigger problem here, not really related to lightweight tunnels or OVS.
> 
> The VXLAN RFC says (referring to the UDP checksum and not specific to IPv4/v6):
> "It SHOULD be transmitted as zero. When a packet is received with a
> UDP checksum of zero, it MUST be accepted for decapsulation."
> 
> We can debate whether this is correct or whether it conflicts with RFC
> 2460 but this is what essentially everyone is going to implement. With
> the default settings of the flags in IPv6, we are violating both
> statements. With the second one in particular, the result is that
> Linux will not be able to communicate with any non-Linux VXLAN
> endpoint over IPv6 with default settings.

I do not see any such conflict here.

It's a SHOULD, therefore a recommendation.  Likely they thought this
would improve performance, and ironically it has the opposite effect.

The text of the VXLAN RFC does not say that the checksum MUST be sent
as zero, and it also does not say that receiving a non-zero checksum
is violating the RFC.

I therefore do not see the interoperability issue.  Maybe some
deployed systems will run more slowly or hit a slot path (which is not
our problem), but they absolutely should not drop such frames.
