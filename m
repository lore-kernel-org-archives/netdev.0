From: Pasi Sjoholm <ptsjohol@cc.jyu.fi>
Subject: Re: ksoftirqd uses 99% CPU triggered by network traffic (maybe
 RLT-8139 related)
Date: Tue, 3 Aug 2004 15:32:15 +0300 (EEST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.44.0408031523220.32102-100000@silmu.st.jyu.fi>
References: <20040803003515.A29885@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=iso-8859-1
Content-Transfer-Encoding: quoted-printable
Cc: Robert Olsson <Robert.Olsson@data.slu.se>,
        H?ctor Mart?n <hector@marcansoft.com>,
        Linux-Kernel <linux-kernel@vger.kernel.org>, <akpm@osdl.org>,
        <netdev@oss.sgi.com>, <brad@brad-x.com>, <shemminger@osdl.org>
Return-path: <netdev-bounce@oss.sgi.com>
To: Francois Romieu <romieu@fr.zoreil.com>
In-Reply-To: <20040803003515.A29885@electric-eye.fr.zoreil.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, 3 Aug 2004, Francois Romieu wrote:

> I have made a few changes. Please enable the DEBUG option and set msglv=
l
> to its maximal value via ethtool. You may test the patches separately i=
f
> you find some time but the log once both r8139-10.patch and r8139-20.pa=
tch
> are applied would be enough.

The full logfiles can be downloaded from:

http://www.cc.jyu.fi/~ptsjohol/syslog1.gz=20
http://www.cc.jyu.fi/~ptsjohol/syslog2.gz=20

The first log file is with both patchs applied and the second one with on=
e=20
little change to rx8139_rx() to show if it even goes to through=20

"        while (netif_running(dev) && received < budget
               && (RTL_R8 (ChipCmd) & RxBufEmpty) =3D=3D 0) {"-section.

This was the change which I made.. so you can see in the second log file=20
that there won't be any of these messages after the driver has crashed.=20

/*              if (netif_msg_rx_status(tp))*/
        printk(KERN_DEBUG "%s:  rtl8139_rx() status %4.4x, size %4.4x,"
        " cur %4.4x.\n", dev->name, rx_status, rx_size, cur_rx);

For the first logfile the exact crash time is "13:02:22" and the for the=20
second one it is "14:54:49".

> If the log fills too fast, you may comment out any message which does
> not belong to rtl8139_rx().

I took out those "exiting with interrupt"-messages.

--
Pasi Sj=F6holm
