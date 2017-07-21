From: Marc Gonzalez <marc_gonzalez@sigmadesigns.com>
Subject: Re: [PATCH v2 1/4] net: phy: at803x: Document RGMII RX and TX clock
 delay issues
Date: Fri, 21 Jul 2017 16:36:41 +0200
Message-ID: <ee921ae6-4501-8406-2deb-91e884c802d3@sigmadesigns.com>
References: <2617d673-ef81-5e7f-4730-ed3aa3f1c2c6@sigmadesigns.com>
 <051653a2-946f-6a0b-4cff-b403d1197038@sigmadesigns.com>
 <a9d3777c-1752-d79b-8302-d09c5f736a9f@codeaurora.org>
 <db666f79-5ee3-f136-527e-aeb9cc6425b7@sigmadesigns.com>
 <1c35e791-c181-2855-8463-b3b0ef5367a2@codeaurora.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
 Thibaud Cornic <thibaud_cornic@sigmadesigns.com>,
 "David S. Miller" <davem@davemloft.net>,
 Linux ARM <linux-arm-kernel@lists.infradead.org>, Mason <slash.tmp@free.fr>
To: Timur Tabi <timur@codeaurora.org>, Florian Fainelli
 <f.fainelli@gmail.com>, Andrew Lunn <andrew@lunn.ch>, Mans Rullgard
 <mans@mansr.com>, Martin Blumenstingl <martin.blumenstingl@gmail.com>,
 Grygorii Strashko <grygorii.strashko@ti.com>, Fabio Estevam
 <fabio.estevam@nxp.com>, Zefir Kurtisi <zefir.kurtisi@neratec.com>, "Daniel
 Mack" <zonque@gmail.com>
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
In-Reply-To: <1c35e791-c181-2855-8463-b3b0ef5367a2@codeaurora.org>
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

On 21/07/2017 16:06, Timur Tabi wrote:

> On 7/21/17 8:29 AM, Marc Gonzalez wrote:
>
>> I don't understand what you're saying.
>>
>> It is a correct observation that the code enabling
>> RGMII RX clock delay is a NOP, since that bit will
>> always be set at that point.
>>
>> The spec for the 8035 (I haven't checked for 8030 and 8031,
>> is that what you meant by "other systems"?) states that
>> Sel_clk125m_dsp, which is described as:
>> "Control bit for rgmii interface rx clock delay"
>> is 1 after HW reset, 1 after SW reset.
>>
>> So my statement "RX clock delay is enabled at reset"
>> is universally true. It's not just on some systems.
> 
> Ok, taken out of context, the comment doesn't really explain why the 
> code is the way it is.  I'm not really happy about the word "assumes". 

If a HW setting defaults to 0 at reset, and some init is called
right after reset, then you know the setting's value is 0.
If you need that value to be 1, all you need is a function
setting it to 1. This is the current situation.

Commit 2e5f9f281ee8 assumes 0 at reset, and provides a function
setting the value to 1.

Reality is different. The HW setting defaults to 1 at reset.
So it turns out that the function setting the value to 1
is pointless, because the value is already 1. There is
however no way to set the value to 0.

Does that explain why I wrote "assume"?

Also the commit message:
"The current code supports enabling RGMII RX and TX clock delays.
The unstated assumption is that these settings are disabled by
default at reset, which is not the case."

> Maybe you should add a sentence explaining when the code is NOT a no-op.

The code is *NEVER* NOT a no-op.
I.e. the code enabling RX clock delay is ALWAYS a no-op.
I don't understand what you think is unclear in my comment.

Regards.
