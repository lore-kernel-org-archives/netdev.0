From: Heiko Carstens <heiko.carstens@de.ibm.com>
Subject: Re: igb driver triggers BUILD_BUG_ON on s390
Date: Tue, 12 Mar 2013 07:59:00 +0100
Message-ID: <20130312065900.GA4148@osiris>
References: <20130309100004.GA3584@osiris>
 <513DFC80.5000105@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>
To: Alexander Duyck <alexander.h.duyck@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e06smtp13.uk.ibm.com ([195.75.94.109]:55106 "EHLO
	e06smtp13.uk.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753416Ab3CLG7F (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Mar 2013 02:59:05 -0400
Received: from /spool/local
	by e06smtp13.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <heiko.carstens@de.ibm.com>;
	Tue, 12 Mar 2013 06:57:02 -0000
Received: from b06cxnps4076.portsmouth.uk.ibm.com (d06relay13.portsmouth.uk.ibm.com [9.149.109.198])
	by d06dlp02.portsmouth.uk.ibm.com (Postfix) with ESMTP id 3271E219002D
	for <netdev@vger.kernel.org>; Tue, 12 Mar 2013 07:00:35 +0000 (GMT)
Received: from d06av03.portsmouth.uk.ibm.com (d06av03.portsmouth.uk.ibm.com [9.149.37.213])
	by b06cxnps4076.portsmouth.uk.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r2C6wpYX27656430
	for <netdev@vger.kernel.org>; Tue, 12 Mar 2013 06:58:51 GMT
Received: from d06av03.portsmouth.uk.ibm.com (localhost.localdomain [127.0.0.1])
	by d06av03.portsmouth.uk.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r2C6x0nl003484
	for <netdev@vger.kernel.org>; Tue, 12 Mar 2013 00:59:00 -0600
Content-Disposition: inline
In-Reply-To: <513DFC80.5000105@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Mar 11, 2013 at 08:47:12AM -0700, Alexander Duyck wrote:
> On 03/09/2013 02:00 AM, Heiko Carstens wrote:
> > git commit 74e238ead "igb: Support using build_skb in the case that
> > jumbo frames are disabled" added a BUILD_BUG_ON() to the igb driver=
s
> > which triggers on s390:
> >
> > drivers/net/ethernet/intel/igb/igb_main.c:6231:2:
> > error: call to =E2=80=98__compiletime_assert_6235=E2=80=99 declared=
 with attribute error:
> >   BUILD_BUG_ON failed: SKB_WITH_OVERHEAD(IGB_RX_BUFSZ) <
> >     (NET_SKB_PAD + NET_IP_ALIGN + IGB_TS_HDR_LEN + ETH_FRAME_LEN + =
ETH_FCS_LEN)
> >
> > Any opinions?
> >
>=20
> A fix for this has already been submitted. As it turns out the
> BUILD_BUG_ON is mostly redundant anyway since we used a similar
> calculation to determine if we were going to enable the use of build_=
skb
> per ring.

Ok, thanks!
