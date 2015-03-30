From: Stas Sergeev <stsp@list.ru>
Subject: Re: [PATCH 4/6] of: add API for changing parameters of fixed link
Date: Mon, 30 Mar 2015 20:04:05 +0300
Message-ID: <55198205.2030808@list.ru>
References: <55155AFC.4050800@list.ru> <55155D35.1070703@list.ru> <CAGVrzcau0mUne8uXsTs_9=e4JtQt5w5L+hwtLmKo+UfjSEwC+w@mail.gmail.com> <5515803F.3020600@list.ru> <CAGVrzcaLfQcTAx8OR=sE=7FLrp0gGvfX8_YfxK_CU+x26JHymw@mail.gmail.com> <551587D1.5070408@list.ru> <5515904A.1060600@gmail.com> <55196011.7080502@list.ru> <CAGVrzcYam=zd+9DpKjhX8o+P_iksz+xOJWh0M45-GASMZbsBXA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev <netdev@vger.kernel.org>,
	Linux kernel <linux-kernel@vger.kernel.org>,
	Stas Sergeev <stsp@users.sourceforge.net>,
	Grant Likely <grant.likely@linaro.org>,
	Rob Herring <robh+dt@kernel.org>,
	"devicetree@vger.kernel.org" <devicetree@vger.kernel.org>,
	Thomas Petazzoni <thomas.petazzoni@free-electrons.com>,
	Andrew Lunn <andrew@lunn.ch>
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAGVrzcYam=zd+9DpKjhX8o+P_iksz+xOJWh0M45-GASMZbsBXA@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

30.03.2015 19:06, Florian Fainelli =D0=BF=D0=B8=D1=88=D0=B5=D1=82:
> So yes, it is a bug in the sense that it is not transparently handled=
,
> but at the same time, the PHY library has no way to know whether a
> fixed_link_update callback is being invoked since it is not poking
> into the fixed PHY driver.
Maybe then it would be better to have an API in fixed_phy.c itself
to change the state? No one will then care about the callback at all.
=46or example, currently in my new patch, when I receive the interrupt
about phy status change, I can't do anything: I can't change the state
or force the phylib to do a callback right now. So, instead of changing
the state upon interrupt, I need instead to ask HW the current state on
every poll, which is likely not effective in some regards. By having th=
e
API that would be solved, as well as the detached device problem.

>> @@ -304,6 +310,7 @@ struct mvneta_port {
>>         unsigned int link;
>>         unsigned int duplex;
>>         unsigned int speed;
>> +       int inband_status;
> Since you are essentially using this variable as a boolean to indicat=
e
> whether in-band status should be queried or not, maybe you should nam=
e
> that "needs_inband_status" or "wants_inband_status", inband_status
That's fine, will go for "use_inband_status:1" tomorrow.
