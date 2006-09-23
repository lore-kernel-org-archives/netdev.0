From: "Arnaldo Carvalho de Melo" <arnaldo.melo@gmail.com>
Subject: Re: softmac mtu
Date: Sat, 23 Sep 2006 19:08:29 -0300
Message-ID: <39e6f6c70609231508n5bf99777gad80be51d1d3f20@mail.gmail.com>
References: <ef3s4u$or5$3@sea.gmane.org> <4515A9BF.90709@lwfinger.net>
	 <20060923.144757.78710420.davem@davemloft.net>
	 <4515AE54.4040403@lwfinger.net>
	 <39e6f6c70609231504qd442c59hebf152df00a7af0c@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	"David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wx-out-0506.google.com ([66.249.82.227]:1479 "EHLO
	wx-out-0506.google.com") by vger.kernel.org with ESMTP
	id S1750782AbWIWWIa (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 23 Sep 2006 18:08:30 -0400
Received: by wx-out-0506.google.com with SMTP id s14so1400055wxc
        for <netdev@vger.kernel.org>; Sat, 23 Sep 2006 15:08:29 -0700 (PDT)
To: "Larry Finger" <Larry.Finger@lwfinger.net>
In-Reply-To: <39e6f6c70609231504qd442c59hebf152df00a7af0c@mail.gmail.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 9/23/06, Arnaldo Carvalho de Melo <arnaldo.melo@gmail.com> wrote:
> On 9/23/06, Larry Finger <Larry.Finger@lwfinger.net> wrote:
> > David Miller wrote:
> > > From: Larry Finger <Larry.Finger@lwfinger.net>
> > > Date: Sat, 23 Sep 2006 16:40:15 -0500
> > >
> > >> The maximum value for MTU is set in include/linux/if_ether.h for all
> > >> ethernet-type communications, not in softmac or ieee80211. I doubt
> > >> that one could easily change the number. It may be that the 802.11
> > >> standard allows bigger frames, but it looks to me as if Linux does
> > >> not.
> > >
> > >
> > > Not correct.  Linux is perfectly fine with setting 9000 byte MTU on
> > > ethernet devices that support it, and in fact just about every
> > > gigabit ethernet driver supports it.
> > >
> > > That macro you see in if_ether.h is just the value of the base MTU
> > > limit, so larger MTU settings are easily allowable on a per-device
> > > basis.
> >
> > Where/how does the device allow it? When I tried 'ifconfig eth0 mtu 2000' on my VIA Technologies,
> > Inc. VT6102 [Rhine-II] wired controller, I got a 'SIOCSIFMTU: Invalid argument' message, which is
> > the same message I get on my BCM4306 wireless card.
>
> David didn't said 1500 all the way to 9000, he said that some drivers
> support 9000, some don't, lemme check for ya which one does...


drivers/net/8139cp.c: max is 4096
drivers/net/acenic.c: 9000

just do a:

vi $(find drivers/net | xargs grep -l change_mtu)

and check the rest :-)

- Arnaldo
