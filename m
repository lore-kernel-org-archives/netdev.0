From: Jonathan Nieder <jrnieder@gmail.com>
Subject: Re: [PATCH 1/2] r8169: Rx FIFO overflow fixes.
Date: Sun, 19 Feb 2012 20:37:40 -0600
Message-ID: <20120220023740.GA4433@burratino>
References: <20111127092808.GE21635@elie.hsd1.il.comcast.net>
 <4ED2A573.1020807@wolke7.net>
 <20111127231147.GA1784@electric-eye.fr.zoreil.com>
 <D95C09DB1A7E493E89FE5A0B3879CEB0@realtek.com.tw>
 <20111129105440.GA2410@electric-eye.fr.zoreil.com>
 <4ED538EC.4010509@wolke7.net>
 <20111201102000.GA14013@electric-eye.fr.zoreil.com>
 <4ED7E6AB.6050308@wolke7.net>
 <20111201222612.GA27998@electric-eye.fr.zoreil.com>
 <20111205063045.GA3103@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: booster@wolke7.net, hayeswang <hayeswang@realtek.com>,
	'Eric Dumazet' <eric.dumazet@gmail.com>,
	netdev@vger.kernel.org, 'nic_swsd' <nic_swsd@realtek.com>,
	linux-kernel@vger.kernel.org,
	'Armin Kazmi' <armin.kazmi@tu-dortmund.de>,
	Lucas Stach <dev@lynxeye.de>
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20111205063045.GA3103@electric-eye.fr.zoreil.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Fran=C3=A7ois, Gerd, et al,

=46rancois Romieu wrote:

> Realtek has specified that the post 8168c gigabit chips and the post
> 8105e fast ethernet chips recover automatically from a Rx FIFO overfl=
ow.
> The driver does not need to clear the RxFIFOOver bit of IntrStatus an=
d
> it should rather avoid messing it.
>
> The implementation deserves some explanation:

I would be interested in some subset of these fixes for 3.0.y and
2.6.32.y.  In particular:

> 1. events outside of the intr_event bit mask are now ignored.
>    a no-processing policy for the events that either should not be th=
ere
>    or should be ignored.

This seems like a valuable and unrisky change.

> 2. RxFIFOOver was already ignored in rtl_cfg_infos[RTL_CFG_1] for the
>    whole 8168 line of chips with two exceptions:
>    - RTL_GIGA_MAC_VER_22 since b5ba6d12bdac21bc0620a5089e0f24e362645e=
fd
>      ("use RxFIFO overflow workaround for 8168c chipset.").
>      This one should now be correctly handled.

This seems useful if we can test it.

[...]
> 3. RxFIFOOver is masked for post 8105e 810x chips, namely the sole 81=
05e
>    (RTL_GIGA_MAC_VER_30) itself.

This also seems useful if we can test it.

What do you think?  Is there any way I can help?  (E.g., given rough
guidelines about what approach is acceptable I'd be happy to work with
Gerd to produce a tested patch that does (1) and (2) but not (3) for
3.0.y.)

Thanks for your hard work,
Jonathan
