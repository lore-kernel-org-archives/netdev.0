From: "Nambiar, Amritha" <amritha.nambiar@intel.com>
Subject: Re: [patch net-next v2 00/20] net: sched: convert cls ndo_setup_tc
 offload calls to per-block callbacks
Date: Thu, 26 Oct 2017 13:24:31 -0700
Message-ID: <2e4baa66-35e3-0259-6228-ab05ec826345@intel.com>
References: <20171019135048.4306-1-jiri@resnulli.us>
 <20171021.030446.967534081159629805.davem@davemloft.net>
 <CAKgT0Ud0RJLZ6mz9Ysb9A7PdkcwBYt2+ASvLZQxMGPK2BwvqKw@mail.gmail.com>
 <20171025121503.GA1910@nanopsycho>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Cc: David Miller <davem@davemloft.net>,
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
        pieter.jansenvanvuuren@netronome.com, john.hurl
To: Jiri Pirko <jiri@resnulli.us>,
        Alexander Duyck <alexander.duyck@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([192.55.52.115]:49272 "EHLO mga14.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S932328AbdJZUYp (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 26 Oct 2017 16:24:45 -0400
In-Reply-To: <20171025121503.GA1910@nanopsycho>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/25/2017 5:15 AM, Jiri Pirko wrote:
> Tue, Oct 24, 2017 at 06:01:34PM CEST, alexander.duyck@gmail.com wrote:
> 
> [...]
> 
>> 1.       To offload filter into HW, the hw-tc-offload feature flag has
>> to be turned on before creating the ingress qdisc.
>>
>> Previously, this could also be turned on after the qdisc was created
>> and the filters could still be offloaded. Looks like this is because,
>> previously the offload flag was checked as a part of filter
>> integration in the classifier, and now it is checked as part of qdisc
>> creation (ingress_init). So, if no offload capability is advertised at
>> ingress qdisc creation time then hardware will not be asked to offload
>> filters later if the flag is enabled.
> 
> I have patchset that fixes this in my queue now. Will do some smoke
> testing and send later today.
> 
> 
>>
>> 2.       Deleting the ingress qdisc fails to remove filters added in
>> HW. Filters in SW gets deleted.
>>
>> We haven’t exactly root-caused this, the changes being extensive, but
>> our guess is again something wrong with the offload check or similar
>> while unregistering the block callback (tcf_block_cb_unregister) and
>> further to the classifier (CLS_U32/CLS_FLOWER etc.) with the
>> DESTROY/REMOVE command.
> 
> Hmm. How does this worked previously. I mean, do you see change of
> behaviour? I'm asking because I don't see how rules added only to HW
> could be removed, driver should care of it. Or are you talking about
> rules added to both SW and HW?

These are rules added to both SW and HW. Previously all cls_* had
ndo_setup_tc calls based on the offload capability.

commit 8d26d5636d "net: sched: avoid ndo_setup_tc calls for
TC_SETUP_CLS*" removed this bit to work with the new block callback. Is
there something similar in the block callback flow while acting on the
tcf_proto destroy call initiated when the qdisc is cleared?

> 
> Thanks!
> 
