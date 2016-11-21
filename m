From: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Subject: Re: Synopsys Ethernet QoS Driver
Date: Mon, 21 Nov 2016 16:03:28 +0100
Message-ID: <7318c77e-3011-03f3-e673-54e3bb0554aa@st.com>
References: <CADvZ6ErjyVR5ShWTk0QesWLYR1m3p8yAMkK8v9gm2kN5xTv8zw@mail.gmail.com>
 <1dbb6047-2bbb-4d56-2a62-ab65a0254844@synopsys.com>
 <20161119135654.GA14079@lnxartpec.se.axis.com>
 <CAJ3bTp7PpUJcz=1JohX=A54UP6vVAafWnB0PGUBSxb5JJiO8Lg@mail.gmail.com>
 <1248f4ce-4859-10e6-fef9-342ea543f8d4@synopsys.com>
 <87c8a24b-0812-7850-cb3f-7be691bab432@st.com>
 <afc18eb0-4c11-9668-498d-982624c6de78@synopsys.com>
 <937252db-9538-2cf6-c8fa-82b558531c51@st.com>
 <48776f8b-4e06-1456-1b52-3ea08a22b2a4@synopsys.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"; Format="flowed"
Content-Transfer-Encoding: 7bit
Cc: andreas.irestal@axis.com, alexandre.torgue@st.com, saeedm@mellanox.com,
 netdev <netdev@vger.kernel.org>, linux-kernel@vger.kernel.org,
 CARLOS.PALMINHA@synopsys.com, idosch@mellanox.com,
 mued dib <kreptor@gmail.com>, jiri@mellanox.com,
 Jeff Kirsher <jeffrey.t.kirsher@intel.com>, David Miller <davem@davemloft.net>,
 "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>,
 lars.persson@axis.com
To: Joao Pinto <Joao.Pinto@synopsys.com>, Rayagond Kokatanur
 <rayagond@vayavyalabs.com>, Rabin Vincent <rabin@rab.in>
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
In-Reply-To: <48776f8b-4e06-1456-1b52-3ea08a22b2a4@synopsys.com>
List-Unsubscribe: <http://lists.infradead.org/mailman/options/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=unsubscribe>
List-Archive: <http://lists.infradead.org/pipermail/linux-arm-kernel/>
List-Post: <mailto:linux-arm-kernel@lists.infradead.org>
List-Help: <mailto:linux-arm-kernel-request@lists.infradead.org?subject=help>
List-Subscribe: <http://lists.infradead.org/mailman/listinfo/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=subscribe>
Sender: "linux-arm-kernel" <linux-arm-kernel-bounces@lists.infradead.org>
Errors-To: linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org
List-Id: netdev.vger.kernel.org

On 11/21/2016 4:00 PM, Joao Pinto wrote:
> On 21-11-2016 14:36, Giuseppe CAVALLARO wrote:
>> Hello Joao
>>
>> On 11/21/2016 2:48 PM, Joao Pinto wrote:
>>> Synopsys QoS IP is a separated hardware component, so it should be reusable by
>>> all implementations using it and so have its own "core driver" and platform +
>>> pci glue drivers. This is necessary for example in hardware validation, where
>>> you prototype an IP and instantiate its drivers and test it.
>>>
>>> Was there a strong reason to integrate QoS features directly in stmmac and not
>>> in synopsys/dwc_eth_qos.*?
>>
>> We decided to enhance the stmmac on supporting the QoS for several
>> reasons; for example the common APIs that the driver already exposed and
>> actually suitable for other SYNP chips. Then, PTP, EEE,
>> S/RGMII, MMC could be shared among different chips with a minimal
>> effort.  This meant a lot of code already ready.
>>
>> For sure, the net-core, Ethtool, mdio parts were reused. Same for the
>> glue logic files.
>> For the latter, this helped to easily bring-up new platforms also
>> because the stmmac uses the HW cap register to auto-configure many
>> parts of the MAC core, DMA and modules. This helped many users, AFAIK.
>>
>> For validation purpose, this is my experience, the stmmac helped
>> a lot because people used the same code to validate different HW
>> and it was easy to switch to a platform to another one in order to
>> verify / check if the support was ok or if a regression was introduced.
>> This is important for complex supports like PTP or EEE.
>>
>> Hoping this can help.
>>
>> Do not hesitate to contact me for further details
>
> Thanks for the highly detailed info.
> My target application is to prototype the Ethernet QoS IP in a FPGA, with a PHY
> attached and make hardware validation.
>
> In your opinion a refactored stmmac with the missing QoS features would be
> suitable for it?

I think so; somebody also added code for FPGA.

In any case, step-by-step we can explore and understand
how to proceed. I wonder if you could start looking at the internal
of the stmmac. Then welcome doubts and open question...

>
> Thanks.

welcome

peppe

>
>>
>> peppe
>
>
