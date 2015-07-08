From: James Chapman <jchapman@katalix.com>
Subject: Re: problems with L2TP
Date: Wed, 08 Jul 2015 11:02:27 +0100
Message-ID: <559CF533.2060204@katalix.com>
References: <CAKaJLVuu8vZ8fq32jqbC0MKRms9ikmT_d9KKA+hJ8kwpEYBhmA@mail.gmail.com>	<20150703154155.GA19294@jackdaw> <CAKaJLVss0SMqf5hcBCdBuwa7+3_iBh527DW4+2Vb-RUPcb9Ffg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: Tom Parkin <tparkin@katalix.com>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Sumit Semwal <sumit.semwal@linaro.org>
To: Sam Protsenko <semen.protsenko@linaro.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from katalix.com ([82.103.140.233]:58264 "EHLO mail.katalix.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758184AbbGHKKd (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 8 Jul 2015 06:10:33 -0400
In-Reply-To: <CAKaJLVss0SMqf5hcBCdBuwa7+3_iBh527DW4+2Vb-RUPcb9Ffg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 06/07/15 17:16, Sam Protsenko wrote:
> Thanks for your reply, Tom!
>
>> How are you deriving the session and tunnel IDs?
> If you mean how they are generated at client side -- they are
> basically random values (I'm using modified "mtpd" tool from Android):
>  - session ID -- see "local_session" variable at [5]
>  - tunnel ID -- see "local_tunnel" variable at [6].
>
> I will try to play with tunnel_id/session_id values for both tunnel
> and session sockets (in code from my first message) and see if it
> helps.
>
> Thanks!
>
> References:
>
> [1] https://github.com/xelerance/xl2tpd/blob/master/xl2tpd.c#L421
> [2] xl2tpd log (with debug options enabled): http://pastebin.com/f0kfz37E
> [3] https://github.com/xelerance/xl2tpd/blob/master/control.c#L998
> [4] https://github.com/xelerance/xl2tpd/blob/master/network.c#L597
> [5] https://android.googlesource.com/platform/external/mtpd/+/0269612ac00a0700997dda333faf0a3c33a388b8/l2tp.c#479
> [6] https://android.googlesource.com/platform/external/mtpd/+/0269612ac00a0700997dda333faf0a3c33a388b8/l2tp.c#319

Tom and I discussed this and we're not clear what you are running. Have
you changed create_pppox() in mtpd with the code fragment from your
original mail? Are you sure that your modified mtpd gets the correct
local/remote tunnel-id and session-id to make its connect() call?

Use l2tp_debugfs to get information from debugfs about the l2tp state in
the kernel. Check that this matches what your app has configured.

Several open source projects use the l2tp driver so these might be
useful as a reference:

[a] pppd's pppol2tp plugin - http://download.samba.org/pub/ppp/
[b] accel-ppp - http://accel-ppp.org

-- 
James Chapman
Katalix Systems Ltd
http://www.katalix.com
Catalysts for your Embedded Linux software development
