From: Thomas Glanzmann <thomas@glanzmann.de>
Subject: Re: [PATCH] This extends tx_data and and iscsit_do_tx_data with the
 additional parameter flags and avoids sending multiple TCP packets in
 iscsit_fe_sendpage_sg
Date: Sun, 9 Feb 2014 16:07:49 +0100
Message-ID: <20140209150749.GE11169@glanzmann.de>
References: <1391869805.10160.97.camel@edumazet-glaptop2.roam.corp.google.com>
 <20140208150001.GI20512@glanzmann.de>
 <1391871986.10160.105.camel@edumazet-glaptop2.roam.corp.google.com>
 <20140208165732.GB22359@glanzmann.de>
 <1391879318.10160.108.camel@edumazet-glaptop2.roam.corp.google.com>
 <20140208171531.GA23798@glanzmann.de>
 <1391886759.10160.114.camel@edumazet-glaptop2.roam.corp.google.com>
 <20140209074027.GA8105@glanzmann.de>
 <20140209074227.GA8219@glanzmann.de>
 <1391949039.10160.129.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: John Ogness <john.ogness@linutronix.de>,
	Eric Dumazet <edumazet@google.com>,
	"David S. Miller" <davem@davemloft.net>,
	"Nicholas A. Bellinger" <nab@linux-iscsi.org>,
	target-devel <target-devel@vger.kernel.org>,
	Linux Network Development <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <target-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1391949039.10160.129.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: target-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello Eric,

> 1) Use your own identity as the sender, not impersonate me.
> ( thats standard convention )

sorry about that, will not happen ever again.

> 2) Put following line as first line of the mail
> ( Documentation/SubmittingPatches lines ~565)

> From: Eric Dumazet <edumazet@google.com>

> Then I'll add my :
> Signed-off-by: Eric Dumazet <edumazet@google.com>

I see. Thank you for the awareness training. I read SubmittingPatches
completly.

> Anyway, patch is not yet complete : We also want to set
> MSG_MORE/MSG_SENDPAGE_NOTLAST for all pages but last one in a sg list.

I see.

> This will fix suboptimal traffic :

> 13:32:04.976923 IP 10.101.99.5.3260 > 10.101.0.12.43418: Flags [.], seq 289953:292849, ack 45792, win 795, options [nop,nop,TS val 4294914045 ecr 1577012], length 2896
> 13:32:04.976936 IP 10.101.99.5.3260 > 10.101.0.12.43418: Flags [.], seq 292849:295745, ack 45792, win 795, options [nop,nop,TS val 4294914045 ecr 1577012], length 2896
> 13:32:04.976944 IP 10.101.99.5.3260 > 10.101.0.12.43418: Flags [P.], seq 295745:298193, ack 45792, win 795, options [nop,nop,TS val 4294914045 ecr 1577012], length 2448
> 13:32:04.976952 IP 10.101.99.5.3260 > 10.101.0.12.43418: Flags [.], seq 298193:301089, ack 45792, win 795, options [nop,nop,TS val 4294914045 ecr 1577012], length 2896
> 13:32:04.976960 IP 10.101.99.5.3260 > 10.101.0.12.43418: Flags [.], seq 301089:303985, ack 45792, win 795, options [nop,nop,TS val 4294914045 ecr 1577012], length 2896
> 13:32:04.976998 IP 10.101.99.5.3260 > 10.101.0.12.43418: Flags [P.], seq 303985:306385, ack 45792, win 795, options [nop,nop,TS val 4294914045 ecr 1577012], length 2400

What is suboptimal about the traffic, could they all go in one packet?
Since my MTU is 1500 I assume that the network card will split this then
in MTU sized packets, is that correct? Should I repeat the test with MTU
9000 as well?

> Please try following updated patch, thanks!

This time it took 2 seconds instead of 4 seconds (3.12) to create the
filesystem. Find pcap here:

https://thomas.glanzmann.de/tmp/tcp_auto_corking_on_patched_tcp_more_notlast.pcap.bz2

> Once tested, we'll submit it formally.

Let me know if you want to submit or I should. If I should do it I would
split it up in two patches, one for the interface change and one for the
packet submission logic. Btw. your last patches did not apply for me
because I cut & pasted them from e-mail instead of saving it in an
editor this one. So your patch was fine but they way I tried to apply it
was flawed.

Cheers,
        Thomas
