From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: [PATCH net-next] dp83640: Fix receive timestamp race condition
Date: Thu, 17 Jul 2014 20:12:22 +0200
Message-ID: <20140717181222.GB23623@localhost.localdomain>
References: <1405603079-23572-1-git-send-email-stefan.sorensen@spectralink.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Stefan =?iso-8859-1?Q?S=F8rensen?=
	<stefan.sorensen@spectralink.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f178.google.com ([209.85.212.178]:56394 "EHLO
	mail-wi0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751275AbaGQSMn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Jul 2014 14:12:43 -0400
Received: by mail-wi0-f178.google.com with SMTP id hi2so3278839wib.11
        for <netdev@vger.kernel.org>; Thu, 17 Jul 2014 11:12:42 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1405603079-23572-1-git-send-email-stefan.sorensen@spectralink.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jul 17, 2014 at 03:17:59PM +0200, Stefan S=F8rensen wrote:
> When timestamping received packets, rx_timestamp_work may be schedule=
d before
> the timestamps is received from the hardware resulting in the packet =
beeing
> delivered without the timestamp.
>=20
> This is fixed by changing the receive timestamp path: On receiving a =
packet
> that need timestamping, it is added to a queue. When a timestamp arri=
ves, the
> queue is traversed and if a matching packet is found, it is deliverd =
with the
> timestamp. In case the hardware drops a timestamp, a workqueue regula=
rly
> checks the queue for old packets and delivers them without a timestam=
p.

And what happens when the timestamp arrives *before* the PTP packet?

The original code was desgined to handle this possibility. Although it
makes logical sense for the PHY to deliver the status frame after the
regular frame, there is nothing in the documentation that confirms
this behavior, and hardware engineering decisions are not always
logical. If some newer silicon revision were to buffer the incoming
packet, waiting for the time stamp logic, then the driver should still
work.

Thanks,
Richard
