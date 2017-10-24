From: Or Gerlitz <gerlitz.or@gmail.com>
Subject: Re: [patch net-next v2 00/20] net: sched: convert cls ndo_setup_tc
 offload calls to per-block callbacks
Date: Tue, 24 Oct 2017 20:03:59 +0300
Message-ID: <CAJ3xEMha47UcfqLPMhHc0kW0QNkgr3f98LaOpJAo7=Lt7FtjwQ@mail.gmail.com>
References: <20171019135048.4306-1-jiri@resnulli.us> <20171021.030446.967534081159629805.davem@davemloft.net>
 <CAKgT0Ud0RJLZ6mz9Ysb9A7PdkcwBYt2+ASvLZQxMGPK2BwvqKw@mail.gmail.com>
 <CAKgT0UeR8t3C82cQo9er4zkQy7PH36H4r84WA7V7HLOavY7RGg@mail.gmail.com> <CAJ3xEMgdRBEuv0hb_G43zJXXRy=PWgY2tdHuwDN0Opc2NVF35g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: David Miller <davem@davemloft.net>, Jiri Pirko <jiri@resnulli.us>,
        Netdev <netdev@vger.kernel.org>,
        Jamal Hadi Salim <jhs@mojatatu.com>,
        Cong Wang <xiyou.wangcong@gmail.com>,
        mlxsw <mlxsw@mellanox.com>, Andrew Lunn <andrew@lunn.ch>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
        Florian Fainelli <f.fainelli@gmail.com>,
        Michael Chan <michael.chan@broadcom.com>,
        Ganesh Goudar <ganeshgr@chelsio.com>,
        Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
        Saeed Mahameed <saeedm@mellanox.com>,
        Matan Barak <matanb@mellanox.com>,
        Leon Romanovsky <leonro@mellanox.com>,
        Ido Schimmel <idosch@mellanox.com>,
        Jakub Kicinski <jakub.kicinski@netronome.com>,
        Alexei Starovoitov <ast@kernel.org>,
        Daniel Borkmann <daniel@iogearbox.net>,
        Simon Horman <simon.horman@netronome
To: Alexander Duyck <alexander.duyck@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f65.google.com ([209.85.218.65]:48395 "EHLO
        mail-oi0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751378AbdJXREB (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 24 Oct 2017 13:04:01 -0400
Received: by mail-oi0-f65.google.com with SMTP id m198so38396611oig.5
        for <netdev@vger.kernel.org>; Tue, 24 Oct 2017 10:04:01 -0700 (PDT)
In-Reply-To: <CAJ3xEMgdRBEuv0hb_G43zJXXRy=PWgY2tdHuwDN0Opc2NVF35g@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Oct 24, 2017 at 8:02 PM, Or Gerlitz <gerlitz.or@gmail.com> wrote:
> On Tue, Oct 24, 2017 at 7:24 PM, Alexander Duyck <alexander.duyck@gmail.com> wrote:
>> On Tue, Oct 24, 2017 at 9:01 AM, Alexander Duyck <alexander.duyck@gmail.com> wrote:

>>> We are getting internal reports of regressions being seen with this
>>> patch set applied. Specifically the issues below have been pointed out
>>> to me. My understanding is that these issues are all being reported on ixgbe:

>>> 1.       To offload filter into HW, the hw-tc-offload feature flag has
>>> to be turned on before creating the ingress qdisc.

>>> 2.       Deleting the ingress qdisc fails to remove filters added in
>>> HW. Filters in SW gets deleted.

> FWIW, I don't think this is what you're hitting, but please note there are
> two  fixes  to the series in net-next
>
> 9d452ce net/sched: Fix actions list corruption when adding offloaded tc flows
> 0843c09 net/sched: Set the net-device for egress device instance
>
> I had to looked on other stuff today, but I will keep stressing see if/what
> is broken w.r.t mlx5
> and help to get things to work later this and next week so by netdev we'll
> be fine
>
> Or.
