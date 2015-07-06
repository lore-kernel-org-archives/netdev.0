From: Sam Protsenko <semen.protsenko@linaro.org>
Subject: Re: problems with L2TP
Date: Mon, 6 Jul 2015 19:16:30 +0300
Message-ID: <CAKaJLVss0SMqf5hcBCdBuwa7+3_iBh527DW4+2Vb-RUPcb9Ffg@mail.gmail.com>
References: <CAKaJLVuu8vZ8fq32jqbC0MKRms9ikmT_d9KKA+hJ8kwpEYBhmA@mail.gmail.com>
	<20150703154155.GA19294@jackdaw>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: James Chapman <jchapman@katalix.com>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	Sumit Semwal <sumit.semwal@linaro.org>
To: Tom Parkin <tparkin@katalix.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20150703154155.GA19294@jackdaw>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Thanks for your reply, Tom!

> How is the tunnel/session being created on the server side?

My server is xl2tpd. If I understand correctly, session and tunnel are
being created in start_pppd() function, see [1].
Judging from xl2tpd logs (see [2]), start_pppd() function is executed,
in turn, from control_finish() (see [3]), when "c->msgtype" switch is
in "case ICCN:" (marked as "Incoming-Call-Connected" in log).
Tunnel ID and call ID for server side are generated in new_tunnel()
and new_call() functions, accordingly.
Tunnel ID and call ID for client side, I believe, are being received
from client in this code: [4] (see get_call() and get_tunnel()
functions calls).

> How are you deriving the session and tunnel IDs?

If you mean how they are generated at client side -- they are
basically random values (I'm using modified "mtpd" tool from Android):
 - session ID -- see "local_session" variable at [5]
 - tunnel ID -- see "local_tunnel" variable at [6].

I will try to play with tunnel_id/session_id values for both tunnel
and session sockets (in code from my first message) and see if it
helps.

Thanks!

References:

[1] https://github.com/xelerance/xl2tpd/blob/master/xl2tpd.c#L421
[2] xl2tpd log (with debug options enabled): http://pastebin.com/f0kfz37E
[3] https://github.com/xelerance/xl2tpd/blob/master/control.c#L998
[4] https://github.com/xelerance/xl2tpd/blob/master/network.c#L597
[5] https://android.googlesource.com/platform/external/mtpd/+/0269612ac00a0700997dda333faf0a3c33a388b8/l2tp.c#479
[6] https://android.googlesource.com/platform/external/mtpd/+/0269612ac00a0700997dda333faf0a3c33a388b8/l2tp.c#319
