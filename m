From: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Subject: Re: [PATCH net-next] net/vxlan: Avoid unaligned access in
 vxlan_build_skb()
Date: Wed, 28 Sep 2016 15:56:44 -0400
Message-ID: <20160928195644.GA10249@oracle.com>
References: <20160922.015242.735026657310158125.davem@davemloft.net>
 <20160922213010.GA32052@oracle.com>
 <20160923.080618.678103827885223586.davem@davemloft.net>
 <CAKgT0UcoDb5T9xwfAq83cNwU=XAKZxf0TmPiJZQyHFPr82zggg@mail.gmail.com>
 <20160923172059.GB2484@oracle.com>
 <CAKgT0UeB5n3g4f1v_2nenjcayAi=eOPFSC7132ihXTZOztHRkw@mail.gmail.com>
 <20160923234134.GA6397@oracle.com>
 <CAKgT0Uenb+D44D4g2SieNDf3+P_wnv2WYSBZ+NU_87e011PRjA@mail.gmail.com>
 <20160928170346.GA9263@oracle.com>
 <CAKgT0UeEFoA8EQN0Fgn656mFDqC6BdnrUqUfQAJSgEwRBUxBZw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Netdev <netdev@vger.kernel.org>
To: Alexander Duyck <alexander.duyck@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:39721 "EHLO
        userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753091AbcI1T4x (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 28 Sep 2016 15:56:53 -0400
Content-Disposition: inline
In-Reply-To: <CAKgT0UeEFoA8EQN0Fgn656mFDqC6BdnrUqUfQAJSgEwRBUxBZw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On (09/28/16 11:08), Alexander Duyck wrote:
> > - then udp_gro_receive -> vxlan_gro_receive pulls up vxlan header
> >   into linear part, and then..
> 
> This is the point where we need to stop, drop the existing headers,
> call skb_reserve(NET_IP_ALIGN), and then pick back up where we left
> off.  We just have to make sure the skbuff isn't shared.
  :
> In general the interface behind the tunnel shouldn't need to know
> about any of the data in front of the tunnel, so you should be able to
> drop the original header offsets and reset things if you want so you
> could overwrite the old headers.

Except that some of these encapsulations may be doing things like
[inner-mac, outer-ip] fdb learning, so we may not be able to lose
the outer headers at this early point in all cases.

> If I am not mistaken I think the multi-buffer approach is the approach
> taken by other OSes, although for us it is more difficult since we

yes, I think that's approximately what gets done with mblk/mbufs
(with pullups as needed). But as you point out, this type of
->frag_list chaining is a non-trivial change.

> I'm sure we are all going to be talking about this in great detail
> next week at netdev/netconf.. :-)

Agree.

--Sowmini
