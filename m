From: Fan Du <fan.du@windriver.com>
Subject: Re: [PATCHv3 linux-next] hrtimer: Add notifier when clock_was_set
 was called
Date: Mon, 16 Sep 2013 08:26:09 +0800
Message-ID: <52365021.8040906@windriver.com>
References: <alpine.DEB.2.02.1309121441420.4089@ionos.tec.linutronix.de> <20130912134409.GB21212@gondor.apana.org.au> <alpine.DEB.2.02.1309121636010.4089@ionos.tec.linutronix.de> <20130912.133252.425268707009916773.davem@davemloft.net> <52327C92.5010009@windriver.com> <alpine.DEB.2.02.1309131628250.4089@ionos.tec.linutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, <herbert@gondor.hengli.com.au>,
	<steffen.klassert@secunet.com>, <dborkman@redhat.com>,
	<linux-kernel@vger.kernel.org>, <netdev@vger.kernel.org>,
	John Stultz <john.stultz@linaro.org>
To: Thomas Gleixner <tglx@linutronix.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <alpine.DEB.2.02.1309131628250.4089@ionos.tec.linutronix.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi, Thomas

On 2013=E5=B9=B409=E6=9C=8813=E6=97=A5 22:32, Thomas Gleixner wrote:
> On Fri, 13 Sep 2013, Fan Du wrote:
>> (2) What I have been bugging you around here for this long time is r=
eally the
>> second
>>      problem, I'm sorry I didn't make it clearly to you and others, =
which is
>> below:
>>
>>      Why using wall clock time to calculate soft/hard IPsec events w=
hen
>> xfrm_state timer
>>      out happens in its timeout handler? Because even if xfrm_state =
using
>> CLOCK_BOOTTIME,
>>      system wall clock time changing will surely disturb soft/hard I=
Psec
>> events, which
>>      you raised your concern about in (*a*).
>
> No CLOCK_BOOTTIME is not affected by wall clock time changes. It's
> basically CLOCK_MONOTONIC, it just keeps counting the suspend time as
> well. So without a suspend/resume cycle CLOCK_MONOTONIC and
> CLOCK_BOOTTIME are the same. After a suspend/resume cycle
> CLOCK_BOOTTIME will be N seconds ahead of CLOCK_MONOTONIC, where N is
> the number of seconds spent in suspend.

Sorry for the ambiguity. Yes, CLOCK_BOOTTIME is monotonic *and* countin=
g
suspend/resume time as well as not affected by wall clock time change.

Using CLOCK_BOOTTIME guarantees b- will timeout in a right manner, i.e.=
, not
affected by wall clock time change, as well as keep the timer valid whe=
n
suspend/resume.

A classic way of using timer is:
  a- Arm a timer with specified interval
  b- Wait for the timer to timeout
  c- After the timeout, notify the event to other place in the timer ha=
ndler.

IPsec key lifetime timer does its this way:
  a- Arm a timer with specified interval
  b- Wait for the timer to timeout
  c- After timeout, in the timer handler, using wall clock time to calc=
ulate
    which kind of event to notify user(soft or hard for both key use ti=
me,
    and key created time). So the problem arises at this stage if wall =
clock
    time changed.



Thanks

> Thanks,
>
> 	tglx
>

--=20
=E6=B5=AE=E6=B2=89=E9=9A=8F=E6=B5=AA=E5=8F=AA=E8=AE=B0=E4=BB=8A=E6=9C=9D=
=E7=AC=91

--fan
