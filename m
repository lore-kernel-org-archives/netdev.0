From: Jan Kiszka <jan.kiszka@siemens.com>
Subject: Re: [PATCH v2 5/6] stmmac: pci: Use dmi_system_id table for
 retrieving PHY addresses
Date: Sun, 28 May 2017 18:52:40 +0200
Message-ID: <9a0753a2-eb4d-5f9f-34a8-f1774593c28d@siemens.com>
References: <cover.1495814872.git.jan.kiszka@siemens.com>
 <6e12b2e63c7eaab6db937a99fedf79ec806d176f.1495814872.git.jan.kiszka@siemens.com>
 <CAHp75VeLVs6LK=_=e_2B+huZLENe6V-8SMNLiEEi+4h_uqmvMg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: Giuseppe Cavallaro <peppe.cavallaro@st.com>,
        Alexandre Torgue <alexandre.torgue@st.com>,
        David Miller <davem@davemloft.net>,
        netdev <netdev@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Andy Shevchenko <andy.shevchenko@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from goliath.siemens.de ([192.35.17.28]:39378 "EHLO
        goliath.siemens.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750941AbdE1Qww (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 28 May 2017 12:52:52 -0400
In-Reply-To: <CAHp75VeLVs6LK=_=e_2B+huZLENe6V-8SMNLiEEi+4h_uqmvMg@mail.gmail.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2017-05-27 15:28, Andy Shevchenko wrote:
> On Fri, May 26, 2017 at 7:07 PM, Jan Kiszka <jan.kiszka@siemens.com> wrote:
>> Avoids reimplementation of DMI matching in stmmac_pci_find_phy_addr.
> 
>>  struct stmmac_pci_dmi_data {
>> -       const char *name;
>> -       const char *asset_tag;
>> -       unsigned int func;
>> +       int func;
>>         int phy_addr;
>>  };
> 
> Can we leave unsigned type here...
> 
>> -static struct stmmac_pci_dmi_data quark_pci_dmi_data[] = {
>> +static const struct stmmac_pci_dmi_data galileo_stmmac_dmi_data[] = {
> 
>> +       {-1, -1},
>> +};
> 
>> +static const struct stmmac_pci_dmi_data iot2040_stmmac_dmi_data[] = {
> 
>> +       {-1, -1},
>> +};
> 
> ...and avoid this not so standard terminators?

0 is a valid PCI function, thus can't be use as terminator. Therefore I
chose -1 as an obviously invalid value.

> 
>> +               .matches = {
>> +                       DMI_EXACT_MATCH(DMI_BOARD_NAME, "GalileoGen2"),
>> +               },
> 
>> +               .driver_data = (void *)galileo_stmmac_dmi_data,
> 
> Can't be slightly better
> 
>              .driver_data = &galileo_stmmac_dmi_data,
> 
> ?
> 

Interesting, that removes the "const" as well. OK.

Jan

-- 
Siemens AG, Corporate Technology, CT RDA ITP SES-DE
Corporate Competence Center Embedded Linux
