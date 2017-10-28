From: Jakub Kicinski <kubakici@wp.pl>
Subject: Re: [patch net-next v2 00/20] net: sched: convert cls ndo_setup_tc
 offload calls to per-block callbacks
Date: Fri, 27 Oct 2017 17:52:00 -0700
Message-ID: <20171027175200.018ebe65@cakuba.netronome.com>
References: <20171019135048.4306-1-jiri@resnulli.us>
        <20171021.030446.967534081159629805.davem@davemloft.net>
        <CAKgT0Ud0RJLZ6mz9Ysb9A7PdkcwBYt2+ASvLZQxMGPK2BwvqKw@mail.gmail.com>
        <20171025121503.GA1910@nanopsycho>
        <2e4baa66-35e3-0259-6228-ab05ec826345@intel.com>
        <20171027072730.GB1980@nanopsycho.orion>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
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
Received: from mx3.wp.pl ([212.77.101.9]:58962 "EHLO mx3.wp.pl"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750915AbdJ1AwN (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 27 Oct 2017 20:52:13 -0400
In-Reply-To: <20171027072730.GB1980@nanopsycho.orion>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 27 Oct 2017 09:27:30 +0200, Jiri Pirko wrote:
> >>> 2.       Deleting the ingress qdisc fails to remove filters added in
> >>> HW. Filters in SW gets deleted.
> >>>
> >>> We haven=E2=80=99t exactly root-caused this, the changes being extens=
ive, but
> >>> our guess is again something wrong with the offload check or similar
> >>> while unregistering the block callback (tcf_block_cb_unregister) and
> >>> further to the classifier (CLS_U32/CLS_FLOWER etc.) with the
> >>> DESTROY/REMOVE command. =20
> >>=20
> >> Hmm. How does this worked previously. I mean, do you see change of
> >> behaviour? I'm asking because I don't see how rules added only to HW
> >> could be removed, driver should care of it. Or are you talking about
> >> rules added to both SW and HW? =20
> >
> >These are rules added to both SW and HW. Previously all cls_* had
> >ndo_setup_tc calls based on the offload capability.
> >
> >commit 8d26d5636d "net: sched: avoid ndo_setup_tc calls for
> >TC_SETUP_CLS*" removed this bit to work with the new block callback. Is
> >there something similar in the block callback flow while acting on the
> >tcf_proto destroy call initiated when the qdisc is cleared? =20
>=20
> Yes, it is the same.

FWIW I also see what Amritha and Alex are describing here, for cls_bpf
there are no DESTROYs coming on rmmod or qdisc del.  There is a DESTROY
if I manually remove the filter (or if an ADD with skip_sw fails).
