From: Vince Bridgers <vbridgers2013@gmail.com>
Subject: Re: [PATCH] net: stmmac: add dcrs parameter
Date: Mon, 25 Aug 2014 10:10:09 -0500
Message-ID: <CAOwfj2Oyy8EGxPhgJcgeGPMm3tJ9-fGOh5h7jU8q4_BO=vWrTA@mail.gmail.com>
References: <1408967442-2724-1-git-send-email-lftan@altera.com>
	<CAGb2v65fi=D_TQBSospft4T5OrBCj5TwQfgtkX=11M8TWFftYg@mail.gmail.com>
	<53FB313C.9010808@st.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Chen-Yu Tsai <wens@csie.org>, Ley Foon Tan <lftan@altera.com>,
	netdev <netdev@vger.kernel.org>,
	linux-kernel <linux-kernel@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>, lftan.linux@gmail.com,
	Vince Bridgers <vbridger@altera.com>
To: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <53FB313C.9010808@st.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

On Mon, Aug 25, 2014 at 7:51 AM, Giuseppe CAVALLARO
<peppe.cavallaro@st.com> wrote:
> On 8/25/2014 2:34 PM, Chen-Yu Tsai wrote:
>>
>> Hi,
>>
>> On Mon, Aug 25, 2014 at 7:50 PM, Ley Foon Tan <lftan@altera.com> wrote:
>>>
>>> This patch add the option to enable DCRS bit in GMAC control register.
>>> Default is disabled if snps,dcrs is not defined.
>>>
>>> For MII, Carrier Sense (CRS) must be asserted during transmission
>>> whereas in RGMII, CRS is not. RGMII does not provide a way to signal
>>> loss of carrier during a transmission.

While technically true, from a practical point of view, this is only
useful if using true half-duplex media (like the now obsolete 10Base2
and 10Base5 - think old school coax with vampire taps).

>>>
>>> When DCRS bit set high in control register, the MAC transmitter
>>> ignore the (G)MII Carrier Sense signal during frame transmission
>>> in the half-duplex mode. This request results in no errors generated
>>> because of Loss of Carrier or No Carrier during such transmission.
>>>
>>> Signed-off-by: Ley Foon Tan <lftan@altera.com>
>>> ---

<snip>

>>
>> Since you know this is only required under (G)MII, could you not re-use
>> the "phy-mode" property, instead of adding another one?
>>
>> Better yet, use the "interface" field in the platform data. This way
>> you'll
>> fix non-DT devices as well. You could then avoid touching the platform
>> driver,
>> and just modify the driver core.
>
>
> yes this is what I asked. Thx ChenYu for the this detail.
> Ley Foon Tan, could you do that? Let me know
>
> peppe
>
>

In the Synopsys EMAC case, carrier sense is used to stop transmitting
if no carrier is sensed during a transmission. This is only useful if
the media in use is true half duplex media (like obsolete 10Base2 or
10Base5). If no one in using true half duplex media, then is it
possible to set this disable by default? If we're not sure, then
having an option feels like the right thing to do.

Vince
