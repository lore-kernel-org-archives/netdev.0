From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: Re: [PATCH 02/26] can: c_can: Fix startup logic
Date: Fri, 02 May 2014 14:37:58 +0200
Message-ID: <536391A6.2040800@pengutronix.de>
References: <1398376829-6771-1-git-send-email-mkl@pengutronix.de> <1398376829-6771-3-git-send-email-mkl@pengutronix.de> <CAGm1_ks-Kw2AtNCNpng6Tp2v3wS=HK7DGWTD0iFcMVMhASSO5A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Cc: netdev <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	"linux-can@vger.kernel.org" <linux-can@vger.kernel.org>,
	kernel@pengutronix.de, Thomas Gleixner <tglx@linutronix.de>
To: Yegor Yefremov <yegorslists@googlemail.com>
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <CAGm1_ks-Kw2AtNCNpng6Tp2v3wS=HK7DGWTD0iFcMVMhASSO5A@mail.gmail.com>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 04/29/2014 09:29 AM, Yegor Yefremov wrote:
> On Fri, Apr 25, 2014 at 12:00 AM, Marc Kleine-Budde <mkl@pengutronix.de> wrote:
>> From: Thomas Gleixner <tglx@linutronix.de>
>>
>> c_can_start() enables interrupts way too early. The first enabling
>> happens when setting the control mode in c_can_chip_config() and then
>> again at the end of the function.
>>
>> But that happens before napi_enable() and that means that an interrupt
>> which comes in will disable interrupts again and call napi_schedule,
>> which ignores the request and the later napi_enable() is not making
>> thinks work either. So the interface is up with all device interrupts
>> disabled.
>>
>> Move the device interrupt after napi_enable() and add it to the other
>> callsites of c_can_start() in c_can_set_mode() and c_can_power_up()
>>
>> Signed-off-by: Thomas Gleixner <tglx@linutronix.de>
>> Tested-by: Alexander Stein <alexander.stein@systec-electronic.com>
>> Signed-off-by: Marc Kleine-Budde <mkl@pengutronix.de>
> 
> Tested-by: Yegor Yefremov <yegorslists@googlemail.com>

Thanks, as this branch is already merged by David, it's too late to add
your Tested-by.

Marc

-- 
Pengutronix e.K.                  | Marc Kleine-Budde           |
Industrial Linux Solutions        | Phone: +49-231-2826-924     |
Vertretung West/Dortmund          | Fax:   +49-5121-206917-5555 |
Amtsgericht Hildesheim, HRA 2686  | http://www.pengutronix.de   |
