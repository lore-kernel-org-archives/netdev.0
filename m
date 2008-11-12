From: "Lovich, Vitali" <vlovich@qualcomm.com>
Subject: RE: [PATCH] Packet socket: mmapped IO: PACKET_TX_RING
Date: Wed, 12 Nov 2008 11:05:03 -0800
Message-ID: <FCC0EC655BD1AE408C047268D1F5DF4C3BA61272@NASANEXMB10.na.qualcomm.com>
References: <7e0dd21a0811110950g1182b86cv3e938df93f53d29d@mail.gmail.com>
 <FCC0EC655BD1AE408C047268D1F5DF4C3BA611C3@NASANEXMB10.na.qualcomm.com>
 <20081111185036.GA17717@ioremap.net>
 <7e0dd21a0811111119h3675a137t422bd508ccf2c963@mail.gmail.com>
 <20081111192954.GA19409@ioremap.net>
 <7e0dd21a0811120543k6907de3aw6b0c3de49b2ea5d2@mail.gmail.com>
 <20081112135828.GA30946@ioremap.net>
 <FCC0EC655BD1AE408C047268D1F5DF4C3BA6124F@NASANEXMB10.na.qualcomm.com>
 <20081112174114.GA4743@ioremap.net>
 <FCC0EC655BD1AE408C047268D1F5DF4C3BA61260@NASANEXMB10.na.qualcomm.com>
 <20081112181134.GA5396@ioremap.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: Johann Baudy <johaahn@gmail.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Evgeniy Polyakov <zbr@ioremap.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wolverine01.qualcomm.com ([199.106.114.254]:11370 "EHLO
	wolverine01.qualcomm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752760AbYKLTFH convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Nov 2008 14:05:07 -0500
In-Reply-To: <20081112181134.GA5396@ioremap.net>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



> -----Original Message-----
> From: Evgeniy Polyakov [mailto:zbr@ioremap.net]
> Sent: November-12-08 10:12 AM
> To: Lovich, Vitali
> Cc: Johann Baudy; netdev@vger.kernel.org
> Subject: Re: [PATCH] Packet socket: mmapped IO: PACKET_TX_RING
> 
> On Wed, Nov 12, 2008 at 09:59:20AM -0800, Lovich, Vitali
> (vlovich@qualcomm.com) wrote:
> > They aren't racy - not in the sense that your suggestion would make
> > it.  With current splice & sendfile, when it returns from the syscall,
> > the user knows that it has been transmitted and thus can continue using
> > the file descriptors & memory (in the case of vmsplice).  However, with
> > your suggestion, the user could actually never know when it's safe to
> > write into memory (even in a single-threaded situation).  Thus it is
> > racy in a single-threaded situation (even on a UP it's potentially
> > racy) which is a pretty amazing feat.  Consider:
> 
> Problem is, that when sendfile() returns nothing has been transferred.
> And in some NICs it will take a while to actually make a transfer.
> And what you wrote below is exactly the same problem as exists with
> splice/sendfile in particular and ->sendpage() in general.
I still don't see it.  This can only be a problem for vmsplice, since I believe
sendpage & splice copy the data from the source pipe if necessary.
vmsplice solves this through the SPLICE_F_GIFT flag (if not specified, 
I'm assuming it copies the data into a temporary buffer).  So I don't 
believe that these are actually racy functions if used properly.

However, your suggestion makes non-racy usage of the tx ring impossible
unless you know ahead of time how many frames you will need (in which case, resetting
the status flag is pointless).  But for proper ring buffer behaviour, it needs to
clear the flag in the skb destructor, once we know the data will no longer be used by
the driver.

> Please also update your mailer to wrap strings into 80-or-so lines, it
> is hard to answer into the middle of the paragraph.
Sorry - I hate using Outlook because it doesn't seem to honour my settings.
I'll split up the lines manually instead of trusting Outlook.

Vitali

