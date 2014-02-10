From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] This extends tx_data and and iscsit_do_tx_data with the
 additional parameter flags and avoids sending multiple TCP packets in
 iscsit_fe_sendpage_sg
Date: Mon, 10 Feb 2014 13:01:40 -0800
Message-ID: <1392066100.6615.55.camel@edumazet-glaptop2.roam.corp.google.com>
References: <20140208150001.GI20512@glanzmann.de>
	 <1391871986.10160.105.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20140208165732.GB22359@glanzmann.de>
	 <1391879318.10160.108.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20140208171531.GA23798@glanzmann.de>
	 <1391886759.10160.114.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20140209074027.GA8105@glanzmann.de> <20140209074227.GA8219@glanzmann.de>
	 <1391949039.10160.129.camel@edumazet-glaptop2.roam.corp.google.com>
	 <1392058718.17867.8.camel@haakon3.risingtidesystems.com>
	 <20140210205634.GC19621@glanzmann.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "Nicholas A. Bellinger" <nab@linux-iscsi.org>,
	John Ogness <john.ogness@linutronix.de>,
	Eric Dumazet <edumazet@google.com>,
	"David S. Miller" <davem@davemloft.net>,
	target-devel <target-devel@vger.kernel.org>,
	Linux Network Development <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>
To: Thomas Glanzmann <thomas@glanzmann.de>
Return-path: <target-devel-owner@vger.kernel.org>
In-Reply-To: <20140210205634.GC19621@glanzmann.de>
Sender: target-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2014-02-10 at 21:56 +0100, Thomas Glanzmann wrote:
> Hello Nab,
> 
> > This looks correct to me.  Thomas, once your able to confirm please
> > include your 'Tested-by' and I'll include for the next -rc3 PULL
> > request.
> 
> Eric is currently reviewing our latest iteration with MSG_MORE for
> kernel_sendmsg and MSG_MORE | MSG_SENDPAGE_NOTLAST for sendpage. However
> with the last iteration we had again a high RTT for some packets. But
> than Eric let me tune net.ipv4.tcp_min_tso_segs to 8 and the RTT went
> down to what it used before auto corking was enabled. At least almost.
> 

Hmm.. I was not aware of high RTT for some packets.

Can you spot this on the pcap you provided ?


> I'm having a steep learning curve but Eric hopefully knows how to get
> this back in check. Nevertheless the regression I saw are history
> because I saw that Eric has submitted the patch to David S. Miller which
> fixes the two bugs that killed the iSCSI performance when tcp auto
> corking was on. So currently we're just optimizing to get the last 20%
> or so out of it. Quite interesting. Especially how much bandwidth can be
> saved by coalescing packets.

It depends on the ratio payload/headers.

The beginning of your pcap show a lot of 512 bytes requests, so for this
kind of requests, the gain is huge (maybe 50%), but for 32K or 64K
request, gain would be marginal.
