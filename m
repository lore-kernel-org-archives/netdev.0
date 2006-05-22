From: "Haruki Dai-r35557" <Dai.Haruki@freescale.com>
Subject: RE: [PATCH] Gianfar SKB Recycling Support
Date: Sun, 21 May 2006 18:38:26 -0700
Message-ID: <18AEF66AFDF06F4CAAA1D419D000FD33524DED@az33exm24.fsl.freescale.net>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: <netdev@vger.kernel.org>,
	"Fleming Andy-afleming" <afleming@freescale.com>,
	"Kumar Gala" <galak@kernel.crashing.org>, <linuxppc-dev@ozlabs.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from de01egw02.freescale.net ([192.88.165.103]:62656 "EHLO
	de01egw02.freescale.net") by vger.kernel.org with ESMTP
	id S964973AbWEVBiZ convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 21 May 2006 21:38:25 -0400
Received: from de01smr02.am.mot.com (de01smr02.freescale.net [10.208.0.151])
	by de01egw02.freescale.net (8.12.11/de01egw02) with ESMTP id k4M1mcfl027320
	for <netdev@vger.kernel.org>; Sun, 21 May 2006 18:48:38 -0700 (MST)
Received: from az33exm24.fsl.freescale.net (az33exm24.am.freescale.net [10.64.32.14])
	by de01smr02.am.mot.com (8.13.1/8.13.0) with ESMTP id k4M1cONM010796
	for <netdev@vger.kernel.org>; Sun, 21 May 2006 20:38:24 -0500 (CDT)
Content-class: urn:content-classes:message
To: "Stephen Hemminger" <shemminger@osdl.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> -----Original Message-----
> From: Stephen Hemminger [mailto:shemminger@osdl.org] 
> Sent: Saturday, May 20, 2006 2:48 AM
> To: Haruki Dai-r35557
> Cc: netdev@vger.kernel.org; Fleming Andy-afleming; Kumar 
> Gala; Haruki Dai-r35557
> Subject: Re: [PATCH] Gianfar SKB Recycling Support
> 
> On Wed, 17 May 2006 15:45:14 -0700
> "Haruki Dai-r35557" <Dai.Haruki@freescale.com> wrote:
> 
> > This patch improves the IP forwarding throughput of
> > the Freescale TSEC/eTSEC Gianfar driver. By recycling
> > the Socket buffer and Data buffer, reduce the unnecessary
> > memory allocation and de-allocation in the forwarding
> > processing chain.
> > 
> > Signed-off-by: Dai Haruki <dai.haruki@freescale.com>
> > Signed-off-by: Andy Fleming <afleming@freescale.com>
> > 
> 
> In case the general impression wasn't clear from the earlier comments.
> This patch is an interesting benchmark tweak, but unlikely to ever
> make it into the mainline kernel. The kernel needs to be a general
> purpose system and deal with multiple types of hardware and resource
> control.
> 
> But don't give up looking at performance. If you can find ways to
> speed up the overall socket buffer handling without breaking existing
> semantics; then the patches would be positively received.
>

I admit the explanation of the implementation is indeed unclear. I will
put the recycling mechanism explanation. Is it better put as the
driver's comment? Or, the separate document like, say,
Document/net/skb_recycling.txt?

Just in case, I need to confirm that the patch is rejected even though
the expalanation is added? 

I will surely work for making this mechanism more generic to the other
interface. I want to make sure that this patch is not the purpose of
benchmark tweak. This recycling mechanism makes the Linux's position in
the packet forwarding application better compare to the other
proprietary OS/Stack in terms of the throughput performance. 
 
 For the gianfar user, this patch also improves interrupt response under
the situation when previous gianfar tied up with the a lot of TX hw
interrupt even under NAPI (current gianfar NAPI implementation only help
Rx side since we have separate interrupt line). I will separate the
gianfar specific improvement, and post to this list again.



- Dai
