From: "kus Kusche Klaus" <kus@keba.com>
Subject: RE: My vote against eepro* removal
Date: Fri, 20 Jan 2006 11:19:20 +0100
Message-ID: <AAD6DA242BC63C488511C611BD51F367323325@MAILIT.keba.co.at>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "John Ronciak" <john.ronciak@gmail.com>,
	"Adrian Bunk" <bunk@stusta.de>,
	"Lee Revell" <rlrevell@joe-job.com>,
	<linux-kernel@vger.kernel.org>, <john.ronciak@intel.com>,
	<ganesh.venkatesan@intel.com>, <jesse.brandeburg@intel.com>,
	<netdev@vger.kernel.org>, "Steven Rostedt" <rostedt@goodmis.org>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1750786AbWATKT1@vger.kernel.org>
Content-class: urn:content-classes:message
To: "Evgeniy Polyakov" <johnpol@2ka.mipt.ru>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Evgeniy Polyakov
> Each MDIO read can take upto 2 msecs (!) and at least 20 
> usecs in e100,
> and this runs in timer handler.
> Concider attaching (only compile tested) patch which moves 
> e100 watchdog
> into workqueue.

Hmmm, I don't think moving it around is worth the trouble
(nevertheless, I will test later if I find time).

For a full preemption kernel, both timer code and workqueue code
are executed in a thread of their own. If I know that there is a
500 us piece of code in either of them, I have to adjust the prio
of the corresponding thread (and all others) accordingly anyway.

For a non-full preemption kernel, your patch moves the 500 us 
piece of code from kernel to thread context, so it really 
improves things. But is 500 us something to worry about in a
non-full preemption kernel?

-- 
Klaus Kusche                 (Software Development - Control Systems)
KEBA AG             Gewerbepark Urfahr, A-4041 Linz, Austria (Europe)
Tel: +43 / 732 / 7090-3120                 Fax: +43 / 732 / 7090-6301
E-Mail: kus@keba.com                                WWW: www.keba.com
 
