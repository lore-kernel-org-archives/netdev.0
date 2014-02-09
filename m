From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: REGRESSION f54b311142a92ea2e42598e347b84e1655caf8e3 tcp auto
 corking slows down iSCSI file system creation by factor of 70 [WAS: 4 TB
 VMFS creation takes 15 minutes vs 26 seconds]
Date: Sat, 08 Feb 2014 16:15:28 -0800
Message-ID: <1391904928.10160.118.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1391867404.10160.88.camel@edumazet-glaptop2.roam.corp.google.com>
	 <1391868816.10160.93.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20140208141905.GG20512@glanzmann.de>
	 <1391869805.10160.97.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20140208150001.GI20512@glanzmann.de>
	 <1391871986.10160.105.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20140208165732.GB22359@glanzmann.de>
	 <1391879318.10160.108.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20140208171531.GA23798@glanzmann.de>
	 <1391886759.10160.114.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20140208213608.GA24328@glanzmann.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: John Ogness <john.ogness@linutronix.de>,
	Eric Dumazet <edumazet@google.com>,
	"David S. Miller" <davem@davemloft.net>,
	"Nicholas A. Bellinger" <nab@linux-iscsi.org>,
	target-devel <target-devel@vger.kernel.org>,
	Linux Network Development <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>
To: Thomas Glanzmann <thomas@glanzmann.de>
Return-path: <target-devel-owner@vger.kernel.org>
In-Reply-To: <20140208213608.GA24328@glanzmann.de>
Sender: target-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, 2014-02-08 at 22:36 +0100, Thomas Glanzmann wrote:
> Hello Eric,
> 
> > I was simply thinking about something like :
> > (might need further changes, but I guess this should solve your case)
> 
> thank you for your patch. It did not apply on top of Linux tip, so I put
> in the changes manually and fixed up another call to tx_data that your
> forgot in your initial patch to make it apply.
> 
> I gave it another run, can you confirm that it now behaves better?
> 
> https://thomas.glanzmann.de/tmp/tcp_auto_corking_on_patched_tcp_more.pcap.bz2
> 
> And look at that roundtrip graph it is perfect. Also filesystem is now
> created in 3 seconds instead of 4.

Yes, this is much better : 2 frames per request/response, instead of 4.

13:32:04.665367 IP 10.101.0.12.43418 > 10.101.99.5.3260: Flags [P.], seq 384:432, ack 2529, win 514, options [nop,nop,TS val 1576981 ecr 4294913967], length 48
13:32:04.665483 IP 10.101.99.5.3260 > 10.101.0.12.43418: Flags [P.], seq 2529:3089, ack 432, win 235, options [nop,nop,TS val 4294913967 ecr 1576981], length 560
13:32:04.665642 IP 10.101.0.12.43418 > 10.101.99.5.3260: Flags [P.], seq 432:480, ack 3089, win 514, options [nop,nop,TS val 1576981 ecr 4294913967], length 48
13:32:04.665756 IP 10.101.99.5.3260 > 10.101.0.12.43418: Flags [P.], seq 3089:3649, ack 480, win 235, options [nop,nop,TS val 4294913967 ecr 1576981], length 560
13:32:04.665933 IP 10.101.0.12.43418 > 10.101.99.5.3260: Flags [P.], seq 480:528, ack 3649, win 514, options [nop,nop,TS val 1576981 ecr 4294913967], length 48
13:32:04.666046 IP 10.101.99.5.3260 > 10.101.0.12.43418: Flags [P.], seq 3649:4209, ack 528, win 235, options [nop,nop,TS val 4294913967 ecr 1576981], length 560
13:32:04.666214 IP 10.101.0.12.43418 > 10.101.99.5.3260: Flags [P.], seq 528:576, ack 4209, win 514, options [nop,nop,TS val 1576981 ecr 4294913967], length 48
13:32:04.666333 IP 10.101.99.5.3260 > 10.101.0.12.43418: Flags [P.], seq 4209:4769, ack 576, win 235, options [nop,nop,TS val 4294913967 ecr 1576981], length 560
13:32:04.666678 IP 10.101.0.12.43418 > 10.101.99.5.3260: Flags [P.], seq 576:624, ack 4769, win 514, options [nop,nop,TS val 1576981 ecr 4294913967], length 48
13:32:04.666790 IP 10.101.99.5.3260 > 10.101.0.12.43418: Flags [P.], seq 4769:5329, ack 624, win 235, options [nop,nop,TS val 4294913967 ecr 1576981], length 560
13:32:04.666983 IP 10.101.0.12.43418 > 10.101.99.5.3260: Flags [P.], seq 624:672, ack 5329, win 514, options [nop,nop,TS val 1576981 ecr 4294913967], length 48
13:32:04.667097 IP 10.101.99.5.3260 > 10.101.0.12.43418: Flags [P.], seq 5329:5889, ack 672, win 235, options [nop,nop,TS val 4294913967 ecr 1576981], length 560
13:32:04.667280 IP 10.101.0.12.43418 > 10.101.99.5.3260: Flags [P.], seq 672:720, ack 5889, win 514, options [nop,nop,TS val 1576981 ecr 4294913967], length 48
13:32:04.667324 IP 10.101.99.5.3260 > 10.101.0.12.43418: Flags [P.], seq 5889:6449, ack 720, win 235, options [nop,nop,TS val 4294913967 ecr 1576981], length 560
13:32:04.667500 IP 10.101.0.12.43418 > 10.101.99.5.3260: Flags [P.], seq 720:768, ack 6449, win 514, options [nop,nop,TS val 1576981 ecr 4294913967], length 48
13:32:04.667540 IP 10.101.99.5.3260 > 10.101.0.12.43418: Flags [P.], seq 6449:7009, ack 768, win 235, options [nop,nop,TS val 4294913967 ecr 1576981], length 560
