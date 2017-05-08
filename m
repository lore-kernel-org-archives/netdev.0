From: Joao Pinto <Joao.Pinto@synopsys.com>
Subject: Re: [PATCH v3 net-next 01/11] net: stmmac: prepare dma op mode config
 for multiple queues
Date: Mon, 8 May 2017 13:02:12 +0100
Message-ID: <54cd5a46-eed3-bce7-5280-c5e95957e8e6@synopsys.com>
References: <cover.1489575025.git.jpinto@synopsys.com>
 <efde5ec3d6873d0b2ad5b806f230f5804257915d.1489575025.git.jpinto@synopsys.com>
 <de6d5aa6-250b-e583-3f24-aee13e6b7ff8@siemens.com>
 <CAHp75Vfe0pXTEvdt7Z3-DgMTFdC5B3106ubj_D+_ng0vNCUaRA@mail.gmail.com>
 <96c988c8-2d4a-33df-0d20-cc8adac3b01c@synopsys.com>
 <CAHp75VcO13o0BgZ75Ssxav2jwP_g+WXLjob8x5QTB6Mdoynpzg@mail.gmail.com>
 <967da95a-cc4e-a0ac-c702-e659bd4f0481@synopsys.com>
 <CAHp75Vea1jke4yp0=762B0XvFkcP+YrW=KA7C-v6w61_s4EzUA@mail.gmail.com>
 <c80563da-d4f7-5281-d692-d05f43fc80b6@synopsys.com>
 <CAHp75Vc1YeD9DvwVLh7U1CtDWRGpm-zQSbf4d8C=skLcf_ucBg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
Cc: Jan Kiszka <jan.kiszka@siemens.com>,
        "David S. Miller" <davem@davemloft.net>,
        Giuseppe CAVALLARO <peppe.cavallaro@st.com>,
        Alexandre TORGUE <alexandre.torgue@st.com>,
        netdev <netdev@vger.kernel.org>,
        Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
To: Andy Shevchenko <andy.shevchenko@gmail.com>,
        Joao Pinto <Joao.Pinto@synopsys.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from us01smtprelay-2.synopsys.com ([198.182.60.111]:37303 "EHLO
        smtprelay.synopsys.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751390AbdEHMCS (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 8 May 2017 08:02:18 -0400
In-Reply-To: <CAHp75Vc1YeD9DvwVLh7U1CtDWRGpm-zQSbf4d8C=skLcf_ucBg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Às 12:56 PM de 5/8/2017, Andy Shevchenko escreveu:
> On Mon, May 8, 2017 at 2:40 PM, Joao Pinto <Joao.Pinto@synopsys.com> wrote:
>> Às 12:34 PM de 5/8/2017, Andy Shevchenko escreveu:
>>> On Mon, May 8, 2017 at 1:42 PM, Joao Pinto <Joao.Pinto@synopsys.com> wrote:
>>>> Às 11:12 AM de 5/8/2017, Andy Shevchenko escreveu:
>>>>> On Mon, May 8, 2017 at 12:54 PM, Joao Pinto <Joao.Pinto@synopsys.com> wrote:
>>>>>> Às 10:36 AM de 5/8/2017, Andy Shevchenko escreveu:
> 
>>>
>>> [   44.374161] stmmac_dvr_probe <<< 0 0
>>>
>>
>> Ok, so this is the cause of the problem. The driver is geting 0 for real RX and
>> TX queues.
>>
>> Your setup uses standard DT parsing from stmmac_platform or a custom one?
>>
>> If you are using stmmac_probe_config_dt():
>> https://urldefense.proofpoint.com/v2/url?u=https-3A__git.kernel.org_pub_scm_linux_kernel_git_torvalds_linux.git_tree_drivers_net_ethernet_stmicro_stmmac_stmmac-5Fplatform.c-23n363&d=DwIFaQ&c=DPL6_X_6JkXFx7AXWqB0tg&r=s2fO0hii0OGNOv9qQy_HRXy-xAJUD1NNoEcc3io_kx0&m=fJQj7RiT2sksJYOAZ9VSJUDnxPR7RlE6Fw_cTV0_Mqc&s=KhdAPUtP0twDkibE89cLYs8JjnxEvBgav5uf08WL_e8&e= 
>>
>> You will find a function named stmmac_mtl_setup() being called:
>> https://urldefense.proofpoint.com/v2/url?u=https-3A__git.kernel.org_pub_scm_linux_kernel_git_torvalds_linux.git_tree_drivers_net_ethernet_stmicro_stmmac_stmmac-5Fplatform.c-23n492&d=DwIFaQ&c=DPL6_X_6JkXFx7AXWqB0tg&r=s2fO0hii0OGNOv9qQy_HRXy-xAJUD1NNoEcc3io_kx0&m=fJQj7RiT2sksJYOAZ9VSJUDnxPR7RlE6Fw_cTV0_Mqc&s=rTxn0fwdudwq9XAquH60xNHN538KBQ6_n4wODdLoyA0&e= 
>>
>> In this function, the number of RX and TX queues is being set to 1 by default.
> 
> Ah-ha, now I know how it's happened.
> You forget to update all setup() hooks in PCI bus driver :-)
> 
> I will prepare a fix.
> Just tell me should I put Fixes tag or not? And if yes, what commit
> should I refer to?
> 

Great, you can use this commit:

https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/commit/drivers/net/ethernet/stmicro/stmmac/stmmac_pci.c?id=26d6851fd24ed5d88580d66b4c8384947d5ca29b

Thanks!

Joao
