From: Wolfgang Grandegger <wg@grandegger.com>
Subject: Re: [PATCH] can: flexcan: fix irq flooding by clearing all interrupt
 sources
Date: Tue, 13 Dec 2011 17:22:06 +0100
Message-ID: <4EE77BAE.5040702@grandegger.com>
References: <4EE61928.10608@grandegger.com> <4EE61E3D.2090303@pengutronix.de> <4EE62141.8010305@grandegger.com> <4EE7416E.8070203@grandegger.com> <4EE74AC5.9050404@grandegger.com> <4EE74C2A.9040908@pengutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-can@vger.kernel.org,
	Reuben Dowle <Reuben.Dowle@navico.com>,
	=?ISO-8859-1?Q?Lothar_Wa=DFmann?= <LW@KARO-electronics.de>
To: Marc Kleine-Budde <mkl@pengutronix.de>
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <4EE74C2A.9040908@pengutronix.de>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 12/13/2011 01:59 PM, Marc Kleine-Budde wrote:
> On 12/13/2011 01:53 PM, Wolfgang Grandegger wrote:
>>> I got my MX35PDK board working and can confirm, that the patch works on
>>> a i.mx35 as well. My testing also confirms, that the ESR TWRN_INT,
>>> RWRN_INT, FLEXCAN_ESR_BOFF_INT do not function as documented. These
>>> flags do show up once, together with ERR_INT, and then, after clearing,
>>> never again. Obviously a bug in the Flexcan logic. From the feedback we
>>> can say, that only the i.MX28 does behave differently (==correctly). All
>>> other seem to work with the current code:
>>>
>>>  Flexcan on
>>>  - i.mx25
>>>  - i.mx35
>>>  - i.mx53
>>>  - P1010/P1020
>>
>> But unfortunately, state change reporting looks different with this patch :)
> 
> Hmm - so not schedule for stable. What about your buf-off-handling, will
> this change the reporting again?

Well, as it is a serious problem on i.MX28, I would schedule this patch
for stable as well. The error and state change reporting is bogus on the
Flexcan anyhow. Without this patch, I get "active->warning->passive" if
I send a message with cable disconnect (no ack). With patch just
"active->warning". That's the same behaviour
as on the i.MX28, also with my new state and bus-off handling. See:

https://gitorious.org/~wgrandegger/linux-can/wg-linux-can-next/commit/bd3acb12dbb9551541d28ae8766c154d3cf6ed57

Wolfgang.

