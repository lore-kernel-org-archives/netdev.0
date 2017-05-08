From: Andy Shevchenko <andy.shevchenko@gmail.com>
Subject: Re: [PATCH v3 net-next 01/11] net: stmmac: prepare dma op mode config
 for multiple queues
Date: Mon, 8 May 2017 14:56:10 +0300
Message-ID: <CAHp75Vc1YeD9DvwVLh7U1CtDWRGpm-zQSbf4d8C=skLcf_ucBg@mail.gmail.com>
References: <cover.1489575025.git.jpinto@synopsys.com> <efde5ec3d6873d0b2ad5b806f230f5804257915d.1489575025.git.jpinto@synopsys.com>
 <de6d5aa6-250b-e583-3f24-aee13e6b7ff8@siemens.com> <CAHp75Vfe0pXTEvdt7Z3-DgMTFdC5B3106ubj_D+_ng0vNCUaRA@mail.gmail.com>
 <96c988c8-2d4a-33df-0d20-cc8adac3b01c@synopsys.com> <CAHp75VcO13o0BgZ75Ssxav2jwP_g+WXLjob8x5QTB6Mdoynpzg@mail.gmail.com>
 <967da95a-cc4e-a0ac-c702-e659bd4f0481@synopsys.com> <CAHp75Vea1jke4yp0=762B0XvFkcP+YrW=KA7C-v6w61_s4EzUA@mail.gmail.com>
 <c80563da-d4f7-5281-d692-d05f43fc80b6@synopsys.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Cc: Jan Kiszka <jan.kiszka@siemens.com>,
        "David S. Miller" <davem@davemloft.net>,
        Giuseppe CAVALLARO <peppe.cavallaro@st.com>,
        Alexandre TORGUE <alexandre.torgue@st.com>,
        netdev <netdev@vger.kernel.org>,
        Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
To: Joao Pinto <Joao.Pinto@synopsys.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <c80563da-d4f7-5281-d692-d05f43fc80b6@synopsys.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, May 8, 2017 at 2:40 PM, Joao Pinto <Joao.Pinto@synopsys.com> wrote:
> =C3=80s 12:34 PM de 5/8/2017, Andy Shevchenko escreveu:
>> On Mon, May 8, 2017 at 1:42 PM, Joao Pinto <Joao.Pinto@synopsys.com> wro=
te:
>>> =C3=80s 11:12 AM de 5/8/2017, Andy Shevchenko escreveu:
>>>> On Mon, May 8, 2017 at 12:54 PM, Joao Pinto <Joao.Pinto@synopsys.com> =
wrote:
>>>>> =C3=80s 10:36 AM de 5/8/2017, Andy Shevchenko escreveu:

>>
>> [   44.374161] stmmac_dvr_probe <<< 0 0
>>
>
> Ok, so this is the cause of the problem. The driver is geting 0 for real =
RX and
> TX queues.
>
> Your setup uses standard DT parsing from stmmac_platform or a custom one?
>
> If you are using stmmac_probe_config_dt():
> https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/d=
rivers/net/ethernet/stmicro/stmmac/stmmac_platform.c#n363
>
> You will find a function named stmmac_mtl_setup() being called:
> https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/d=
rivers/net/ethernet/stmicro/stmmac/stmmac_platform.c#n492
>
> In this function, the number of RX and TX queues is being set to 1 by def=
ault.

Ah-ha, now I know how it's happened.
You forget to update all setup() hooks in PCI bus driver :-)

I will prepare a fix.
Just tell me should I put Fixes tag or not? And if yes, what commit
should I refer to?

--=20
With Best Regards,
Andy Shevchenko
