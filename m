From: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Subject: Re: [PATCH RFC net-next] packet: always ensure that we pass
 hard_header_len bytes in skb_headlen() to the driver
Date: Mon, 30 Jan 2017 11:26:03 -0500
Message-ID: <20170130162603.GF3590@oracle.com>
References: <20170127020836.GH29475@oracle.com>
 <CAF=yD-LWLDQhQMBA9O5T5k+di5VKMPtix+pHLb-zjUtd4+WZmQ@mail.gmail.com>
 <20170127151119.GB25829@oracle.com>
 <CAF=yD-+LS6g572Uo5oErq7uazxxPwXXo0w2p4zcHDbXxkuah6Q@mail.gmail.com>
 <20170127170320.GD25829@oracle.com>
 <CAF=yD-J6r+myVVAb5uNL8-Fua7Gr5q8U+veqPB=xm4gNOTp5Tg@mail.gmail.com>
 <20170127200639.GF25829@oracle.com>
 <CAF=yD-+GGAdvgXoZeMshyQXXh_3m9kjDGNFf9FQ43rxJgk__vw@mail.gmail.com>
 <20170127215848.GG25829@oracle.com>
 <CAF=yD-KqQdPVn-CFAu3ak+c3NRO9gfT+8UwXXS4eSv9ax0iAnA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>,
        Network Development <netdev@vger.kernel.org>
To: Willem de Bruijn <willemdebruijn.kernel@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:42134 "EHLO
        userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932440AbdA3Q0N (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 30 Jan 2017 11:26:13 -0500
Content-Disposition: inline
In-Reply-To: <CAF=yD-KqQdPVn-CFAu3ak+c3NRO9gfT+8UwXXS4eSv9ax0iAnA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On (01/27/17 19:19), Willem de Bruijn wrote:
> > other than ax25, are there variable length header protocols out there
> > without ->validate, and which need the CAP_RAW_SYSIO branch?
> 
> I don't know. An exhaustive search of protocols (by header_ops) may be
> needed to say for sure.
> 
> If there are none, then the solution indeed is quite simple.


I tried to start that exhaustive search, and it can be quite daunting:
if you are doing this by just code-inspection, it's easy to get
it wrong.. I havent quite given up yet, but it may be simpler to have
the drivers support some defensive code against bogus skb's in the
Tx path (the drivers will know, for sure, what's the min non-paged
len they need anyway).

--Sowmini
