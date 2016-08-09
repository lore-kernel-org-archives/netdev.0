From: Wolfgang Grandegger <wg@grandegger.com>
Subject: Re: [PATCH RESEND] net: can: Introduce MEN 16Z192-00 CAN controller
 driver
Date: Tue, 9 Aug 2016 13:54:30 +0200
Message-ID: <0dc06064-9f4b-a392-d167-39f2124970ad@grandegger.com>
References: <20160726091555.GA26227@awelinux>
 <9487fe77-dbd0-3a64-b648-cf76b897feda@grandegger.com>
 <20160808113938.GA17459@awelinux>
 <456c4f82-6a53-e821-3396-63d413db9eb7@grandegger.com>
 <20160808140546.GA1733@awelinux>
 <808e919b-8643-2113-9fde-001861883abe@grandegger.com>
 <20160809061038.GC1733@awelinux>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: mkl@pengutronix.de, linux-can@vger.kernel.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	davem@davemloft.net, jthumshirn@suse.de, andy@wernerandy.de,
	michael.miehling@men.de
To: Andreas Werner <andreas.werner@men.de>
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <20160809061038.GC1733@awelinux>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Am 09.08.2016 um 08:10 schrieb Andreas Werner:
> On Mon, Aug 08, 2016 at 04:35:34PM +0200, Wolfgang Grandegger wrote:
>> Am 08.08.2016 um 16:05 schrieb Andreas Werner:
>>> On Mon, Aug 08, 2016 at 02:28:39PM +0200, Wolfgang Grandegger wrote:

---snip---

>>>>>>> +
>>>>>>> +	ndev = alloc_candev(sizeof(struct men_z192), 1);
>>>>>>
>>>>>> You specify here one echo_skb but it's not used anywhere. Local loopback
>>>>>> seems not to be implemented.
>>>>>>
>>>>>
>>>>> Agree with you, will set it to "0".
>>>>
>>>> No, the local loopback is mandetory!
>>>>
>>>
>>> Hm ok, but if i check alloc_candev() in drivers/net/can/dev.c
>>> it is not mandatory. In the Documentation/networking/can.txt
>>> there is also a "should" and a fallback mechnism if the driver
>>> does not support the local loopback.
>>
>> Well, s/driver/hardware/ ! Local loopback is the preferred mechanism.
>>
>
> Sure...
>
>>> I'm currently ok with this fallback mechanism.
>>>
>>> Anyway I am not sure that the driver can handle the echo skb correctly.
>>> If i understand it correctly, the can_get_echo_skb() is normally called
>>> on a "TX done IRQ" to get the skb and loop it back.
>>> I do not have such a "TX done IRQ" and have not implemented implemented
>>> and added the local looback.
>>
>> What does "MEN_Z192_TFLG_TXIF" signal?
>>
>
> It is not a "TX Done" IRQ, it is the tx buffer level IRQ.
> The IRQ is triggered when the number of available tx buffer entries is as
> configured with txlvl. (after the buffer was full)
>
> Example:
> txlvl = 0
> tx buffer has 255 entries.
>
> -> The IRQ is triggered as soon as 1 frame got transmitted (254 entries).
>
> ---
>
> txlvl = 254
> tx buffer has 255 entries.
>
> -> The IRQ is triggered as soon as the buffer has one entry and it got transmitted
>
>
>>> May be I can put and get the echo skb within the xmit function?
>>> Does this make sense?
>>
>> It only makes sense if the driver knows when one or more transfers are done.
>>
>
> Then i do not think that I can use the txlvl IRQ in this case and need to use
> the fallback mechanism.


You could store "MEN_Z192_TX_BUF_CNT(readl(&regs->rx_tx_sts))" in the 
start_xmit function and check again in the isr function to find out how 
much transfers have been transmitted in the meantime. Does it make sense?

Wolfgang.

