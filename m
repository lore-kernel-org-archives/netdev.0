From: "Dmitry Kravkov" <dmitry@broadcom.com>
Subject: RE: [PATCH net] bnx2x: fix TCP offload for tunneling ipv4 over
 ipv6
Date: Mon, 3 Jun 2013 11:45:24 +0000
Message-ID: <504C9EFCA2D0054393414C9CB605C37F20C96065@SJEXCHMB06.corp.ad.broadcom.com>
References: <1370251721-24668-1-git-send-email-dmitry@broadcom.com>
 <51AC7DB3.70908@cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=us-ascii
Content-Transfer-Encoding: 8BIT
Cc: "davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"Ariel Elior" <ariele@broadcom.com>,
	"Eilon Greenstein" <eilong@broadcom.com>
To: "Sergei Shtylyov" <sergei.shtylyov@cogentembedded.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:4630 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752448Ab3FCLpd convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 Jun 2013 07:45:33 -0400
In-Reply-To: <51AC7DB3.70908@cogentembedded.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> -----Original Message-----
> From: Sergei Shtylyov [mailto:sergei.shtylyov@cogentembedded.com]
> Sent: Monday, June 03, 2013 2:28 PM
> To: Dmitry Kravkov
> Cc: davem@davemloft.net; netdev@vger.kernel.org; Ariel Elior; Eilon Greenstein
> Subject: Re: [PATCH net] bnx2x: fix TCP offload for tunneling ipv4 over ipv6
> 
> Hello.
> 
> On 03-06-2013 13:28, Dmitry Kravkov wrote:
> 
> > FW was initialized with data from wrong header, this caused TSO packets
> > have wrong IP csum.
> 
> > Signed-off-by: Dmitry Kravkov <dmitry@broadcom.com>
> > Signed-off-by: Ariel Elior <ariele@broadcom.com>
> > Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
> > ---
> >   drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c | 13 ++++++-------
> >   1 file changed, 6 insertions(+), 7 deletions(-)
> 
> > diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
> > index c80f1d2..37c1495 100644
> > --- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
> > +++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
> > @@ -3198,11 +3198,11 @@ static u32 bnx2x_xmit_type(struct bnx2x *bp, struct sk_buff *skb)
> >   		rc |= XMIT_CSUM_TCP;
> >
> >   	if (skb_is_gso_v6(skb)) {
> > -		rc |= (XMIT_GSO_V6 | XMIT_CSUM_TCP | XMIT_CSUM_V6);
> > +		rc |= (XMIT_GSO_V6 | XMIT_CSUM_TCP);
> 
>    Maybe it's time to drop the useless ()?
> 
> >   		if (rc & XMIT_CSUM_ENC)
> >   			rc |= XMIT_GSO_ENC_V6;
> >   	} else if (skb_is_gso(skb)) {
> > -		rc |= (XMIT_GSO_V4 | XMIT_CSUM_V4 | XMIT_CSUM_TCP);
> > +		rc |= (XMIT_GSO_V4 | XMIT_CSUM_TCP);
> 
>     Oh, here as well...
> 
> WBR, Sergei
>
Net tree is not proper place for pure beautification - this can be done in net-next after this functional change is merged there


 
