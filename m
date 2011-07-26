From: Anton Blanchard <anton@samba.org>
Subject: Re: [PATCH] net: Fix security_socket_sendmsg() bypass problem.
Date: Tue, 26 Jul 2011 19:55:57 +1000
Message-ID: <20110726195557.5abcf96d@kryten>
References: <4E2A7273.7030504@msgid.tls.msk.ru>
	<201107231939.FIF21882.QHOSOFtMFVLFOJ@I-love.SAKURA.ne.jp>
	<20110725222010.0b284042@kryten>
	<201107252215.GBG95887.OQVMFOOJLSFFHt@I-love.SAKURA.ne.jp>
	<4E2D8F4D.2000009@schaufler-ca.com>
	<201107260143.CGH18263.FOOSVMOQFJFLHt@I-love.SAKURA.ne.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: casey@schaufler-ca.com, mjt@tls.msk.ru, davem@davemloft.net,
	netdev@vger.kernel.org, linux-security-module@vger.kernel.org
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Return-path: <linux-security-module-owner@vger.kernel.org>
In-Reply-To: <201107260143.CGH18263.FOOSVMOQFJFLHt@I-love.SAKURA.ne.jp>
Sender: linux-security-module-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Hi,

> I fear it too. Unless many dozens (maybe some hundreds) of packets
> are sent by sendmmsg(), msg11504.html might show better performance
> than msg11510.html . But I don't have a machine to benchmark.

Not sure what happened to your email but the gains are evident at
just 2 packets.

I can help with testing - the commit included a microbenchmark for
the purposes of analysing its performance.

Anton

--

    net: Add sendmmsg socket system call
    
    This patch adds a multiple message send syscall and is the send
    version of the existing recvmmsg syscall. This is heavily
    based on the patch by Arnaldo that added recvmmsg.
    
    I wrote a microbenchmark to test the performance gains of using
    this new syscall:
    
    http://ozlabs.org/~anton/junkcode/sendmmsg_test.c
    
    The test was run on a ppc64 box with a 10 Gbit network card. The
    benchmark can send both UDP and RAW ethernet packets.
    
    64B UDP
    
    batch   pkts/sec
    1       804570
    2       872800 (+ 8 %)
    4       916556 (+14 %)
    8       939712 (+17 %)
    16      952688 (+18 %)
    32      956448 (+19 %)
    64      964800 (+20 %)
    
    64B raw socket
    
    batch   pkts/sec
    1       1201449
    2       1350028 (+12 %)
    4       1461416 (+22 %)
    8       1513080 (+26 %)
    16      1541216 (+28 %)
    32      1553440 (+29 %)
    64      1557888 (+30 %)
    
    We see a 20% improvement in throughput on UDP send and 30%
    on raw socket send.
    
    [ Add sparc syscall entries. -DaveM ]
