From: Karsten Keil <kkeil@linux-pingi.de>
Subject: Re: [PATCH 3/8] Sometimes the ISDN chip only controls the D-channel
Date: Thu, 03 May 2012 08:31:57 +0200
Message-ID: <4FA2265D.6040000@linux-pingi.de>
References: <1335613404-10187-1-git-send-email-kkeil@linux-pingi.de> <1335613404-10187-4-git-send-email-kkeil@linux-pingi.de> <20120501.133007.569588994121475807.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from moutng.kundenserver.de ([212.227.126.171]:64583 "EHLO
	moutng.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751374Ab2ECGhX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 May 2012 02:37:23 -0400
In-Reply-To: <20120501.133007.569588994121475807.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello David,

Am 01.05.2012 19:30, schrieb David Miller:
> From: Karsten Keil <kkeil@linux-pingi.de>
> Date: Sat, 28 Apr 2012 13:43:19 +0200
> 
>> The B-channels are only accessed via the PCM backplane.
>> Add infrastruckture for this special mode.
>>
>> Signed-off-by: Karsten Keil <kkeil@linux-pingi.de>
> 
> I dread reviewing these ISDN patch sets because they are so
> full of problems, and it's so damn obvious how little care is
> put into preparing them.
> 
> What I see is that you put the minimum amount of work necessary
> into splitting up your huge ISDN patch set submission into more
> managable pieces, and as a result you are introducing problems.
> 

I did put the additional PCM infrastructure in this series, because
the approval test was done with it in place.
I did plan the update of the low level drivers in a separate patchset
from the beginning.

What do you prefer, adding the driver part now, as additional patch, or
removing this additional infrastruckture part and submit it in a later
series ?

>> diff --git a/drivers/isdn/mISDN/socket.c b/drivers/isdn/mISDN/socket.c
>> index abe2d69..502bcf1 100644
>> --- a/drivers/isdn/mISDN/socket.c
>> +++ b/drivers/isdn/mISDN/socket.c
>> @@ -270,6 +270,7 @@ data_sock_release(struct socket *sock)
>>  		break;
>>  	case ISDN_P_LAPD_TE:
>>  	case ISDN_P_LAPD_NT:
>> +	case ISDN_P_B_PCM:
>>  	case ISDN_P_B_RAW:
>>  	case ISDN_P_B_HDLC:
>>  	case ISDN_P_B_X75SLP:
> 
> Ok, that's fine.
> 
>> @@ -148,6 +149,8 @@ struct bchannel {
>>  	u_int			state;
>>  	void			*hw;
>>  	int			slot;	/* multiport card channel slot */
>> +	int			pcm_tx;	/* PCM tx slot nr */
>> +	int			pcm_rx;	/* PCM rx slot nr */
>>  	struct timer_list	timer;
>>  	/* receive data */
>>  	struct sk_buff		*rx_skb;
> 
> But what the hell is this?  These structure members are unused by
> this patch, and in fact no patch in your entire series uses them.
> 
>> @@ -360,8 +360,8 @@ clear_channelmap(u_int nr, u_char *map)
>>  #define MISDN_CTRL_LOOP			0x0001
>>  #define MISDN_CTRL_CONNECT		0x0002
>>  #define MISDN_CTRL_DISCONNECT		0x0004
>> -#define MISDN_CTRL_PCMCONNECT		0x0010
>> -#define MISDN_CTRL_PCMDISCONNECT	0x0020
>> +#define MISDN_CTRL_GET_PCM_SLOTS	0x0010
>> +#define MISDN_CTRL_SET_PCM_SLOTS	0x0020
>>  #define MISDN_CTRL_SETPEER		0x0040
>>  #define MISDN_CTRL_UNSETPEER		0x0080
>>  #define MISDN_CTRL_RX_OFF		0x0100
> 
> Another completely unrelated change, nothing in this patch uses
> these new defines.
> 
>> @@ -381,6 +381,10 @@ clear_channelmap(u_int nr, u_char *map)
>>  #define MISDN_CTRL_HFC_WD_INIT		0x4009
>>  #define MISDN_CTRL_HFC_WD_RESET		0x400A
>>  
>> +/* special PCM slot numbers */
>> +#define MISDN_PCM_SLOT_DISABLE	-1	/* PCM disabled */
>> +#define MISDN_PCM_SLOT_IGNORE	-2	/* PCM setting will be not changed */
>> +
>>  /* socket options */
>>  #define MISDN_TIME_STAMP		0x0001
>>  
> 
> Same thing.
> 
>> @@ -389,6 +393,7 @@ struct mISDN_ctrl_req {
>>  	int		channel;
>>  	int		p1;
>>  	int		p2;
>> +	int		p3;
>>  };
>>  
>>  /* muxer options */
> 
> And again, same problem.
> 
> You really need to get your act in gear and prepare your patches
> properly, so that they don't have unrelated changes in them.
> 
> This is not amateur hour.
> 
> 
