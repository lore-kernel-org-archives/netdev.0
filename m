From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [patch net-next v2 00/20] net: sched: convert cls ndo_setup_tc
 offload calls to per-block callbacks
Date: Tue, 31 Oct 2017 11:46:41 +0100
Message-ID: <20171031104641.GI1972@nanopsycho.orion>
References: <CAKgT0Ud0RJLZ6mz9Ysb9A7PdkcwBYt2+ASvLZQxMGPK2BwvqKw@mail.gmail.com>
 <20171025121503.GA1910@nanopsycho>
 <2e4baa66-35e3-0259-6228-ab05ec826345@intel.com>
 <20171027072730.GB1980@nanopsycho.orion>
 <20171027175200.018ebe65@cakuba.netronome.com>
 <20171028072031.GC1980@nanopsycho.orion>
 <20171028005321.3b5817da@laptop>
 <20171028084351.GF1980@nanopsycho.orion>
 <20171028101724.1e4e1374@cakuba.netronome.com>
 <20171029072625.GA2635@nanopsycho>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
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
Received: from mail-wm0-f52.google.com ([74.125.82.52]:45601 "EHLO
        mail-wm0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752838AbdJaKqn (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 31 Oct 2017 06:46:43 -0400
Received: by mail-wm0-f52.google.com with SMTP id y80so14658951wmd.0
        for <netdev@vger.kernel.org>; Tue, 31 Oct 2017 03:46:43 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20171029072625.GA2635@nanopsycho>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Sun, Oct 29, 2017 at 08:26:25AM CET, jiri@resnulli.us wrote:
>Sat, Oct 28, 2017 at 07:17:24PM CEST, kubakici@wp.pl wrote:
>>On Sat, 28 Oct 2017 10:43:51 +0200, Jiri Pirko wrote:
>>> Sat, Oct 28, 2017 at 09:53:21AM CEST, kubakici@wp.pl wrote:
>>> >On Sat, 28 Oct 2017 09:20:31 +0200, Jiri Pirko wrote:  
>>> >> Sat, Oct 28, 2017 at 02:52:00AM CEST, kubakici@wp.pl wrote:  
>>> >> >On Fri, 27 Oct 2017 09:27:30 +0200, Jiri Pirko wrote:    
>>> >> >> Yes, it is the same.    
>>> >> >
>>> >> >FWIW I also see what Amritha and Alex are describing here, for cls_bpf
>>> >> >there are no DESTROYs coming on rmmod or qdisc del.  There is a DESTROY
>>> >> >if I manually remove the filter (or if an ADD with skip_sw fails).    
>>> >> 
>>> >> Is this different to the original behaviour? Just for cls_bpf?  
>>> >
>>> >For cls_bpf the callbacks used to be 100% symmetrical, i.e. destroy
>>> >would always be guaranteed if add succeeded (regardless of state of
>>> >skip_* flags).  
>>> 
>>> Hmm. It still should be symmetrical. Looking at following path:
>>> cls_bpf_destroy->
>>>    __cls_bpf_delete->
>>>       cls_bpf_stop_offload->
>>>          cls_bpf_offload_cmd(tp, prog, TC_CLSBPF_DESTROY)
>>> 
>>> I don't see how any tp could be missed. Could you please check this
>>> callpath is utilized during your action (rmmod or qdisc del)?
>>
>>The same path seems to be utilized but the unbind comes before the
>>filters are destroyed.
>
>Ah, will fix. Thanks!

We need to move tcf_block_offload_unbind(block, q, ei); call after the
chains are flushed. There are big waves around this code in net and
net-next atm. Will send a patch fix this once the storm is over.

Thanks!
