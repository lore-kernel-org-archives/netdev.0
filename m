From: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Subject: Re: [PATCH 1/3] drivers: net: stmmac: add blackfin support
Date: Wed, 23 May 2012 10:21:29 +0200
Message-ID: <4FBC9E09.6010300@st.com>
References: <1337672336-7378-1-git-send-email-lliubbo@gmail.com> <4FBB8852.7060403@st.com> <CAA_GA1dWh=8rh9TQ4D81X22v-Cy1ZRUbBcZnVegqfFnKn_hVSw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, francesco.virlinzi@st.com,
	rayagond@vayavyalabs.com, sr@denx.de, netdev@vger.kernel.org,
	uclinux-dist-devel@blackfin.uclinux.org
To: Bob Liu <lliubbo@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog111.obsmtp.com ([207.126.144.131]:38626 "EHLO
	eu1sys200aog111.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755428Ab2EWIWF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 May 2012 04:22:05 -0400
In-Reply-To: <CAA_GA1dWh=8rh9TQ4D81X22v-Cy1ZRUbBcZnVegqfFnKn_hVSw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello Bob Liu

On 5/23/2012 9:58 AM, Bob Liu wrote:
> Hi Peppe,
> 
> On 5/22/12, Giuseppe CAVALLARO <peppe.cavallaro@st.com> wrote:
>> Hello Bob Liu
>>
>> On 5/22/2012 9:38 AM, Bob Liu wrote:
>>> Blackfin arch use stmmac on its reference board bf609-ezkit, the stmmac
>>> ip
>>> version is 3.61a.
>>>
>>> But the spec seems a little different, some register addr and define are
>>> not
>>> the same with current code.
>>>
>>> This patch add the support for blackfin arch following the spec.
>>
>> The 3.61a is supported and you have to point to the dw1000.h header file.
>>
>> To support this GMAC generation you only need to pass from the platform
>> the field has_gmac (see stmmac.txt).
>> Also the 3.61a has the HW cap registers so many internal fields (e.g. rx
>> coe, enhanced descr ...) will be fixed at run-time (although you can
>> pass them from the platform).
>>
>> Your patch adds the GMAC SPEC in the old MAC 10/100.
>>
>> Also I am reluctant to have specific ifdef <ARCH> within the code.
>> I do think the driver already has all the platform fields to run on your
>> board. If you need extra conf pls feel free to enhance the
>> plat_stmmacenet_data.
>>
> 
> Thank you for your reply.
> I tried to use driver dwmac1000 by setting .has_gmac = 1 today.
> Ping can finish with no error but when rcp a file or telnet it will hang.

Hmm this should be debugged ... maybe you can verify the tx / rx
checksum. I mean if your IP has these modules or if, for somereason, the
HW cap register is not present and there are not properly fixed

> 
> Using below patch without setting .has_gmac, everything works fine.

With your patch (that added the dwmac1000 into the dwmac100) you are
indeed using the MAC100 setting where by default there is no HW
checksumming ;-)

> Any ideas?  Thank you.

you are welcome

Peppe

> diff --git a/drivers/net/ethernet/stmicro/stmmac/dwmac100.h
> b/drivers/net/ethernet/stmicro/stmmac/dwmac100.h
> index 7c6d857..00499b8 100644
> --- a/drivers/net/ethernet/stmicro/stmmac/dwmac100.h
> +++ b/drivers/net/ethernet/stmicro/stmmac/dwmac100.h
> @@ -29,6 +29,18 @@
>   *                             MAC BLOCK defines
>   *---------------------------------------------------------------------------*/
>  /* MAC CSR offset */
> +#if defined(CONFIG_BLACKFIN)
> +#define MAC_CONTROL    0x00000000      /* MAC Control */
> +#define MAC_FRAME_FILTER       0x0000004       /* Frame filter */
> +#define MAC_HASH_HIGH  0x00000008      /* Multicast Hash Table High */
> +#define MAC_HASH_LOW   0x0000000c      /* Multicast Hash Table Low */
> +#define MAC_MII_ADDR   0x00000010      /* MII Address */
> +#define MAC_MII_DATA   0x00000014      /* MII Data */
> +#define MAC_FLOW_CTRL  0x00000018      /* Flow Control */
> +#define MAC_VLAN1      0x0000001c      /* VLAN1 Tag */
> +#define MAC_ADDR_HIGH  0x00000040      /* MAC Address High */
> +#define MAC_ADDR_LOW   0x00000044      /* MAC Address Low */
> +#else
>  #define MAC_CONTROL    0x00000000      /* MAC Control */
>  #define MAC_ADDR_HIGH  0x00000004      /* MAC Address High */
>  #define MAC_ADDR_LOW   0x00000008      /* MAC Address Low */
> @@ -39,6 +51,7 @@
>  #define MAC_FLOW_CTRL  0x0000001c      /* Flow Control */
>  #define MAC_VLAN1      0x00000020      /* VLAN1 Tag */
>  #define MAC_VLAN2      0x00000024      /* VLAN2 Tag */
> +#endif
> 
>  /* MAC CTRL defines */
>  #define MAC_CONTROL_RA 0x80000000      /* Receive All Mode */
> @@ -67,7 +80,11 @@
>  #define MAC_CONTROL_TE         0x00000008      /* Transmitter Enable */
>  #define MAC_CONTROL_RE         0x00000004      /* Receiver Enable */
> 
> +#ifdef CONFIG_BLACKFIN
> +#define MAC_CORE_INIT ((1 << 14) | MAC_CONTROL_DBF)
> +#else
>  #define MAC_CORE_INIT (MAC_CONTROL_HBD | MAC_CONTROL_ASTP)
> +#endif
> 
>  /* MAC FLOW CTRL defines */
>  #define MAC_FLOW_CTRL_PT_MASK  0xffff0000      /* Pause Time Mask */
> 
