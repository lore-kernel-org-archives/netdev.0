From: Wolfgang Grandegger <wg-5Yr1BZd7O62+XT7JhA+gdA@public.gmane.org>
Subject: Re: [PATCH net-next-2.6 v5 1/1] can: c_can: Added support for Bosch
	C_CAN controller
Date: Tue, 01 Feb 2011 08:23:04 +0100
Message-ID: <4D47B4D8.1010304@grandegger.com>
References: <1295515238-481-1-git-send-email-bhupesh.sharma@st.com>	<4D3B2F66.8090603@grandegger.com>	<D5ECB3C7A6F99444980976A8C6D896384DEE082650@EAPEX1MAIL1.st.com>	<4D3E8118.10904@grandegger.com>
	<D5ECB3C7A6F99444980976A8C6D896384DEE0832F8@EAPEX1MAIL1.st.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "Socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org" <Socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>,
	"netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Marc Kleine-Budde <mkl-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>, David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
To: Bhupesh SHARMA <bhupesh.sharma-qxv4g6HH51o@public.gmane.org>
Return-path: <socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
In-Reply-To: <D5ECB3C7A6F99444980976A8C6D896384DEE0832F8-8vAmw3ZAcdzhJTuQ9jeba9BPR1lH4CV8@public.gmane.org>
List-Unsubscribe: <https://lists.berlios.de/mailman/options/socketcan-core>,
	<mailto:socketcan-core-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=unsubscribe>
List-Archive: <https://lists.berlios.de/pipermail/socketcan-core>
List-Post: <mailto:socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
List-Help: <mailto:socketcan-core-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=help>
List-Subscribe: <https://lists.berlios.de/mailman/listinfo/socketcan-core>,
	<mailto:socketcan-core-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=subscribe>
Sender: socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
Errors-To: socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi Bhupesh,

On 02/01/2011 05:29 AM, Bhupesh SHARMA wrote:
> Hello Wolfgang,
> 
>> ...
>>>>> +		/* handle error on the bus */
>>>>> +		lec_type = c_can_has_and_handle_berr(priv);
>>>>> +		if (lec_type && (error_type != C_CAN_NO_ERROR))
>>>>> +			work_done += c_can_err(dev, error_type, lec_type);
>>>>
>>>> State changes are only reported if berr_reporting is enabled and a
>> bus
>>>> error occured. This needs to be fixed.
>>>
>>> As I mentioned earlier in a response to a review comment, the Bus
>> Error
>>> reporting for C_CAN seems different from sja1000 and flexcan
>> approaches.
>>> Do you think it will be useful to drop CAN_CTRLMODE_BERR_REPORTING
>> from
>>> priv->can.ctrlmode_supported as done by *pch* driver? Or do you have
>>> a better idea..
>>
>> You bus error reporting is OK. The problem is that it does not only
>> affect bus errors but also state changes. State change messages should
>> alway be send independent of priv->can.ctrlmode. It's just a matter of
>> moving code to the right location. E.g. the code snippet above inside
>> c_can_err() before you check for bus errors.
>>
>>>> Feel free to send the output of "candump any,0:0,#FFFFFFFF" when
>>>> sending
>>>> messages without cable connected and with a bus error provocuted.
>>>
>>> OK. I will try to cross-compile candump for my arm-v7 architecture
>>> and will send the output.
>>
> 
> I did some changes to the code to ensure that the state change and lec
> handling are handled separately and properly.

Great.

> Please find the candump any,0:0,#FFFFFFFF output below:
> 
> 1. With No-Cable connected, I keep getting:
>   can0  20000004  [8] 00 28 00 00 00 00 00 00   ERRORFRAME
>   can0  20000004  [8] 00 28 00 00 00 00 00 00   ERRORFRAME
>   can0  20000004  [8] 00 28 00 00 00 00 00 00   ERRORFRAME
>   can0  20000004  [8] 00 28 00 00 00 00 00 00   ERRORFRAME
>   can0  20000004  [8] 00 28 00 00 00 00 00 00   ERRORFRAME
>   can0  20000004  [8] 00 28 00 00 00 00 00 00   ERRORFRAME
>   can0  20000004  [8] 00 28 00 00 00 00 00 00   ERRORFRAME
>   can0  20000004  [8] 00 28 00 00 00 00 00 00   ERRORFRAME
>   can0  20000004  [8] 00 28 00 00 00 00 00 00   ERRORFRAME
>   can0  20000004  [8] 00 28 00 00 00 00 00 00   ERRORFRAME
>   can0  20000004  [8] 00 28 00 00 00 00 00 00   ERRORFRAME
>   can0  20000004  [8] 00 28 00 00 00 00 00 00   ERRORFRAME
>   can0  20000004  [8] 00 28 00 00 00 00 00 00   ERRORFRAME
>   can0  20000004  [8] 00 28 00 00 00 00 00 00   ERRORFRAME
>   can0  20000004  [8] 00 28 00 00 00 00 00 00   ERRORFRAME
>   can0  20000004  [8] 00 28 00 00 00 00 00 00   ERRORFRAME
>   can0  20000004  [8] 00 28 00 00 00 00 00 00   ERRORFRAME
>   can0  20000004  [8] 00 28 00 00 00 00 00 00   ERRORFRAME
>   can0  20000004  [8] 00 28 00 00 00 00 00 00   ERRORFRAME
>   can0  20000004  [8] 00 28 00 00 00 00 00 00   ERRORFRAME
>   can0  20000004  [8] 00 28 00 00 00 00 00 00   ERRORFRAME
>   can0  20000004  [8] 00 28 00 00 00 00 00 00   ERRORFRAME
>   can0  20000004  [8] 00 28 00 00 00 00 00 00   ERRORFRAME
>   can0  20000004  [8] 00 28 00 00 00 00 00 00   ERRORFRAME
>   can0  20000004  [8] 00 28 00 00 00 00 00 00   ERRORFRAME

The SJA1000 reports:

---- Error-active -> error-warning -> error-passive
---- cable disconnected
-bash-3.2# ./candump -t d any,0:0,#FFFFFFFF

 (0.000000)  can0  20000004  [8] 00 08 00 00 00 00 60 00   ERROR-WARNING
 (0.002588)  can0  20000004  [8] 00 20 00 00 00 00 80 00   ERROR-PASSIVE

I wonder why you get data[1]=28 immediately. Also it's nice to have the
txerr and rxerr in data[6..7].

> 2. With Tx and Rx shorted to simulate bus-error, I get:
>   can0  20000044  [8] 00 20 00 00 00 00 00 00   ERRORFRAME

Also here, you should see:

---- Error-active -> error-warning -> error-passive -> bus-off

-bash-3.2# ./candump -t d any,0:0,#FFFFFFFF
 (0.000000)  can0  20000004  [8] 00 08 00 00 00 00 88 00   ERROR-WARNING
 (0.001362)  can0  20000004  [8] 00 20 00 00 00 00 88 00   ERROR-PASSIVE
 (0.001560)  can0  20000044  [8] 00 00 00 00 00 00 7F 00   BUS-OFF

> In case 2, when I enable debug messages I get the correct state change sequence:
> entered error warning state
> entered error passive state
> entered bus off state

As the log confirms.

> Does this result seem fine to you?

Not yet. Also the output with "berr-reporting on" should be checked. And
the output when you recover from bus-off manually (using "ip link set
type can restart")

Thanks,

Wolfgang.
