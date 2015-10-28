From: Toshiaki Makita <toshiaki.makita1@gmail.com>
Subject: Re: [PATCH v2 net-next 0/4] Automatic adjustment of max frame size
Date: Wed, 28 Oct 2015 16:40:16 +0900
Message-ID: <56307BE0.5080606@gmail.com>
References: <1445830859-4651-1-git-send-email-makita.toshiaki@lab.ntt.co.jp>
 <20151028135820.72329de4@samsung9>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S . Miller" <davem@davemloft.net>,
	Patrick McHardy <kaber@trash.net>,
	Vlad Yasevich <vyasevich@gmail.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	intel-wired-lan@lists.osuosl.org, netdev@vger.kernel.org
To: Stephen Hemminger <stephen@networkplumber.org>,
	Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f51.google.com ([209.85.220.51]:35571 "EHLO
	mail-pa0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752109AbbJ1HkV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 Oct 2015 03:40:21 -0400
Received: by pasz6 with SMTP id z6so248638513pas.2
        for <netdev@vger.kernel.org>; Wed, 28 Oct 2015 00:40:21 -0700 (PDT)
In-Reply-To: <20151028135820.72329de4@samsung9>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 15/10/28 (=E6=B0=B4) 13:58, Stephen Hemminger wrote:
> On Mon, 26 Oct 2015 12:40:55 +0900
> Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp> wrote:
=2E..

Thank you for taking a look at the patch set.
I'm not sure if I fully understand you, so please correct me if I=20
misread you.

> The problem is that you require changing network device drivers
> and device specific knowledge about what will work or not. Because
> of that the modificaton can't be automated.

I'm not sure what you mean by "device specific knowledge" and "automate=
d"...
Indeed, this requires change in each driver.
But required changes in drivers should be mostly making use of=20
ndo_change_mtu implementation code and not hard. We can progressively=20
implement ndo_enc_hdr_len for each driver.
If max frame size cannot be changed on a certain NIC, vlan driver will=20
emit a warning message and make MTU smaller, then userspace can handle=20
it (patch 3). If needed, maybe we can expose this feature via ethtool.

>
> Also, this effects even more layered devices like tunnels etc.

Yes, if tunnel devices start to utilize this framework. This is one of=20
purposes of my patch set.

> The problem is quite large, and this patch only begins to address it.

Yes, this is the first step to address the problem.

>
> It seems to me that just having the vlan driver to a sane
> auto default is the best solution.

=46or now, this patch implementation is limited to vlan. For other=20
protocols, auto-expansion may not be suitable and may need some nob to=20
use the framework.

If you mean just making MTU smaller on vlan device instead of adjusting=
=20
max frame size of real device, then it would not work. 802.1ad HW=20
switches, at any rate, send 1526 bytes frames so they will be dropped o=
n=20
the real device.

> It might cause a smaller MTU
> than ideal, but at least it will still work. Then the user can
> manually set a larger MTU if they know their hardware will work.

Toshiaki Makita
