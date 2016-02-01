From: Gregory CLEMENT <gregory.clement@free-electrons.com>
Subject: Re: [PATCH v2 net 3/6] net: mvneta: Remove unused code
Date: Mon, 01 Feb 2016 14:37:03 +0100
Message-ID: <87d1sg7ds0.fsf@free-electrons.com>
References: <1454332067-16378-1-git-send-email-gregory.clement@free-electrons.com>
	<1454332067-16378-4-git-send-email-gregory.clement@free-electrons.com>
	<56AF5E55.9030603@cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem@davemloft.net>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	Thomas Petazzoni <thomas.petazzoni@free-electrons.com>,
	Jason Cooper <jason@lakedaemon.net>,
	Andrew Lunn <andrew@lunn.ch>,
	Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>,
	linux-arm-kernel@lists.infradead.org,
	Lior Amsalem <alior@marvell.com>,
	Nadav Haklai <nadavh@marvell.com>,
	Marcin Wojtas <mw@semihalf.com>,
	Russell King - ARM Linux <linux@arm.linux.org.uk>,
	Willy Tarreau <w@1wt.eu>
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <56AF5E55.9030603@cogentembedded.com> (Sergei Shtylyov's message
	of "Mon, 1 Feb 2016 16:32:05 +0300")
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Sergei,
=20
 On lun., f=C3=A9vr. 01 2016, Sergei Shtylyov <sergei.shtylyov@cogentem=
bedded.com> wrote:

> Hello.
>
> On 2/1/2016 4:07 PM, Gregory CLEMENT wrote:
>
>> Since the commit 2dcf75e2793c ("net: mvneta: Associate RX queues wit=
h
>> each CPU") all the percpu irq are used and unmask at initialization,=
 so
>
>    Unmasked, you mean?

yes and disabled would be more appropriate actually.

>
>> there is no point to unmask them first.
>
>    Mask, maybe (looking at the patch)?

not mask, but here again disable would be more appropriate. The code
removed disables the interrupt.


Thanks,

Gregory

>
>> Signed-off-by: Gregory CLEMENT <gregory.clement@free-electrons.com>
>> ---
>>   drivers/net/ethernet/marvell/mvneta.c | 8 --------
>>   1 file changed, 8 deletions(-)
>>
>> diff --git a/drivers/net/ethernet/marvell/mvneta.c b/drivers/net/eth=
ernet/marvell/mvneta.c
>> index 3d6e3137f305..861b7e0d7d5f 100644
>> --- a/drivers/net/ethernet/marvell/mvneta.c
>> +++ b/drivers/net/ethernet/marvell/mvneta.c
>> @@ -3009,14 +3009,6 @@ static int mvneta_open(struct net_device *dev=
)
>>   		goto err_cleanup_txqs;
>>   	}
>>
>> -	/* Even though the documentation says that request_percpu_irq
>> -	 * doesn't enable the interrupts automatically, it actually
>> -	 * does so on the local CPU.
>> -	 *
>> -	 * Make sure it's disabled.
>> -	 */
>> -	mvneta_percpu_disable(pp);
>> -
>>   	/* Enable per-CPU interrupt on all the CPU to handle our RX
>>   	 * queue interrupts
>>   	 */
>
> MBR, Sergei
>

--=20
Gregory Clement, Free Electrons
Kernel, drivers, real-time and embedded Linux
development, consulting, training and support.
http://free-electrons.com
