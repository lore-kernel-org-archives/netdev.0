From: Vlad Yasevich <vyasevic@redhat.com>
Subject: Re: [PATCH 4/5] sctp: Improve a size determination in
 sctp_inetaddr_event()
Date: Mon, 22 May 2017 17:00:36 -0400
Message-ID: <90582e7d-1e22-cf23-2f51-6630ab1b9bf4@redhat.com>
References: <2845df67-d35d-536a-0a53-b2eb83fe1ba5@users.sourceforge.net>
 <a96c883f-0495-ad8c-e3a4-c80f27b76ed2@users.sourceforge.net>
Reply-To: vyasevic@redhat.com
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: LKML <linux-kernel@vger.kernel.org>,
        kernel-janitors@vger.kernel.org
To: SF Markus Elfring <elfring@users.sourceforge.net>,
        linux-sctp@vger.kernel.org, netdev@vger.kernel.org,
        "David S. Miller" <davem@davemloft.net>,
        Neil Horman <nhorman@tuxdriver.com>,
        Vlad Yasevich <vyasevich@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:41100 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1762648AbdEVVAi (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 22 May 2017 17:00:38 -0400
In-Reply-To: <a96c883f-0495-ad8c-e3a4-c80f27b76ed2@users.sourceforge.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 05/22/2017 12:40 PM, SF Markus Elfring wrote:
> From: Markus Elfring <elfring@users.sourceforge.net>
> Date: Mon, 22 May 2017 18:08:24 +0200
> 
> Replace the specification of a data structure by a pointer dereference
> as the parameter for the operator "sizeof" to make the corresponding size
> determination a bit safer according to the Linux coding style convention.
> 
> Signed-off-by: Markus Elfring <elfring@users.sourceforge.net>
> ---
>  net/sctp/protocol.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/net/sctp/protocol.c b/net/sctp/protocol.c
> index 64756c42cec9..057479b7bd72 100644
> --- a/net/sctp/protocol.c
> +++ b/net/sctp/protocol.c
> @@ -784,7 +784,7 @@ static int sctp_inetaddr_event(struct notifier_block *this, unsigned long ev,
>  
>  	switch (ev) {
>  	case NETDEV_UP:
> -		addr = kmalloc(sizeof(struct sctp_sockaddr_entry), GFP_ATOMIC);
> +		addr = kmalloc(sizeof(*addr), GFP_ATOMIC);
>  		if (addr) {
>  			addr->a.v4.sin_family = AF_INET;
>  			addr->a.v4.sin_port = 0;
> 

Acked-by: Vlad Yasevich <vyasevich@gmail.com>

-vlad
