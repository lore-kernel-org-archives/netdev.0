From: Jakub Kicinski <kubakici@wp.pl>
Subject: Re: [patch net-next v2 00/20] net: sched: convert cls ndo_setup_tc
 offload calls to per-block callbacks
Date: Sat, 28 Oct 2017 10:17:24 -0700
Message-ID: <20171028101724.1e4e1374@cakuba.netronome.com>
References: <20171019135048.4306-1-jiri@resnulli.us>
        <20171021.030446.967534081159629805.davem@davemloft.net>
        <CAKgT0Ud0RJLZ6mz9Ysb9A7PdkcwBYt2+ASvLZQxMGPK2BwvqKw@mail.gmail.com>
        <20171025121503.GA1910@nanopsycho>
        <2e4baa66-35e3-0259-6228-ab05ec826345@intel.com>
        <20171027072730.GB1980@nanopsycho.orion>
        <20171027175200.018ebe65@cakuba.netronome.com>
        <20171028072031.GC1980@nanopsycho.orion>
        <20171028005321.3b5817da@laptop>
        <20171028084351.GF1980@nanopsycho.orion>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
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
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx4.wp.pl ([212.77.101.11]:39335 "EHLO mx4.wp.pl"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751230AbdJ1RRh (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sat, 28 Oct 2017 13:17:37 -0400
In-Reply-To: <20171028084351.GF1980@nanopsycho.orion>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 28 Oct 2017 10:43:51 +0200, Jiri Pirko wrote:
> Sat, Oct 28, 2017 at 09:53:21AM CEST, kubakici@wp.pl wrote:
> >On Sat, 28 Oct 2017 09:20:31 +0200, Jiri Pirko wrote:  
> >> Sat, Oct 28, 2017 at 02:52:00AM CEST, kubakici@wp.pl wrote:  
> >> >On Fri, 27 Oct 2017 09:27:30 +0200, Jiri Pirko wrote:    
> >> >> Yes, it is the same.    
> >> >
> >> >FWIW I also see what Amritha and Alex are describing here, for cls_bpf
> >> >there are no DESTROYs coming on rmmod or qdisc del.  There is a DESTROY
> >> >if I manually remove the filter (or if an ADD with skip_sw fails).    
> >> 
> >> Is this different to the original behaviour? Just for cls_bpf?  
> >
> >For cls_bpf the callbacks used to be 100% symmetrical, i.e. destroy
> >would always be guaranteed if add succeeded (regardless of state of
> >skip_* flags).  
> 
> Hmm. It still should be symmetrical. Looking at following path:
> cls_bpf_destroy->
>    __cls_bpf_delete->
>       cls_bpf_stop_offload->
>          cls_bpf_offload_cmd(tp, prog, TC_CLSBPF_DESTROY)
> 
> I don't see how any tp could be missed. Could you please check this
> callpath is utilized during your action (rmmod or qdisc del)?

The same path seems to be utilized but the unbind comes before the
filters are destroyed.
