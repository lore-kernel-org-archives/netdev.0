From: Grant Likely <grant.likely@secretlab.ca>
Subject: Re: [PATCH 1/3] serial/imx: add device tree support
Date: Sun, 19 Jun 2011 12:44:34 -0600
Message-ID: <BANLkTi=Ur1+FAHd2J_KGZgtuGTHrrtBb_g@mail.gmail.com>
References: <1308410354-21387-1-git-send-email-shawn.guo@linaro.org>
 <1308410354-21387-2-git-send-email-shawn.guo@linaro.org> <20110618161934.GH8195@ponder.secretlab.ca>
 <20110619073000.GA23171@S2100-06.ap.freescale.net> <BANLkTi=1hf7ycwMBcZ0+VDNRMG1_vdnSqA@mail.gmail.com>
 <4DFE129E.1010800@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Shawn Guo <shawn.guo@freescale.com>, patches@linaro.org,
	netdev@vger.kernel.org, devicetree-discuss@lists.ozlabs.org,
	Jason Liu <jason.hui@linaro.org>, linux-kernel@vger.kernel.org,
	Jeremy Kerr <jeremy.kerr@canonical.com>,
	Sascha Hauer <s.hauer@pengutronix.de>,
	linux-arm-kernel@lists.infradead.org
To: Rob Herring <robherring2@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <4DFE129E.1010800@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, Jun 19, 2011 at 9:15 AM, Rob Herring <robherring2@gmail.com> wr=
ote:
> On 06/19/2011 10:05 AM, Grant Likely wrote:
>> On Sun, Jun 19, 2011 at 1:30 AM, Shawn Guo <shawn.guo@freescale.com>=
 wrote:
>>> On Sat, Jun 18, 2011 at 10:19:34AM -0600, Grant Likely wrote:
>>>> On Sat, Jun 18, 2011 at 11:19:12PM +0800, Shawn Guo wrote:
>>>>> It adds device tree data parsing support for imx tty/serial drive=
r.
>>>>>
>>>>> Signed-off-by: Jeremy Kerr <jeremy.kerr@canonical.com>
>>>>> Signed-off-by: Jason Liu <jason.hui@linaro.org>
>>>>> Signed-off-by: Shawn Guo <shawn.guo@linaro.org>
>>>>> Cc: Sascha Hauer <s.hauer@pengutronix.de>
>>>>> ---
>>>>> =A0.../bindings/tty/serial/fsl-imx-uart.txt =A0 =A0 =A0 =A0 =A0 |=
 =A0 21 +++++
>>>>> =A0drivers/tty/serial/imx.c =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 | =A0 81 +++++++++++++++++---
>>>>> =A02 files changed, 92 insertions(+), 10 deletions(-)
>>>>> =A0create mode 100644 Documentation/devicetree/bindings/tty/seria=
l/fsl-imx-uart.txt
>>>>>
>>>>> diff --git a/Documentation/devicetree/bindings/tty/serial/fsl-imx=
-uart.txt b/Documentation/devicetree/bindings/tty/serial/fsl-imx-uart.t=
xt
>>>>> new file mode 100644
>>>>> index 0000000..7648e17
>>>>> --- /dev/null
>>>>> +++ b/Documentation/devicetree/bindings/tty/serial/fsl-imx-uart.t=
xt
>>>>> @@ -0,0 +1,21 @@
>>>>> +* Freescale i.MX Universal Asynchronous Receiver/Transmitter (UA=
RT)
>>>>> +
>>>>> +Required properties:
>>>>> +- compatible : should be "fsl,<soc>-uart", "fsl,imx-uart"
>>>>
>>>> I'd make this "fsl,<soc>-uart", "fsl,imx51-uart"
>>>>
>>>> It's better to anchor these things on real silicon, or a real ip b=
lock
>>>> specification rather than something pseudo-generic. =A0Subsequent =
chips,
>>>> like the imx53, should simply claim compatibility with the older
>>>> fsl,imx51-uart.
>>>
>>> It is a real IP block on all imx silicons (except imx23 and imx28
>>> which are known as former stmp).
>>>
>>>>
>>>> (in essence, "fsl,imx51-uart" becomes the generic string without t=
he
>>>> downside of having no obvious recourse when new silicon shows up t=
hat
>>>> is an imx part, but isn't compatible with the imx51 uart.
>>>>
>>> In this case, should imx1 the ancestor of imx family than imx51
>>> becomes part of that generic string? =A0Claiming uart of imx1, imx2=
1
>>> and imx31 (senior than imx51) compatible with the imx51 uart seems
>>> odd to me.
>>>
>>> That said, IMO, "fsl,imx-uart" stands a real IP block specification
>>> here and can be a perfect generic compatibility string to tell the
>>> recourse of any imx silicon using this IP.
>>
>> Yes, but which /version/ of the IP block? =A0Hardware designers are
>> notorious for changing hardware designs for newer silicon, sometimes
>> to add features, sometimes to fix bugs. =A0While I understand the
>> temptation to boil a compatible value down to a nice clean generic
>> string, doing so only works in a perfect world. =A0In the real world=
,
>> you still need to have some information about the specific
>> implementation. =A0I prefer this specifying it to the SoC name, but =
I've
>> been known to be convinced that specifying it to the ip-block name &
>> version in certain circumstances, like for IP blocks in an FPGA, or
>> some of the Freescale powerpc pXXXX SoCs which actually had an IP
>> block swapped out midway through the life of the chip.
>>
>
> There are definitely uart changes along the way with each generation.
>
>> Besides, encoding an soc or ip block version into the 'generic'
>> compatible values is not just good practice, it has *zero downside*.
>> That's the beauty of the compatible property semantics. =A0Any node =
can
>> claim compatibility with an existing device. =A0If no existing devic=
e
>> fits correctly, then the node simple does not claim compatibility.
>> Drivers can bind to any number of compatible strings, so it would be
>> just fine for the of_match_table list to include both "fsl,imx-21" a=
nd
>> "fsl,imx-51" (assuming that is the appropriate solution in this case=
).
>>
>
> Don't you need uart or serial in here somewhere.

you are of course correct.  The examples should be "fsl,imx21-uart" &
"fsl,imx51-uart".  I was just writing too quickly.

g.
