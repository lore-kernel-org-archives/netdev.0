From: Thomas Glanzmann <thomas@glanzmann.de>
Subject: Re: [PATCH] This extends tx_data and and iscsit_do_tx_data with the
 additional parameter flags and avoids sending multiple TCP packets in
 iscsit_fe_sendpage_sg
Date: Mon, 10 Feb 2014 21:56:34 +0100
Message-ID: <20140210205634.GC19621@glanzmann.de>
References: <20140208150001.GI20512@glanzmann.de>
 <1391871986.10160.105.camel@edumazet-glaptop2.roam.corp.google.com>
 <20140208165732.GB22359@glanzmann.de>
 <1391879318.10160.108.camel@edumazet-glaptop2.roam.corp.google.com>
 <20140208171531.GA23798@glanzmann.de>
 <1391886759.10160.114.camel@edumazet-glaptop2.roam.corp.google.com>
 <20140209074027.GA8105@glanzmann.de>
 <20140209074227.GA8219@glanzmann.de>
 <1391949039.10160.129.camel@edumazet-glaptop2.roam.corp.google.com>
 <1392058718.17867.8.camel@haakon3.risingtidesystems.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	John Ogness <john.ogness@linutronix.de>,
	Eric Dumazet <edumazet@google.com>,
	"David S. Miller" <davem@davemloft.net>,
	target-devel <target-devel@vger.kernel.org>,
	Linux Network Development <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>
To: "Nicholas A. Bellinger" <nab@linux-iscsi.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1392058718.17867.8.camel@haakon3.risingtidesystems.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello Nab,

> This looks correct to me.  Thomas, once your able to confirm please
> include your 'Tested-by' and I'll include for the next -rc3 PULL
> request.

Eric is currently reviewing our latest iteration with MSG_MORE for
kernel_sendmsg and MSG_MORE | MSG_SENDPAGE_NOTLAST for sendpage. However
with the last iteration we had again a high RTT for some packets. But
than Eric let me tune net.ipv4.tcp_min_tso_segs to 8 and the RTT went
down to what it used before auto corking was enabled. At least almost.

I'm having a steep learning curve but Eric hopefully knows how to get
this back in check. Nevertheless the regression I saw are history
because I saw that Eric has submitted the patch to David S. Miller which
fixes the two bugs that killed the iSCSI performance when tcp auto
corking was on. So currently we're just optimizing to get the last 20%
or so out of it. Quite interesting. Especially how much bandwidth can be
saved by coalescing packets.

Cheers,
        Thomas
