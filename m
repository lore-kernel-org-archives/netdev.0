From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: ssh connections hanging on 4.1rc7
Date: Thu, 11 Jun 2015 11:24:21 -0700
Message-ID: <1434047061.27504.40.camel@edumazet-glaptop2.roam.corp.google.com>
References: <20150611174618.GA30268@codemonkey.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Dave Jones <davej@codemonkey.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f193.google.com ([209.85.223.193]:34418 "EHLO
	mail-ie0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752868AbbFKSYZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Jun 2015 14:24:25 -0400
Received: by iebtr6 with SMTP id tr6so4063866ieb.1
        for <netdev@vger.kernel.org>; Thu, 11 Jun 2015 11:24:24 -0700 (PDT)
In-Reply-To: <20150611174618.GA30268@codemonkey.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2015-06-11 at 13:46 -0400, Dave Jones wrote:
> Just hit this weird problem where I can ssh into a machine once,
> then after logging out, subsequent ssh connections hang.
> 
> The client side looks like..
> 
> 13:39:06.307781 IP wopr.kernelslacker.org.43982 >
> gelk.kernelslacker.org.ssh: Flags [S], seq 319726787, win 29200,
> options [mss 1460,sackOK,TS val 77408596 ecr 0,nop,wscale 7], length 0
> 13:39:06.308580 IP wopr.kernelslacker.org.43982 >
> gelk.kernelslacker.org.ssh: Flags [P.], seq 319726788:319726820, ack
> 1404309216, win 229, options [nop,nop,TS val 77408597 ecr 19368680],
> length 32
> 13:39:06.332551 IP wopr.kernelslacker.org.43982 >
> gelk.kernelslacker.org.ssh: Flags [P.], seq 32:2000, ack 33, win 229,
> options [nop,nop,TS val 77408621 ecr 19368703], length 1968
> 13:39:06.370042 IP wopr.kernelslacker.org.43982 >
> gelk.kernelslacker.org.ssh: Flags [P.], seq 2048:2064, ack 1265, win
> 258, options [nop,nop,TS val 77408658 ecr 19368734], length 16
> 13:39:06.449511 IP wopr.kernelslacker.org.43982 >
> gelk.kernelslacker.org.ssh: Flags [.], ack 1309, win 258, options
> [nop,nop,TS val 77408738 ecr 19368782], length 0
> 
> until I ctrl-c which then sends the FIN
> 
> 13:40:06.914614 IP wopr.kernelslacker.org.43982 >
> gelk.kernelslacker.org.ssh: Flags [F.], seq 2108, ack 1309, win 258,
> options [nop,nop,TS val 77469203 ecr 19368782], length 0
> 
> 
> On the sshd side..
> 
> 
> 13:39:06.311005 IP wopr.kernelslacker.org.43982 >
> gelk.kernelslacker.org.ssh: Flags [S], seq 319726787, win 29200,
> options [mss 1460,sackOK,TS val 77408596 ecr 0,nop,wscale 7], length 0
> 13:39:06.311254 IP wopr.kernelslacker.org.43982 >
> gelk.kernelslacker.org.ssh: Flags [.], ack 1404309216, win 229,
> options [nop,nop,TS val 77408596 ecr 19368680], length 0
> 13:39:06.311778 IP wopr.kernelslacker.org.43982 >
> gelk.kernelslacker.org.ssh: Flags [P.], seq 0:32, ack 1, win 229,
> options [nop,nop,TS val 77408597 ecr 19368680], length 32
> 13:39:06.334546 IP wopr.kernelslacker.org.43982 >
> gelk.kernelslacker.org.ssh: Flags [.], ack 33, win 229, options
> [nop,nop,TS val 77408619 ecr 19368703], length 0
> 13:39:06.335779 IP wopr.kernelslacker.org.43982 >
> gelk.kernelslacker.org.ssh: Flags [P.], seq 32:2000, ack 33, win 229,
> options [nop,nop,TS val 77408621 ecr 19368703], length 1968
> 13:39:06.347867 IP wopr.kernelslacker.org.43982 >
> gelk.kernelslacker.org.ssh: Flags [P.], seq 2000:2048, ack 985, win
> 243, options [nop,nop,TS val 77408633 ecr 19368711], length 48
> 13:39:06.373232 IP wopr.kernelslacker.org.43982 >
> gelk.kernelslacker.org.ssh: Flags [P.], seq 2048:2064, ack 1265, win
> 258, options [nop,nop,TS val 77408658 ecr 19368734], length 16
> 13:39:06.413173 IP wopr.kernelslacker.org.43982 >
> gelk.kernelslacker.org.ssh: Flags [P.], seq 2064:2108, ack 1265, win
> 258, options [nop,nop,TS val 77408698 ecr 19368782], length 44
> 13:39:06.452714 IP wopr.kernelslacker.org.43982 >
> gelk.kernelslacker.org.ssh: Flags [.], ack 1309, win 258, options
> [nop,nop,TS val 77408738 ecr 19368782], length 0
> 
> until the ctrl-c...
> 
> 13:40:06.917807 IP wopr.kernelslacker.org.43982 >
> gelk.kernelslacker.org.ssh: Flags [F.], seq 2108, ack 1309, win 258,
> options [nop,nop,TS val 77469203 ecr 19368782], length 0
> 13:40:06.921241 IP wopr.kernelslacker.org.43982 >
> gelk.kernelslacker.org.ssh: Flags [.], ack 1310, win 258, options
> [nop,nop,TS val 77469206 ecr 19429290], length 0
> 
> 
> Is there anything out of the ordinary here that I'm missing, or is
> this perhaps
> an sshd bug ?
> 
> The odd thing is that it seems repeatable with every host I try to ssh
> to.
> 
> 4.1rc7 on both sides, haven't tried reproducing with different kernels
> yet.

Your tcpdumps look one way only.

Could this be some routing or mtu problem ?
