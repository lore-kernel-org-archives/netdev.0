From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [patch net-next v2 00/20] net: sched: convert cls ndo_setup_tc
 offload calls to per-block callbacks
Date: Sat, 28 Oct 2017 09:20:31 +0200
Message-ID: <20171028072031.GC1980@nanopsycho.orion>
References: <20171019135048.4306-1-jiri@resnulli.us>
 <20171021.030446.967534081159629805.davem@davemloft.net>
 <CAKgT0Ud0RJLZ6mz9Ysb9A7PdkcwBYt2+ASvLZQxMGPK2BwvqKw@mail.gmail.com>
 <20171025121503.GA1910@nanopsycho>
 <2e4baa66-35e3-0259-6228-ab05ec826345@intel.com>
 <20171027072730.GB1980@nanopsycho.orion>
 <20171027175200.018ebe65@cakuba.netronome.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Cc: "Nambiar, Amritha" <amritha.nambiar@intel.com>,
        Alexander Duyck <alexander.duyck@gmail.com>,
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
        Alexei Starovoitov <ast@kernel.org>,
        Daniel Borkmann <daniel@iogearbox.net>,
        Simon Horman <simon.horman@netronome.com>,
To: Jakub Kicinski <kubakici@wp.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f193.google.com ([209.85.128.193]:46303 "EHLO
        mail-wr0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750788AbdJ1HUd (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 28 Oct 2017 03:20:33 -0400
Received: by mail-wr0-f193.google.com with SMTP id l1so7984131wrc.3
        for <netdev@vger.kernel.org>; Sat, 28 Oct 2017 00:20:32 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20171027175200.018ebe65@cakuba.netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Sat, Oct 28, 2017 at 02:52:00AM CEST, kubakici@wp.pl wrote:
>On Fri, 27 Oct 2017 09:27:30 +0200, Jiri Pirko wrote:
>> >>> 2.       Deleting the ingress qdisc fails to remove filters added in
>> >>> HW. Filters in SW gets deleted.
>> >>>
>> >>> We haven’t exactly root-caused this, the changes being extensive, but
>> >>> our guess is again something wrong with the offload check or similar
>> >>> while unregistering the block callback (tcf_block_cb_unregister) and
>> >>> further to the classifier (CLS_U32/CLS_FLOWER etc.) with the
>> >>> DESTROY/REMOVE command.  
>> >> 
>> >> Hmm. How does this worked previously. I mean, do you see change of
>> >> behaviour? I'm asking because I don't see how rules added only to HW
>> >> could be removed, driver should care of it. Or are you talking about
>> >> rules added to both SW and HW?  
>> >
>> >These are rules added to both SW and HW. Previously all cls_* had
>> >ndo_setup_tc calls based on the offload capability.
>> >
>> >commit 8d26d5636d "net: sched: avoid ndo_setup_tc calls for
>> >TC_SETUP_CLS*" removed this bit to work with the new block callback. Is
>> >there something similar in the block callback flow while acting on the
>> >tcf_proto destroy call initiated when the qdisc is cleared?  
>> 
>> Yes, it is the same.
>
>FWIW I also see what Amritha and Alex are describing here, for cls_bpf
>there are no DESTROYs coming on rmmod or qdisc del.  There is a DESTROY
>if I manually remove the filter (or if an ADD with skip_sw fails).

Is this different to the original behaviour? Just for cls_bpf?
