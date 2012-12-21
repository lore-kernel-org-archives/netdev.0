From: Yury Stankevich <urykhy@gmail.com>
Subject: Re: [PATCH] pkt_sched: act_xt support new Xtables interface
Date: Fri, 21 Dec 2012 17:13:04 +0400
Message-ID: <50D46060.2070308@gmail.com>
References: <50C4821D.5090206@gmail.com> <50C9B4BB.9060609@mojatatu.com> <50CCE961.5050204@mojatatu.com> <alpine.LNX.2.01.1212160002330.4901@nerf07.vanv.qr> <CAASe=fQT2pVOK0uctdaKL+aOrF8nYeTMfoF15kmd-rC02+7Vnw@mail.gmail.com> <50CDFB6A.3090806@mojatatu.com> <50CE1A04.1000405@mojatatu.com> <alpine.LNX.2.01.1212162003340.27614@nerf07.vanv.qr> <50CE3203.9080007@mojatatu.com> <50CF1071.1050405@mojatatu.com> <CAASe=fRuJdtisEvp7uo=PHwN3nKHqsYDW4Om1gk2MK-vyNvBrA@mail.gmail.com> <50D06177.2090905@mojatatu.com> <CAASe=fR6Hm2dxp=1wDchtrzqnaH6qacHpg2wrsqLfmGpPbQ9Fg@mail.gmail.com> <50D1A8A7.1090002@mojatatu.com> <50D1AB7E.5060000@mojatatu.com> <50D2D229.6040802@gmail.com> <50D305FD.7000901@mojatatu.com> <50D327CD.3050904@gmail.com> <50D45E25.7050703@mojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Hasan Chowdhury <shemonc@gmail.com>,
	Stephen Hemminger <shemminger@vyatta.com>,
	Jan Engelhardt <jengelh@inai.de>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	pablo@netfilter.org, netfilter-devel@vger.kernel.org
To: Jamal Hadi Salim <jhs@mojatatu.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <50D45E25.7050703@mojatatu.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

21.12.2012 17:03, Jamal Hadi Salim =D0=BF=D0=B8=D1=88=D0=B5=D1=82:
> On 12-12-20 09:59 AM, Yury Stankevich wrote:
>> interesting,
>>
>> #tc -s filter show dev usb0 parent ffff:
>=20
>=20
> Given you are adding this on ingress - the settings you have will
> happen before pre-routing hook.
> If you did things at egress - the setting will take effect after
> post-routing. So take a closer look at those details they look
> like your source of issues..

sure,
i use it ingress,
so, i need to use tc xt action
to get mark on the packet, before filter on ifb will run.

prerouting rule, in turn, used to test if mark was actually restored.

in practice:
1. prerouting rule - is not fired. so, no packets with mark was seen.
2. filter on ifb - do not pass traffic to flow configured.
looks like `CONNMARK --restore` is not really called.


--=20
Linux registered user #402966 // pub 1024D/E99AF373 <pgp.mit.edu>
--
To unsubscribe from this list: send the line "unsubscribe netfilter-dev=
el" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
