From: Wolfgang Grandegger <wg@grandegger.com>
Subject: Re: [PATCH v5 2/5] can: =?UTF-8?Q?kvaser=5Fusb=3A=20Consolidate?=  =?UTF-8?Q?=20and=20unify=20state=20change=20handling?=
Date: Wed, 21 Jan 2015 12:53:58 +0100
Message-ID: <e5439ed067931dc01bda70592eb6ed52@grandegger.com>
References: <20141223154654.GB6460@vivalin-002>
 <20150120214409.GA16828@linux> <20150120214537.GB16828@linux>
 <20150121103319.14511.57709@shannon>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: "Ahmed S. Darwish" <darwish.07@gmail.com>,
	Olivier Sobrie <olivier@sobrie.be>,
	Oliver Hartkopp <socketcan@hartkopp.net>,
	Marc Kleine-Budde <mkl@pengutronix.de>,
	Linux-CAN <linux-can@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>
To: Andri Yngvason <andri.yngvason@marel.com>
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <20150121103319.14511.57709@shannon>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 21 Jan 2015 10:33:19 +0000, Andri Yngvason
<andri.yngvason@marel.com> wrote:
> Quoting Ahmed S. Darwish (2015-01-20 21:45:37)
>> From: Ahmed S. Darwish <ahmed.darwish@valeo.com>
>> 
>> Replace most of the can interface's state and error counters
>> handling with the new can-dev can_change_state() mechanism.
>> 
>> Suggested-by: Andri Yngvason <andri.yngvason@marel.com>
>> Signed-off-by: Ahmed S. Darwish <ahmed.darwish@valeo.com>
>> ---
>>  drivers/net/can/usb/kvaser_usb.c | 114
>>  +++++++++++++++++++--------------------
>>  1 file changed, 55 insertions(+), 59 deletions(-)
>> 
>> diff --git a/drivers/net/can/usb/kvaser_usb.c
>> b/drivers/net/can/usb/kvaser_usb.c
>> index 971c5f9..0386d3f 100644
>> --- a/drivers/net/can/usb/kvaser_usb.c
>> +++ b/drivers/net/can/usb/kvaser_usb.c

...
> 
> Looks good.

Would be nice to see some "candump" traces as well. Ahmed, could you
please generate such traces doing:

1. Execute in a session:
   # candump -t d -e any,0:0,#FFFFFFFF

2. Execute in another session:
   # cangen -g 10 -D i can0

3. Disconnect the CAN cable

4. After a while reconnect the CAN cable

5. Stop candump and save the trace.

and to test bus-off:

1. Execute in a session:
   # candump -t d -e any,0:0,#FFFFFFFF

2. Execute in another session:
   # cangen -g 10 -D i can0

3. Short-circuit the CAN low and high wires of the CAN cable

4. After a while remove the short-circuit.

5. Stop candump and save the trace.

Thanks,

Wolfgang.
