From: Andy Shevchenko <andy.shevchenko@gmail.com>
Subject: Re: [PATCH v3 net-next 01/11] net: stmmac: prepare dma op mode config
 for multiple queues
Date: Mon, 8 May 2017 14:34:26 +0300
Message-ID: <CAHp75Vea1jke4yp0=762B0XvFkcP+YrW=KA7C-v6w61_s4EzUA@mail.gmail.com>
References: <cover.1489575025.git.jpinto@synopsys.com> <efde5ec3d6873d0b2ad5b806f230f5804257915d.1489575025.git.jpinto@synopsys.com>
 <de6d5aa6-250b-e583-3f24-aee13e6b7ff8@siemens.com> <CAHp75Vfe0pXTEvdt7Z3-DgMTFdC5B3106ubj_D+_ng0vNCUaRA@mail.gmail.com>
 <96c988c8-2d4a-33df-0d20-cc8adac3b01c@synopsys.com> <CAHp75VcO13o0BgZ75Ssxav2jwP_g+WXLjob8x5QTB6Mdoynpzg@mail.gmail.com>
 <967da95a-cc4e-a0ac-c702-e659bd4f0481@synopsys.com>
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
In-Reply-To: <967da95a-cc4e-a0ac-c702-e659bd4f0481@synopsys.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, May 8, 2017 at 1:42 PM, Joao Pinto <Joao.Pinto@synopsys.com> wrote:
> =C3=80s 11:12 AM de 5/8/2017, Andy Shevchenko escreveu:
>> On Mon, May 8, 2017 at 12:54 PM, Joao Pinto <Joao.Pinto@synopsys.com> wr=
ote:
>>> =C3=80s 10:36 AM de 5/8/2017, Andy Shevchenko escreveu:

>>>> JFYI: With today's linux-next when _kexec:ed_ kernel boots I tried and
>>>> got the following:

>>> Are you using the same version of Ethernet IP, 10/100?
>>
>> I'm running on Intel Galileo Gen2 board (v4.11 by the way works fine
>> with direct boot from SD card)
>>
>>> Could you please verify if the crash you are experiencing is this place=
?
>>> https://urldefense.proofpoint.com/v2/url?u=3Dhttps-3A__git.kernel.org_p=
ub_scm_linux_kernel_git_torvalds_linux.git_tree_drivers_net_ethernet_stmicr=
o_stmmac_stmmac-5Fmain.c-23n2956&d=3DDwIFaQ&c=3DDPL6_X_6JkXFx7AXWqB0tg&r=3D=
s2fO0hii0OGNOv9qQy_HRXy-xAJUD1NNoEcc3io_kx0&m=3DUF269QZ9ExFRw1XXpgdvO2QeTCL=
Ep-GquRe8OqZwRf0&s=3DyZu3uME5PK-3nJlxz-H-HfHh3Shjzg0je5If_jSXVb4&e=3D
>>>
>>> I would say that for rather old IPs, the napi is not capable of giving =
a valid
>>> queue number. Could you please print the queue index returned by this l=
ine?
>>>
>>> https://urldefense.proofpoint.com/v2/url?u=3Dhttps-3A__git.kernel.org_p=
ub_scm_linux_kernel_git_torvalds_linux.git_tree_drivers_net_ethernet_stmicr=
o_stmmac_stmmac-5Fmain.c-23n2948&d=3DDwIFaQ&c=3DDPL6_X_6JkXFx7AXWqB0tg&r=3D=
s2fO0hii0OGNOv9qQy_HRXy-xAJUD1NNoEcc3io_kx0&m=3DUF269QZ9ExFRw1XXpgdvO2QeTCL=
Ep-GquRe8OqZwRf0&s=3Dp_TgHODJum23I2N4AldR4oIaOPffSDpk9agmbRMQgoM&e=3D
>>
>> --- a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
>> +++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
>> @@ -2953,7 +2953,9 @@ static netdev_tx_t stmmac_xmit(struct sk_buff
>> *skb, struct net_device *dev)
>>        unsigned int enh_desc;
>>        unsigned int des;
>>
>> +       pr_info("%s <<< 1: priv %p, queue: %u\n", __func__, priv, queue)=
;
>>        tx_q =3D &priv->tx_queue[queue];
>> +       pr_info("%s <<< 2: priv %p, queue: %u tx_q: %p\n", __func__,
>> priv, queue, tx_q);
>>
>>
>> [  101.591040] stmmac_xmit <<< 1: priv cdd1c4c0, queue: 7
>> [  101.596377] stmmac_xmit <<< 2: priv cdd1c4c0, queue: 7 tx_q: cdd1caac

> I assume that the queue index is always 7 right? By return 7, the napi in=
terface
> 'thinks' that your setup is using 8 TX queues which I assume it is not an=
d thats
> the problem causing your board to malfuntion.
>
> Could you please check the values of the 'real' tx and rx queues count in=
 this line?
> https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/d=
rivers/net/ethernet/stmicro/stmmac/stmmac_main.c#n4107
>
> For default they are =3D1, so napi should be assuming 1RX and 1TX, and so=
 you
> should be getting queue index =3D0 in reception and transmission.
>
> In terms of reception, could you print the queue index that stmmac_poll i=
s using
> here:
>
> https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/d=
rivers/net/ethernet/stmicro/stmmac/stmmac_main.c#n3468

+       pr_info("%s <<< %u\n", __func__, rx_q->queue_index);
       work_done =3D stmmac_rx(priv, budget, rx_q->queue_index);
       if (work_done < budget) {
               napi_complete_done(napi, work_done);

       /* Configure real RX and TX queues */
       netif_set_real_num_rx_queues(ndev, priv->plat->rx_queues_to_use);
       netif_set_real_num_tx_queues(ndev, priv->plat->tx_queues_to_use);
+       pr_info("%s <<< %hhu %hhu\n", __func__,
priv->plat->rx_queues_to_use, priv->plat->tx_queues_to_use);


[   44.374161] stmmac_dvr_probe <<< 0 0

[  109.014763] stmmac_xmit <<< 1: priv cdcea4c0, queue: 2
[  109.020099] stmmac_xmit <<< 2: priv cdcea4c0, queue: 2 tx_q: cdcea9e4

That's all, no poll activated.

--=20
With Best Regards,
Andy Shevchenko
