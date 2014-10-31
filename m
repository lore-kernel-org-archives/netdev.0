From: Fabio Estevam <festevam@gmail.com>
Subject: Re: suspend/resume broken on 3.18-rc2
Date: Fri, 31 Oct 2014 17:35:41 -0200
Message-ID: <CAOMZO5AeBSusV=xHgy8KJOb9po9WbS=DkaKXnS8iOpW8t-Y_Fw@mail.gmail.com>
References: <CAOMZO5C5znc2ZD5GoPKC7qQPoFGaJf47BoTMY0HQtEbW46d4dw@mail.gmail.com>
	<6278a77cdc594b3488b0ebc043f7d17b@BLUPR03MB373.namprd03.prod.outlook.com>
	<CAOMZO5C9tcL9K79rwWbYkYcpRMPkpvHS+v2kYyRpY4bt7h=Cgw@mail.gmail.com>
	<8bbe5cec19124e1cae128cc39d249148@BN1PR0301MB0628.namprd03.prod.outlook.com>
	<69f3cd5a2961445ebab0f2652ffa60bd@BLUPR03MB373.namprd03.prod.outlook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "Anson.Huang@freescale.com" <Anson.Huang@freescale.com>,
	"Frank.Li@freescale.com" <Frank.Li@freescale.com>,
	Russell King <linux@arm.linux.org.uk>,
	Shawn Guo <shawn.guo@linaro.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "fugang.duan@freescale.com" <fugang.duan@freescale.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f182.google.com ([209.85.217.182]:54392 "EHLO
	mail-lb0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758935AbaJaTfn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 31 Oct 2014 15:35:43 -0400
Received: by mail-lb0-f182.google.com with SMTP id f15so7437407lbj.13
        for <netdev@vger.kernel.org>; Fri, 31 Oct 2014 12:35:42 -0700 (PDT)
In-Reply-To: <69f3cd5a2961445ebab0f2652ffa60bd@BLUPR03MB373.namprd03.prod.outlook.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Andy,

On Thu, Oct 30, 2014 at 1:11 AM, fugang.duan@freescale.com
<fugang.duan@freescale.com> wrote:

> I tried it yesterday with FEC close, resume cannot back.
> I will try it again.

We have a regression in 3.18-rc1: if I use the imx6sx-sdb.dtb from
3.17.1 then I get:

root@freescale /$ echo enabled > /sys/class/tty/ttymxc0/power/wakeup
root@freescale /$ echo mem > /sys/power/state
[   13.883094] PM: Syncing filesystems ... done.
[   13.932184] Freezing user space processes ... (elapsed 0.003 seconds) done.
[   13.942928] Freezing remaining freezable tasks ... (elapsed 0.003 seconds) d.
[   14.014823] PM: suspend of devices complete after 54.572 msecs
[   14.020730] PM: suspend devices took 0.060 seconds
[   14.035241] PM: late suspend of devices complete after 9.545 msecs
[   14.050901] PM: noirq suspend of devices complete after 9.383 msecs
[   14.057626] Disabling non-boot CPUs ...
[   14.071514] PM: noirq resume of devices complete after 8.338 msecs
[   14.085645] PM: early resume of devices complete after 6.417 msecs
[   14.097720] fec 2188000.ethernet eth0: rcv is not +last
[   14.187491] PM: resume of devices complete after 95.494 msecs
[   14.199039] PM: resume devices took 0.100 seconds
[   14.203831] Restarting tasks ... done.
[   15.892318] fec 2188000.ethernet eth0: rcv is not +last
[   15.897688] fec 2188000.ethernet eth0: rcv is not +last
[   15.903010] fec 2188000.ethernet eth0: rcv is not +last
[   15.908326] fec 2188000.ethernet eth0: rcv is not +last
[   15.913635] fec 2188000.ethernet eth0: rcv is not +last
[   15.918945] fec 2188000.ethernet eth0: rcv is not +last

So fec suspend/resume is broken for mx6sx.

Please take a look at it.
