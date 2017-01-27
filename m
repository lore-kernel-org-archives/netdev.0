From: Rafal Ozieblo <rafalo@cadence.com>
Subject: RE: [PATCH net-next v2] macb: Common code to enable ptp support for
 MACB/GEM
Date: Fri, 27 Jan 2017 10:26:14 +0000
Message-ID: <BN3PR07MB25163747E1520E4CE1C6164FC9760@BN3PR07MB2516.namprd07.prod.outlook.com>
References: <1484841375-11420-1-git-send-email-andrei.pistirica@microchip.com>
 <BN3PR07MB25160FCBCF19918C495F43B4C9770@BN3PR07MB2516.namprd07.prod.outlook.com>
 <CAFcVECLuWM65zXJWtMcwijZ1ZbtH0pvKnTUR=SJagPGHEr9amg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "tbultel@pixelsurmer.com" <tbultel@pixelsurmer.com>,
 "boris.brezillon@free-electrons.com" <boris.brezillon@free-electrons.com>,
 "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
 "alexandre.belloni@free-electrons.com" <alexandre.belloni@free-electrons.com>,
 "nicolas.ferre@atmel.com" <nicolas.ferre@atmel.com>,
 "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
 "richardcochran@gmail.com" <richardcochran@gmail.com>,
 Andrei Pistirica <andrei.pistirica@microchip.com>,
 "michals@xilinx.com" <michals@xilinx.com>,
 "anirudh@xilinx.com" <anirudh@xilinx.com>,
 "punnaia@xilinx.com" <punnaia@xilinx.com>,
 "harini.katakam@xilinx.com" <harini.katakam@xilinx.com>,
 "davem@davemloft.net" <davem@davemloft.net>,
 "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>
To: Harini Katakam <harinikatakamlinux@gmail.com>
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
In-Reply-To: <CAFcVECLuWM65zXJWtMcwijZ1ZbtH0pvKnTUR=SJagPGHEr9amg@mail.gmail.com>
Content-Language: en-US
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

>-----Original Message-----
>From: Harini Katakam [mailto:harinikatakamlinux@gmail.com] 
>Sent: 27 stycznia 2017 06:43
>Subject: Re: [PATCH net-next v2] macb: Common code to enable ptp support for MACB/GEM
>
>Hi Rafal,
>
>On Thu, Jan 26, 2017 at 8:45 PM, Rafal Ozieblo <rafalo@cadence.com> wrote:
>>> -----Original Message-----
>>> From: Andrei Pistirica [mailto:andrei.pistirica@microchip.com]
>>> Sent: 19 stycznia 2017 16:56
>>> Subject: [PATCH net-next v2] macb: Common code to enable ptp support for MACB/GEM
>>>
>>>
>>> +static inline bool gem_has_ptp(struct macb *bp)
>>> +{
>>> +     return !!(bp->caps & MACB_CAPS_GEM_HAS_PTP);
>>> +}
>> Why don't you use hardware capabilities here? Would it be better to read it from hardware instead adding it to many configuration?
>
>If you are referring to TSU bit in DCFG5, then we will be relying on
>Cadence IP's information irrespective of the SoC capability
>and whether the PTP support was adequate.
>I think the capability approach gives better control and
>it is not really much to add.
>
>Regards,
>Harini
>
Yes, I'm referring to TSU bit.
What if SoC contains multiple Cadence GEMs, some with PTP support and others without?
Relevant will be checking both, hardware capabilities and SoC capabilities from "caps" field.
