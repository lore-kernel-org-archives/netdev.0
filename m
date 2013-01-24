From: Xufeng Zhang <xufengzhang.main@gmail.com>
Subject: Re: [PATCH] sctp: set association state to established in dupcook_a handler
Date: Thu, 24 Jan 2013 09:34:30 +0800
Message-ID: <CA+=dFzgWRCL62LnpOLB=1cOn=DfSnWePJ56d7MN8rSTp6uEtdA@mail.gmail.com>
References: <1358926720-25557-1-git-send-email-xufengzhang.main@gmail.com>
	<20130123134650.GA3512@hmsreliant.think-freely.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: vyasevich@gmail.com, sri@us.ibm.com, davem@davemloft.net,
	linux-sctp@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Neil Horman <nhorman@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f54.google.com ([209.85.214.54]:58933 "EHLO
	mail-bk0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752241Ab3AXBec (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Jan 2013 20:34:32 -0500
In-Reply-To: <20130123134650.GA3512@hmsreliant.think-freely.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 1/23/13, Neil Horman <nhorman@tuxdriver.com> wrote:
> On Wed, Jan 23, 2013 at 03:38:40PM +0800, xufengzhang.main@gmail.com wrote:
>> From: Xufeng Zhang <xufeng.zhang@windriver.com>
>>
>> While sctp handling a duplicate COOKIE-ECHO and the action is
>> 'Association restart', sctp_sf_do_dupcook_a() will processing
>> the unexpected COOKIE-ECHO for peer restart, but it does not set
>> the association state to SCTP_STATE_ESTABLISHED, so the association
>> could stuck in SCTP_STATE_SHUTDOWN_PENDING state forever.
>> This violates the sctp specification:
>>   RFC 4960 5.2.4. Handle a COOKIE ECHO when a TCB Exists
>>   Action
>>   A) In this case, the peer may have restarted. .....
>>      After this, the endpoint shall enter the ESTABLISHED state.
>>
>> Fix this problem by adding a SCTP_CMD_NEW_STATE cmd to the command
>> list so as to set the restart association to SCTP_STATE_ESTABLISHED
>> state properly.
>>
>> Signed-off-by: Xufeng Zhang <xufeng.zhang@windriver.com>
>> ---
>>  net/sctp/sm_statefuns.c |    2 ++
>>  1 files changed, 2 insertions(+), 0 deletions(-)
>>
>> diff --git a/net/sctp/sm_statefuns.c b/net/sctp/sm_statefuns.c
>> index 618ec7e..528f1c8 100644
>> --- a/net/sctp/sm_statefuns.c
>> +++ b/net/sctp/sm_statefuns.c
>> @@ -1779,6 +1779,8 @@ static sctp_disposition_t
>> sctp_sf_do_dupcook_a(struct net *net,
>>
>>  	/* Update the content of current association. */
>>  	sctp_add_cmd_sf(commands, SCTP_CMD_UPDATE_ASSOC, SCTP_ASOC(new_asoc));
>> +	sctp_add_cmd_sf(commands, SCTP_CMD_NEW_STATE,
>> +			SCTP_STATE(SCTP_STATE_ESTABLISHED));
>>  	sctp_add_cmd_sf(commands, SCTP_CMD_REPLY, SCTP_CHUNK(repl));
>>  	sctp_add_cmd_sf(commands, SCTP_CMD_EVENT_ULP, SCTP_ULPEVENT(ev));
>>  	return SCTP_DISPOSITION_CONSUME;
>> --
>> 1.7.0.2
>>
>>
>
> Looks reasonable to me, thanks
>
> nit: The RFC indicate the association should enter the ESTABLISHED state
> after
> preforming all other actions, so it seems that the state change should
> occur
> after the ULP event is sent

Good catch! I'll do what vlad suggested.
Thanks for your review!


Thanks,
Xufeng

>
> Neil
>
>
