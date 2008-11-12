From: Evgeniy Polyakov <zbr@ioremap.net>
Subject: Re: [PATCH] Packet socket: mmapped IO: PACKET_TX_RING
Date: Wed, 12 Nov 2008 21:11:34 +0300
Message-ID: <20081112181134.GA5396@ioremap.net>
References: <7e0dd21a0811110950g1182b86cv3e938df93f53d29d@mail.gmail.com> <FCC0EC655BD1AE408C047268D1F5DF4C3BA611C3@NASANEXMB10.na.qualcomm.com> <20081111185036.GA17717@ioremap.net> <7e0dd21a0811111119h3675a137t422bd508ccf2c963@mail.gmail.com> <20081111192954.GA19409@ioremap.net> <7e0dd21a0811120543k6907de3aw6b0c3de49b2ea5d2@mail.gmail.com> <20081112135828.GA30946@ioremap.net> <FCC0EC655BD1AE408C047268D1F5DF4C3BA6124F@NASANEXMB10.na.qualcomm.com> <20081112174114.GA4743@ioremap.net> <FCC0EC655BD1AE408C047268D1F5DF4C3BA61260@NASANEXMB10.na.qualcomm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Johann Baudy <johaahn@gmail.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "Lovich, Vitali" <vlovich@qualcomm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cs-studio.ru ([195.178.208.66]:48844 "EHLO tservice.net.ru"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1751604AbYKLSLg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 12 Nov 2008 13:11:36 -0500
Content-Disposition: inline
In-Reply-To: <FCC0EC655BD1AE408C047268D1F5DF4C3BA61260@NASANEXMB10.na.qualcomm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Nov 12, 2008 at 09:59:20AM -0800, Lovich, Vitali (vlovich@qualcomm.com) wrote:
> They aren't racy - not in the sense that your suggestion would make it.  With current splice & sendfile, when it returns from the syscall, the user knows that it has been transmitted and thus can continue using the file descriptors & memory (in the case of vmsplice).  However, with your suggestion, the user could actually never know when it's safe to write into memory (even in a single-threaded situation).  Thus it is racy in a single-threaded situation (even on a UP it's potentially racy) which is a pretty amazing feat.  Consider:

Problem is, that when sendfile() returns nothing has been transferred.
And in some NICs it will take a while to actually make a transfer.
And what you wrote below is exactly the same problem as exists with
splice/sendfile in particular and ->sendpage() in general.

Please also update your mailer to wrap strings into 80-or-so lines, it
is hard to answer into the middle of the paragraph.

-- 
	Evgeniy Polyakov
