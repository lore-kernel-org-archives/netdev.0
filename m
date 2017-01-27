From: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Subject: Re: [PATCH RFC net-next] packet: always ensure that we pass
 hard_header_len bytes in skb_headlen() to the driver
Date: Thu, 26 Jan 2017 21:08:36 -0500
Message-ID: <20170127020836.GH29475@oracle.com>
References: <1485274309-201670-1-git-send-email-sowmini.varadhan@oracle.com>
 <CAF=yD-KXqpODBVQ0vUt1a1p_mMXzzQp=5GU33f9GY9_cbPJxDw@mail.gmail.com>
 <20170126213742.GE29475@oracle.com>
 <CAF=yD-L66dFV64fx21A3059LRiot_-j0Ykp9GkRFwf52099upQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>,
        Network Development <netdev@vger.kernel.org>
To: Willem de Bruijn <willemdebruijn.kernel@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:43488 "EHLO
        userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750784AbdA0CJ0 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 26 Jan 2017 21:09:26 -0500
Content-Disposition: inline
In-Reply-To: <CAF=yD-L66dFV64fx21A3059LRiot_-j0Ykp9GkRFwf52099upQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On (01/26/17 19:08), Willem de Bruijn wrote:
> 
> Thanks for the context. ax25_addr_parse doesn't adjust length, it only
> verifies that the contents of the variable length header matches
> protocol spec. I don't think that it or the .validate callback have to
> be modified to return length.

Yes, I noticed that too, but my reading of ax25_addr_parse
was that it checks to see that a sane L2 header has been 
passed in, and if that (sane-header) is the case, it
returns pointer to the start of data. Thus the returned
(non-null) pointer minus start should tell you the "real"
header length- is my understanding correct?

> To ensure that skb_headlen(skb) is at least a valid header length even
> when CAP_SYS_RAWIO bypasses validation perhaps revise
> dev_validate_header to take an additional skb->len parameter and
> call skb_put directly from inside that branch.

but when I scanned the af_packet code (which appears to
be the only thing that uses dev_validate_header today)
it already sets up the skb->data and ->len pointers up
correctly (based on len, hard_header_len etc) *before*
calling dev_validate_header, so the additional skb_put
is not needed?

still havent googled up prior discussions that led
to dev_validate_header- will probably do that tomorrow AM.

--Sowmini
