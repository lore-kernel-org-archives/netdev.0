From: <samuel@sortiz.org>
Subject: Re: [PATCH] IRDA: Fix =?UTF-8?Q?genlmsg=5Fput=28=29=20return=20value=20ch?=
 =?UTF-8?Q?eck=2E?=
Date: Mon, 23 Jun 2008 22:13:42 +0200
Message-ID: <7851cb4e2d7432cc11a4527a4996be15@localhost>
References: <1214248629-6208-1-git-send-email-juliusv@google.com> <485FFCE3.2050800@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8bit
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Patrick McHardy <kaber@trash.net>, Julius Volz <juliusv@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 25.mail-out.ovh.net ([91.121.27.228]:46564 "HELO
	25.mail-out.ovh.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S1754856AbYFWUNv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Jun 2008 16:13:51 -0400
In-Reply-To: <485FFCE3.2050800@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Mon, 23 Jun 2008 21:43:31 +0200, Patrick McHardy <kaber@trash.net>

wrote:

> Julius Volz wrote:

>> Fix an incorrect return value check of genlmsg_put() in

> irda_nl_get_mode().

>> genlmsg_put() does not use ERR_PTR() to encode return values, it just

>> returns NULL on error.

>>

>> Signed-off-by: Julius Volz <juliusv@google.com>

>> ---

>>  net/irda/irnetlink.c |    4 ++--

>>  1 files changed, 2 insertions(+), 2 deletions(-)

>>

>> diff --git a/net/irda/irnetlink.c b/net/irda/irnetlink.c

>> index 9e1fb82..ea11cb4 100644

>> --- a/net/irda/irnetlink.c

>> +++ b/net/irda/irnetlink.c

>> @@ -101,8 +101,8 @@ static int irda_nl_get_mode(struct sk_buff *skb,

> struct genl_info *info)

>>

>>  	hdr = genlmsg_put(msg, info->snd_pid, info->snd_seq,

>>  			  &irda_nl_family, 0,  IRDA_NL_CMD_GET_MODE);

>> -	if (IS_ERR(hdr)) {

>> -		ret = PTR_ERR(hdr);

>> +	if (hdr == NULL) {

>> +		ret = -ENOMEM;

>>  		goto err_out;

>>  	}

> 

> Good catch, but the correct return value for insufficient

> space in the skb is -ENOSPC.

Thanks Julius, Patrick. I'll take this one and send it with

my next IrDA patch set.



Cheers,

Samuel.



