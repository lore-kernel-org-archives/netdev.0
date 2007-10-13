From: "Moni Shoua" <monisonlists@gmail.com>
Subject: Re: [PATCH] IB/ipoib: Bound the net device to the ipoib_neigh structue
Date: Sat, 13 Oct 2007 17:24:09 +0200
Message-ID: <9d62a5110710130824w5aa663b0l7aac9df5480f21a0@mail.gmail.com>
References: <11916151232222-git-send-email-fubar@us.ibm.com>
	 <470C200D.4010705@pobox.com> <470C2343.1020800@garzik.org>
	 <20071009.181246.41634534.davem@davemloft.net> <706.1191979132@death>
	 <470CF7E1.6060503@voltaire.com> <aday7eaddod.fsf@cisco.com>
	 <470E37AD.3070408@voltaire.com> <ada3awhcsnw.fsf@cisco.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "Moni Shoua" <monis@voltaire.com>,
	"Jay Vosburgh" <fubar@us.ibm.com>, jeff@garzik.org,
	"David Miller" <davem@davemloft.net>, ogerlitz@voltaire.com,
	netdev@vger.kernel.org, "Moni Levy" <monil@voltaire.com>
To: "Roland Dreier" <rdreier@cisco.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wa-out-1112.google.com ([209.85.146.181]:3544 "EHLO
	wa-out-1112.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754799AbXJMPYK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 13 Oct 2007 11:24:10 -0400
Received: by wa-out-1112.google.com with SMTP id v27so1348312wah
        for <netdev@vger.kernel.org>; Sat, 13 Oct 2007 08:24:10 -0700 (PDT)
In-Reply-To: <ada3awhcsnw.fsf@cisco.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

I will be near my lab only tomorrow...
I will check this and let you know.

On 10/11/07, Roland Dreier <rdreier@cisco.com> wrote:
>  > It happens only when ib interfaces are slaves of a bonding device.
>  > I thought before that the stuck is in napi_disable() but it's almost right.
>  > I put prints before and after call to napi_disable and see that it is called twice.
>  > I'll try to investigate in this direction.
>  >
>  > ib0: stopping interface
>  > ib0: before napi_disable
>  > ib0: after napi_disable
>  > ib0: downing ib_dev
>  > ib0: All sends and receives done.
>  > ib0: stopping interface
>  > ib0: before napi_disable
>
> Yes, two napi_disable()s in a row without a matching napi_enable()
> will deadlock.  I guess the question is why the ipoib interface is
> being stopped twice.
>
> If you just take the net-2.6.24 tree (without bonding patches), does
> bonding for ethernet interfaces work OK, or is there a similar problem
> with double napi_disable()?  How about bonding of ethernet after this
> batch of bonding patches?
>
>  - R.
> -
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>
