From: Marcel Holtmann <marcel@holtmann.org>
Subject: Re: [PATCH] bluetooth:Fix variable assignment for internal function returns in the function l2cap_bredr_sig_cmd
Date: Sun, 20 Dec 2015 08:18:01 +0100
Message-ID: <AF8B86E6-AD47-4548-BDB4-68851C8BD5BD@holtmann.org>
References: <1450498347-20994-1-git-send-email-xerofoify@gmail.com>
Mime-Version: 1.0 (Mac OS X Mail 9.2 \(3112\))
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 8BIT
Cc: "Gustavo F. Padovan" <gustavo@padovan.org>,
	Johan Hedberg <johan.hedberg@gmail.com>,
	"David S. Miller" <davem@davemloft.net>,
	linux-bluetooth@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Nicholas Krause <xerofoify@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [82.165.8.211] ([82.165.8.211]:51585 "EHLO mail.holtmann.org"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1753670AbbLTHSE convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 20 Dec 2015 02:18:04 -0500
In-Reply-To: <1450498347-20994-1-git-send-email-xerofoify@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Nick,

> This makes all internal functions that can return a error code to
> properly signal this to the caller of the function l2cap_bredr_sig_cmd
> by making their return value equal to the variable err before returning
> to the caller of the function l2cap_bredr_sig_cmd with this value
> as to allow us to correctly signal when a failure has occurred when
> this particular function is called.
> 
> Signed-off-by: Nicholas Krause <xerofoify@gmail.com>
> ---
> net/bluetooth/l2cap_core.c | 8 ++++----
> 1 file changed, 4 insertions(+), 4 deletions(-)
> 
> diff --git a/net/bluetooth/l2cap_core.c b/net/bluetooth/l2cap_core.c
> index 7c65ee2..488eebe 100644
> --- a/net/bluetooth/l2cap_core.c
> +++ b/net/bluetooth/l2cap_core.c
> @@ -5319,7 +5319,7 @@ static inline int l2cap_bredr_sig_cmd(struct l2cap_conn *conn,
> 
> 	switch (cmd->code) {
> 	case L2CAP_COMMAND_REJ:
> -		l2cap_command_rej(conn, cmd, cmd_len, data);
> +		err = l2cap_command_rej(conn, cmd, cmd_len, data);
> 		break;

this patch is wrong. Please try to understand on how L2CAP works and look up what the caller of l2cap_bredr_sig_cmd does with the return code. Responses can not cause another command reject.

Regards

Marcel
