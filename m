From: Paul Bolle <pebolle@tiscali.nl>
Subject: Re: gigaset: memory leak in gigaset_initcshw
Date: Thu, 04 Feb 2016 14:46:44 +0100
Message-ID: <1454593604.14366.65.camel@tiscali.nl>
References: <CACT4Y+Y+P7-pM0D4HTz4ZF6i+Rya22eOkPdnrv_OmDCMB7eQtg@mail.gmail.com>
	 <1454516189.14366.8.camel@tiscali.nl>
	 <1454526665.14366.22.camel@tiscali.nl>
	 <CACT4Y+aDi8L_GELzVv7QM8YdtMD7q-wH4uO7LhioeSvaEU5PJg@mail.gmail.com>
	 <1454591389.14366.49.camel@tiscali.nl>
	 <CACT4Y+aXo83LjyOjVG2ihyR94kex-z+=Of+x8o4i+0q8964-1g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Karsten Keil <isdn@linux-pingi.de>,
	"David S. Miller" <davem@davemloft.net>,
	gigaset307x-common@lists.sourceforge.net,
	netdev <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>,
	syzkaller <syzkaller@googlegroups.com>,
	Kostya Serebryany <kcc@google.com>,
	Alexander Potapenko <glider@google.com>,
	Sasha Levin <sasha.levin@oracle.com>
To: Dmitry Vyukov <dvyukov@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from lb1-smtp-cloud2.xs4all.net ([194.109.24.21]:37335 "EHLO
	lb1-smtp-cloud2.xs4all.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S965233AbcBDNqs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Feb 2016 08:46:48 -0500
In-Reply-To: <CACT4Y+aXo83LjyOjVG2ihyR94kex-z+=Of+x8o4i+0q8964-1g@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dmitry,

On do, 2016-02-04 at 14:15 +0100, Dmitry Vyukov wrote:
> On Thu, Feb 4, 2016 at 2:09 PM, Paul Bolle <pebolle@tiscali.nl> wrote:
> > What are you seeing here?
> 
> I see that active_objs is slowly, constantly growing.
> 
> I've attached my config file, please try with it. You mentioned that
> "16 is N_GIGASET_M101, while 7 is N_6PACK", probably one of these ttys
> is not enabled in your config,

Both are. (A 6pack module is loaded when I run the reproducer. I have no
idea what 6pack is good for. ser_gigaset is familiar, to me.)

>  and so the reproducer is not doing
> anything useful.

I actually wonder whether N_6PACK is relevant. Do you also see this
issue with another line discipline in the second TIOCSETD ioctl? 

Maybe it even triggers with two totally different line disciplines in
both calls? A (slightly edited) copy of tty.h is pasted below. It lists
the useful values for the TIOCSETD ioctl.

Would you mind testing a few combinations?

Thanks,


Paul Bolle

/* line disciplines */
#define N_TTY		0
#define N_SLIP		1
#define N_MOUSE		2
#define N_PPP		3
				/* 4 is obsolete */
#define N_AX25		5
#define N_X25		6	/* X.25 async */
#define N_6PACK		7
				/* 8 is obsolete */
#define N_R3964		9	/* Simatic R3964 */
				/* 10 is obsolete */
#define N_IRDA		11	/* Linux IrDa - http://irda.sourceforge.net/ */
				/* 12 is obsolete */
#define N_HDLC		13	/* synchronous HDLC */
#define N_SYNC_PPP	14	/* synchronous PPP */
#define N_HCI		15	/* Bluetooth HCI UART */
#define N_GIGASET_M101	16	/* Siemens Gigaset M101 serial DECT adapter */
#define N_SLCAN		17	/* Serial / USB serial CAN Adaptors */
#define N_PPS		18	/* Pulse per Second */
#define N_V253		19	/* Codec control over voice modem */
#define N_CAIF		20      /* CAIF protocol for talking to modems */
#define N_GSM0710	21	/* GSM 0710 Mux */
#define N_TI_WL		22	/* for TI's WL BT, FM, GPS combo chips */
#define N_TRACESINK	23	/* Trace data routing for MIPI P1149.7 */
#define N_TRACEROUTER	24	/* Trace data routing for MIPI P1149.7 */
#define N_NCI		25	/* NFC NCI UART */
