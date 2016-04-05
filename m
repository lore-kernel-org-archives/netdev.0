From: Bastien Philbert <bastienphilbert@gmail.com>
Subject: Re: [PATCH] sctp: Fix error handling for switch statement case in the
 function sctp_cmd_interprete
Date: Tue, 5 Apr 2016 17:58:38 -0400
Message-ID: <5704350E.5080403@gmail.com>
References: <1459892201-21397-1-git-send-email-bastienphilbert@gmail.com>
 <570433F0.6040506@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: nhorman@tuxdriver.com, davem@davemloft.net,
	linux-sctp@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Daniel Borkmann <daniel@iogearbox.net>, vyasevich@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <570433F0.6040506@iogearbox.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



On 2016-04-05 05:53 PM, Daniel Borkmann wrote:
> On 04/05/2016 11:36 PM, Bastien Philbert wrote:
>> This fixes error handling for the switch statement case
>> SCTP_CMD_SEND_PKT by making the error value of the call
>> to sctp_packet_transmit equal the variable error due to
>> this function being able to fail with a error code. In
> 
> What actual issue have you observed that you fix?
> 
The issue here is basically that sctp_packet_transmit
can return a error if it unsuccessfully transmit the
sk_buff as a parameter. Seems that we should signal
the user/caller(s) when a sctp packet transmission
fails here. If you would like I can resend with a better
commit message in a V2 if this explains the issue better.
Bastien
>> addition allow the call to sctp_ootb_pkt_free afterwards
>> to free up the no longer in use sctp packet even if the
>> call to the function sctp_packet_transmit fails in order
>> to avoid a memory leak here for not freeing the sctp
> 
> Not sure how this relates to your code?
> 
>> Signed-off-by: Bastien Philbert <bastienphilbert@gmail.com>
>> ---
>>   net/sctp/sm_sideeffect.c | 2 +-
>>   1 file changed, 1 insertion(+), 1 deletion(-)
>>
>> diff --git a/net/sctp/sm_sideeffect.c b/net/sctp/sm_sideeffect.c
>> index 7fe56d0..f3a8b58 100644
>> --- a/net/sctp/sm_sideeffect.c
>> +++ b/net/sctp/sm_sideeffect.c
>> @@ -1434,7 +1434,7 @@ static int sctp_cmd_interpreter(sctp_event_t event_type,
>>           case SCTP_CMD_SEND_PKT:
>>               /* Send a full packet to our peer.  */
>>               packet = cmd->obj.packet;
>> -            sctp_packet_transmit(packet, gfp);
>> +            error = sctp_packet_transmit(packet, gfp);
>>               sctp_ootb_pkt_free(packet);
>>               break;
>>
>>
> 
