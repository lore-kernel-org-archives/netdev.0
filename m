From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: Re: [patch net-next v2 00/20] net: sched: convert cls ndo_setup_tc
 offload calls to per-block callbacks
Date: Wed, 25 Oct 2017 16:48:18 +0300
Message-ID: <e5be50b2-4462-16b3-d82d-cee7aeee1eff@mellanox.com>
References: <20171019135048.4306-1-jiri@resnulli.us>
 <20171021.030446.967534081159629805.davem@davemloft.net>
 <CAKgT0Ud0RJLZ6mz9Ysb9A7PdkcwBYt2+ASvLZQxMGPK2BwvqKw@mail.gmail.com>
 <20171025121503.GA1910@nanopsycho>
 <aaa66a3d-766b-f758-692a-eba7f5a8702f@mellanox.com>
 <20171025134211.GA1976@nanopsycho.orion>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Alexander Duyck <alexander.duyck@gmail.com>,
        David Miller <davem@davemloft.net>,
        Netdev <netdev@vger.kernel.org>,
        Jamal Hadi Salim <jhs@mojatatu.com>,
        Cong Wang <xiyou.wangcong@gmail.com>, mlxsw@mellanox.com,
        Andrew Lunn <andrew@lunn.ch>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
        Florian Fainelli <f.fainelli@gmail.com>,
        Michael Chan <michael.chan@broadcom.com>,
        Ganesh Goudar <ganeshgr@chelsio.com>,
        Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
        Saeed Mahameed <saeedm@mellanox.com>,
        Matan Barak <matanb@mellanox.com>,
        Leon Romanovsky <leonro@mellanox.com>, idosch@mellanox.com,
        Jakub Kicinski <jakub.kicinski@netronome.com>,
        Alexei Starovoitov <ast@kernel.org>,
        Daniel Borkmann <daniel@iogearbox.net>,
        Simon Horman <simon.horman@netronome.com>,
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-eopbgr50065.outbound.protection.outlook.com ([40.107.5.65]:61600
        "EHLO EUR03-VE1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1751589AbdJYNs1 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 25 Oct 2017 09:48:27 -0400
In-Reply-To: <20171025134211.GA1976@nanopsycho.orion>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/25/2017 4:42 PM, Jiri Pirko wrote:
> Yes, that is intentional. The thing is, there might be multiple block
> callbacks registered and to be called. If there is a fail with one, we
> need to cleanup all. So in your case you have 1 cb registered, that
> means that in case of an error during insertion, you will get cb called
> to remove. Driver has to take care of that. I was checking that and was
> under impression that mlx5 deals with that.

I see, yeah, in mlx5 we identify that the flow doesn't exist in our 
tables, I sent a patch that deals with that and also another issue, lets 
discuss it there.
