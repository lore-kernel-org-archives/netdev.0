From: Bhupesh SHARMA <bhupesh.sharma-qxv4g6HH51o@public.gmane.org>
Subject: RE: [PATCH net-next-2.6 v5 1/1] can: c_can: Added support for Bosch
	C_CAN controller
Date: Tue, 1 Feb 2011 12:29:35 +0800
Message-ID: <D5ECB3C7A6F99444980976A8C6D896384DEE0832F8@EAPEX1MAIL1.st.com>
References: <1295515238-481-1-git-send-email-bhupesh.sharma@st.com>
	<4D3B2F66.8090603@grandegger.com>
	<D5ECB3C7A6F99444980976A8C6D896384DEE082650@EAPEX1MAIL1.st.com>
	<4D3E8118.10904@grandegger.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "Socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org" <Socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>,
	"netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Marc Kleine-Budde <mkl-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>, David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
To: Wolfgang Grandegger <wg-5Yr1BZd7O62+XT7JhA+gdA@public.gmane.org>
Return-path: <socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
In-Reply-To: <4D3E8118.10904-5Yr1BZd7O62+XT7JhA+gdA@public.gmane.org>
Content-Language: en-US
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

Hello Wolfgang,

> ...
> >>> +		/* handle error on the bus */
> >>> +		lec_type = c_can_has_and_handle_berr(priv);
> >>> +		if (lec_type && (error_type != C_CAN_NO_ERROR))
> >>> +			work_done += c_can_err(dev, error_type, lec_type);
> >>
> >> State changes are only reported if berr_reporting is enabled and a
> bus
> >> error occured. This needs to be fixed.
> >
> > As I mentioned earlier in a response to a review comment, the Bus
> Error
> > reporting for C_CAN seems different from sja1000 and flexcan
> approaches.
> > Do you think it will be useful to drop CAN_CTRLMODE_BERR_REPORTING
> from
> > priv->can.ctrlmode_supported as done by *pch* driver? Or do you have
> > a better idea..
> 
> You bus error reporting is OK. The problem is that it does not only
> affect bus errors but also state changes. State change messages should
> alway be send independent of priv->can.ctrlmode. It's just a matter of
> moving code to the right location. E.g. the code snippet above inside
> c_can_err() before you check for bus errors.
> 
> >> Feel free to send the output of "candump any,0:0,#FFFFFFFF" when
> >> sending
> >> messages without cable connected and with a bus error provocuted.
> >
> > OK. I will try to cross-compile candump for my arm-v7 architecture
> > and will send the output.
> 

I did some changes to the code to ensure that the state change and lec
handling are handled separately and properly.
Please find the candump any,0:0,#FFFFFFFF output below:

1. With No-Cable connected, I keep getting:
  can0  20000004  [8] 00 28 00 00 00 00 00 00   ERRORFRAME
  can0  20000004  [8] 00 28 00 00 00 00 00 00   ERRORFRAME
  can0  20000004  [8] 00 28 00 00 00 00 00 00   ERRORFRAME
  can0  20000004  [8] 00 28 00 00 00 00 00 00   ERRORFRAME
  can0  20000004  [8] 00 28 00 00 00 00 00 00   ERRORFRAME
  can0  20000004  [8] 00 28 00 00 00 00 00 00   ERRORFRAME
  can0  20000004  [8] 00 28 00 00 00 00 00 00   ERRORFRAME
  can0  20000004  [8] 00 28 00 00 00 00 00 00   ERRORFRAME
  can0  20000004  [8] 00 28 00 00 00 00 00 00   ERRORFRAME
  can0  20000004  [8] 00 28 00 00 00 00 00 00   ERRORFRAME
  can0  20000004  [8] 00 28 00 00 00 00 00 00   ERRORFRAME
  can0  20000004  [8] 00 28 00 00 00 00 00 00   ERRORFRAME
  can0  20000004  [8] 00 28 00 00 00 00 00 00   ERRORFRAME
  can0  20000004  [8] 00 28 00 00 00 00 00 00   ERRORFRAME
  can0  20000004  [8] 00 28 00 00 00 00 00 00   ERRORFRAME
  can0  20000004  [8] 00 28 00 00 00 00 00 00   ERRORFRAME
  can0  20000004  [8] 00 28 00 00 00 00 00 00   ERRORFRAME
  can0  20000004  [8] 00 28 00 00 00 00 00 00   ERRORFRAME
  can0  20000004  [8] 00 28 00 00 00 00 00 00   ERRORFRAME
  can0  20000004  [8] 00 28 00 00 00 00 00 00   ERRORFRAME
  can0  20000004  [8] 00 28 00 00 00 00 00 00   ERRORFRAME
  can0  20000004  [8] 00 28 00 00 00 00 00 00   ERRORFRAME
  can0  20000004  [8] 00 28 00 00 00 00 00 00   ERRORFRAME
  can0  20000004  [8] 00 28 00 00 00 00 00 00   ERRORFRAME
  can0  20000004  [8] 00 28 00 00 00 00 00 00   ERRORFRAME

2. With Tx and Rx shorted to simulate bus-error, I get:
  can0  20000044  [8] 00 20 00 00 00 00 00 00   ERRORFRAME

In case 2, when I enable debug messages I get the correct state change sequence:
entered error warning state
entered error passive state
entered bus off state

Does this result seem fine to you?

Regards,
Bhupesh
