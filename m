From: Bastien Philbert <bastienphilbert@gmail.com>
Subject: Re: [PATCH] sctp: Fix error handling for switch statement case in the
 function sctp_cmd_interprete
Date: Tue, 5 Apr 2016 19:03:44 -0400
Message-ID: <57044450.1080001@gmail.com>
References: <1459892201-21397-1-git-send-email-bastienphilbert@gmail.com>
 <20160405221220.GA15005@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: vyasevich@gmail.com, nhorman@tuxdriver.com, davem@davemloft.net,
	linux-sctp@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160405221220.GA15005@localhost.localdomain>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



On 2016-04-05 06:12 PM, Marcelo Ricardo Leitner wrote:
> On Tue, Apr 05, 2016 at 05:36:41PM -0400, Bastien Philbert wrote:
>> This fixes error handling for the switch statement case
>> SCTP_CMD_SEND_PKT by making the error value of the call
>> to sctp_packet_transmit equal the variable error due to
>> this function being able to fail with a error code. In
>> addition allow the call to sctp_ootb_pkt_free afterwards
>> to free up the no longer in use sctp packet even if the
>> call to the function sctp_packet_transmit fails in order
>> to avoid a memory leak here for not freeing the sctp
> 
> This leak shouldn't exist as sctp_packet_transmit() will free the packet
> if it returns ENOMEM, through the nomem: handling.
> 
> But about making it visible to the user, that looks interesting to me
> although I cannot foresee yet its effects, like the comment at the end
> of sctp_packet_transmit() on not returning EHOSTUNREACH. Did you check
> it?
> 
I was aware of the -EHOSTUNREACH issue but assumed that this needs to be
known to functions internal to the kernel. TO rephase does it matter if
the callers of this function known if sctp_packet_transmit or care if it 
fails or is this just unnecessary as we do cleanup else where which is 
enough so the new error check is not needed? Again if their is a certain
test would like me to run on this patch too to make sure it's OK I don't
mind, just let me known :).
Cheers,
Bastien
>>
>> Signed-off-by: Bastien Philbert <bastienphilbert@gmail.com>
>> ---
>>  net/sctp/sm_sideeffect.c | 2 +-
>>  1 file changed, 1 insertion(+), 1 deletion(-)
>>
>> diff --git a/net/sctp/sm_sideeffect.c b/net/sctp/sm_sideeffect.c
>> index 7fe56d0..f3a8b58 100644
>> --- a/net/sctp/sm_sideeffect.c
>> +++ b/net/sctp/sm_sideeffect.c
>> @@ -1434,7 +1434,7 @@ static int sctp_cmd_interpreter(sctp_event_t event_type,
>>  		case SCTP_CMD_SEND_PKT:
>>  			/* Send a full packet to our peer.  */
>>  			packet = cmd->obj.packet;
>> -			sctp_packet_transmit(packet, gfp);
>> +			error = sctp_packet_transmit(packet, gfp);
>>  			sctp_ootb_pkt_free(packet);
>>  			break;
>>  
>> -- 
>> 2.5.0
>>
>> --
>> To unsubscribe from this list: send the line "unsubscribe linux-sctp" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>>
