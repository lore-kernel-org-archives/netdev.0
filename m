From: Xianghua Xiao <xiaoxianghua@gmail.com>
Subject: powerpc gianfar driver does not work well when PREEMPT/PREEMPT_RT is
	enabled
Date: Tue, 27 Apr 2010 16:01:07 -0500
Message-ID: <y2oe6bf505b1004271401wba47dd8h14d06d06b1c03f88@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
To: netdev@vger.kernel.org, linux-rt-users@vger.kernel.org
Return-path: <linux-rt-users-owner@vger.kernel.org>
Sender: linux-rt-users-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

I posted this to linuxppc list originally and hope someone here with
NAPI/COALESCE/RT experience can comment on...
-----------------------------
I'm trying to get 834x/TSEC gianfar.c working with 2.6.33/RT.

when PREEMPT is disabled gianfar driver worked well.

if PREEMPT is enabled, especially when PREEMPT_RT is enabled,
network(gianfar) will be disconnected in about 2-3 minutes under
iperf, if NFS  is used then the whole system will hang after a while
when NFS is accessed.

In an older version (2.6.18-rt) where NAPI is disabled, gianfar
performed well under PREEMPT_RT, in the new version of gianfar, NAPI
is enforced(the code is there by default and it's hard to disable NAPI
in the code now), also TX COALESCE is enabled while RX COALESCE is
disabled. It seems to me NAPI is now by default for Rx and COALESCE is
by default for Tx.

Both NAPI/COALESCE may have negative effects for real time systems,
where latency is more important than throughput. Unfortunately it's
hard to disable either of them now after some experiments.

Is there anyone here using gianfar with PREEMPT_RT? Do I have to port
an older version gianfar to get rid of NAPI at least?

Thanks,
Xianghua
