From: Wolfgang Grandegger <wg-5Yr1BZd7O62+XT7JhA+gdA@public.gmane.org>
Subject: Re: [PATCH net-next-2.6 v4] can: Topcliff: PCH_CAN driver: Add Flow
	control/Fix	Endianess issue/Separate IF register/Enumerate LEC
	macro/Move
	MSI	processing/Use BIT(X)/Change Message Object index/Add prefix PCH_
Date: Tue, 16 Nov 2010 13:22:22 +0100
Message-ID: <4CE2777E.30501@grandegger.com>
References: <4CE275A4.9010400@dsn.okisemi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: andrew.chih.howe.khor-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org,
	Masayuki Ohtake <masa-korg-ECg8zkTtlr0C6LszWs/t0g@public.gmane.org>,
	Samuel Ortiz <sameo-VuQAYsv1563Yd54FQh9/CA@public.gmane.org>, margie.foster-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org, yong.y.wang-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org,
	kok.howg.ewe-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, joel.clark-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org,
	"David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	Christian Pellegrin <chripell-VaTbYqLCNhc@public.gmane.org>, qi.wang-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org
To: Tomoya MORINAGA <tomoya-linux-ECg8zkTtlr0C6LszWs/t0g@public.gmane.org>
Return-path: <socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
In-Reply-To: <4CE275A4.9010400-ECg8zkTtlr0C6LszWs/t0g@public.gmane.org>
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

On 11/16/2010 01:14 PM, Tomoya MORINAGA wrote:
> Add flow control processing.
> Currently, there is no flow control processing.
> Thus, Add flow control processing as
> when there is no empty of tx buffer,
> netif_stop_queue is called.
> When there is empty buffer, netif_wake_queue is called.
> 
> 
> Fix endianness issue.
> there is endianness issue both Tx and Rx.
> Currently, data is set like below.
> Register:
>  MSB---LSB
>  x x D0 D1
>  x x D2 D3
>  x x D4 D5
>  x x D6 D7
> 
> But Data to be sent must be set like below.
> Register:
>  MSB---LSB
>  x x D1 D0
>  x x D3 D2
>  x x D5 D4
>  x x D7 D6  (x means reserved area.)
> 
> 
> Separate interface register from whole of register structure.
> CAN register of Intel PCH EG20T has 2 sets of interface register.
> To reduce whole of code size, separate interface register.
> As a result, the number of function also can be reduced. 
> 
> 
> Enumerate LEC macro from #define macro.
> For easy to readable, all LEC #define macros are replease to enums like below.
> enum pch_can_err {
> 	PCH_STUF_ERR = 1,
> 	PCH_FORM_ERR,
> 	PCH_ACK_ERR,
> 	PCH_BIT1_ERR,
> 	PCH_BIT0_ERR,
> 	PCH_CRC_ERR,
> 	PCH_LEC_ALL,
> };
> 
> 
> Move MSI processing to probe/remove processing.
> Currently, in case this driver is integrated as module, and 
> when this module is re-installed, no interrupts is to be occurred.
> For the above issue, move MSI processing to open/release processing.
> 
> 
> Replace bit assignment value to BIT(X).
> For easy to readable, replace all bit assigned macros to BIT(X)
> 
> 
> Change Message Object index macro name.
> For easy to readable, add Message Object index like below.
> PCH_RX_OBJ_START
> PCH_RX_OBJ_END
> PCH_TX_OBJ_START
> PCH_TX_OBJ_END
> 
> 
> Add prefix PCH_ to all of #define macros.
> For easy to readable, add prefix "PCH_" to all of #define macros.
> 
> 
> 
> Signed-off-by: Tomoya MORINAGA <tomoya-linux-ECg8zkTtlr0C6LszWs/t0g@public.gmane.org>

Acked-by: Wolfgang Grandegger <wg-5Yr1BZd7O62+XT7JhA+gdA@public.gmane.org>

Thanks for your contribution.

Wolfgang.
