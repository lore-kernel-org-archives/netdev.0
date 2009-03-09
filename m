From: John Heffner <johnwheffner@gmail.com>
Subject: Re: TCP rx window autotuning harmful at LAN context
Date: Mon, 9 Mar 2009 11:01:52 -0700
Message-ID: <1e41a3230903091101u536a3b3bv7f0dd9da6891781e@mail.gmail.com>
References: <20090309112521.GB37984@bts.sk>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-2
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: =?ISO-8859-2?Q?Marian_=CFurkovi=E8?= <md@bts.sk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from el-out-1112.google.com ([209.85.162.183]:9410 "EHLO
	el-out-1112.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751396AbZCISJY convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Mar 2009 14:09:24 -0400
Received: by el-out-1112.google.com with SMTP id b25so986545elf.1
        for <netdev@vger.kernel.org>; Mon, 09 Mar 2009 11:09:21 -0700 (PDT)
In-Reply-To: <20090309112521.GB37984@bts.sk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Mar 9, 2009 at 4:25 AM, Marian =CFurkovi=E8 <md@bts.sk> wrote:
> =A0 As rx window autotuning is enabled in all recent kernels and with=
 1 GB
> of RAM the maximum tcp_rmem becomes 4 MB, this problem is spreading r=
apidly
> and we believe it needs urgent attention. As demontrated above, such =
huge
> rx window (which is at least 100*BDP of the example above) does not d=
eliver
> any performance gain but instead it seriously harms other hosts and/o=
r
> applications. It should also be noted, that host with autotuning enab=
led
> steals an unfair share of the total available bandwidth, which might =
look
> like a "better" performing TCP stack at first sight - however such be=
haviour
> is not appropriate (RFC2914, section 3.2).

It's well known that "standard" TCP fills all available drop-tail
buffers, and that this behavior is not desirable.

The situation you describe is exactly what congestion control (the
topic of RFC2914) should fix.  It is not the role of receive window
(flow control).  It is really the sender's job to detect and react to
this, not the receiver's.  (We have had this discussion before on
netdev.)  There are a number of delay-based congestion control
algorithms that have been implemented and are available in Linux, but
all have proved problematic in many cases, and has not been suitable
to enable widely.  This is still an active research topic.

Another option in LANs is to enable AQM.  In Linux, you can configure
the bottleneck interface qdisc to be any of a number of RED-like early
droppers.  Most commercial routers also offer the ability to configure
AQM on interfaces, though most do not enable by default.

  -John
