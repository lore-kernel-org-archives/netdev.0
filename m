From: Somnath Kotur <Somnath.Kotur@Emulex.Com>
Subject: RE: [PATCH net 2/2] be2net: Need a delay before processing CQE
 after 2nd mbox register write
Date: Tue, 14 Jan 2014 06:33:56 +0000
Message-ID: <4d812a88-90d8-4376-a0bb-7faa6d0491d4@CMEXHTCAS1.ad.emulex.com>
References: <4b4fd4cb-9d23-4900-a20c-f2c2bef70849@CMEXHTCAS2.ad.emulex.com>
 <063D6719AE5E284EB5DD2968C1650D6D454FBA@AcuExch.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "davem@davemloft.net" <davem@davemloft.net>,
	Kalesh Purayil <Kalesh.Purayil@Emulex.Com>
To: David Laight <David.Laight@ACULAB.COM>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cmexedge1.ext.emulex.com ([138.239.224.99]:59415 "EHLO
	CMEXEDGE1.ext.emulex.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751203AbaANGd6 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Jan 2014 01:33:58 -0500
In-Reply-To: <063D6719AE5E284EB5DD2968C1650D6D454FBA@AcuExch.aculab.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



> -----Original Message-----
> From: David Laight [mailto:David.Laight@ACULAB.COM]
> Sent: Wednesday, January 08, 2014 3:02 PM
> To: Somnath Kotur; netdev@vger.kernel.org
> Cc: davem@davemloft.net; Kalesh Purayil
> Subject: RE: [PATCH net 2/2] be2net: Need a delay before processing CQE
> after 2nd mbox register write
> 
> > From: Somnath Kotur
> > Due to Host platform synchronization issues between the mbox RDY bit
> > polled status and the completion of the DMA for the CQE, it is
> > preferable that the Host always wait for the RDY bit to transition to
> > 1 after the 2nd mbox register write and always follow that with a
> > short wait for the valid bit in the CQE, before processing the CQE.
> 
> While I don't doubt that a delay(1) fixes the problem it doesn't seem an ideal
> solution.
> I've not looked at what the code is doing (or how often it does it) but either
> delay(1) is far, far longer than is necessary or it might not be long enough and
> some kind of retry loop is required.
> 
> It might even be that the driver is just missing a memory barrier.

David,
	The memory barrier by itself did not work, however like you said polling on the valid 
Bit to be set seems like the right solution as the time for the mbox-completion DMA to finish/reach the host
may not be deterministic.

Thanks
Som
