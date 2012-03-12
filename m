From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: [PATCH RE-SUBMIT 2/2] net/pch_gbe: supports eg20t ptp clock
Date: Mon, 12 Mar 2012 07:17:02 +0100
Message-ID: <20120312061702.GA1911@netboy.at.omicron.at>
References: <1331194587-29114-1-git-send-email-tshimizu818@gmail.com>
 <1331194587-29114-2-git-send-email-tshimizu818@gmail.com>
 <20120310111149.GC3489@netboy.at.omicron.at>
 <CAHBEfB8bAyGDAtP1O8OFoTw5GAs9C2Sht-idXiXUYkc7vWVSTQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jeffrey.t.kirsher@intel.com, davem@davemloft.net,
	lucas.demarchi@profusion.mobi, mirq-linux@rere.qmqm.pl,
	paul.gortmaker@windriver.com, jdmason@kudzu.us,
	john.stultz@linaro.org, arnd@arndb.de, khc@pm.waw.pl,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	qi.wang@intel.com, yong.y.wang@intel.com, joel.clark@intel.com,
	kok.howg.ewe@intel.com
To: Takahiro Shimizu <tshimizu818@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f178.google.com ([209.85.212.178]:49169 "EHLO
	mail-wi0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753186Ab2CLGRJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 Mar 2012 02:17:09 -0400
Content-Disposition: inline
In-Reply-To: <CAHBEfB8bAyGDAtP1O8OFoTw5GAs9C2Sht-idXiXUYkc7vWVSTQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Mar 12, 2012 at 09:35:44AM +0900, Takahiro Shimizu wrote:
> Hello Richard,
> 
> Thank you for the comment.
> 
> > +     if ((sk_run_filter(skb, ptp_filter) != PTP_CLASS_V2_IPV4) &&
> > > +             (sk_run_filter(skb, ptp_filter) != PTP_CLASS_V1_IPV4)) {
> >
> > No, just run the filter once and test the result twice.
> >
> > Also, doesn't the timestamping unit work with IPv6 and L2?  If so,
> > don't restrict the driver to IPv4.
> >
> >
> According to the EG20T spec, it support IPv6 too. But I did not any test
> about IPv6 now.
> Do you mean I don't restrict anything here?

No, what I mean is that you only accept PTP_CLASS_V1_IPV4 or
PTP_CLASS_V2_IPV4. You should accept any packet type supported by the
hardware.

If someone tries to use your driver with PTPv2 over UDPv6, for
example, then the filter will return PTP_CLASS_V2_IPV6, and the match
will fail. It will also fail for PTPv2 L2 and PTPv2 L2/VLAN.

It does not make sense to me to limit the driver in this way.

Richard
