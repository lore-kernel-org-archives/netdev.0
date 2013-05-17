From: Chen Gang <gang.chen@asianux.com>
Subject: Re: [PATCH v3] Bluetooth: hidp: using strlcpy instead of strncpy,
 also beautify code.
Date: Fri, 17 May 2013 15:04:35 +0800
Message-ID: <5195D683.2000001@asianux.com>
References: <518906A8.7060708@asianux.com> <CANq1E4SmY+CD0uf53_b6GeFkQ-LYnpdxsDGSRMWdn2i1mnb6WQ@mail.gmail.com> <5189A417.503@asianux.com> <5189C7C6.8090408@asianux.com> <alpine.LNX.2.00.1305091041140.23038@pobox.suse.cz> <51904ACF.6010904@asianux.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: Gustavo Padovan <gustavo@padovan.org>,
	David Herrmann <dh.herrmann@gmail.com>,
	Marcel Holtmann <marcel@holtmann.org>,
	Johan Hedberg <johan.hedberg@gmail.com>,
	David Miller <davem@davemloft.net>,
	andrei.emeltchenko@intel.com,
	"linux-bluetooth@vger.kernel.org" <linux-bluetooth@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>
To: Jiri Kosina <jkosina@suse.cz>
Return-path: <netdev-owner@vger.kernel.org>
Received: from intranet.asianux.com ([58.214.24.6]:18149 "EHLO
	intranet.asianux.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754750Ab3EQHF1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 May 2013 03:05:27 -0400
In-Reply-To: <51904ACF.6010904@asianux.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello Maintainers:

Please help check this patch when you have time, thanks.

It is "Reviewed-by: David Herrmann <dh.herrmann@gmail.com>"

And also is "Acked-by: Jiri Kosina <jkosina@suse.cz>"

If need me do any additional things, please tell me.


Thanks.

On 05/13/2013 10:07 AM, Chen Gang wrote:
> 
> For NUL terminated string, need always let it ended by zero.
> 
> Since have already called memcpy() to initialize 'ci', so need not
> redundant initialization.
> 
> Better use ''if(session->hid) {} else if(session->input) {}"" instead
> of ''if(session->hid) {}; if(session->input) {};''
> 
> Signed-off-by: Chen Gang <gang.chen@asianux.com>
> ---
>  net/bluetooth/hidp/core.c |   14 ++++----------
>  1 files changed, 4 insertions(+), 10 deletions(-)
> 
> diff --git a/net/bluetooth/hidp/core.c b/net/bluetooth/hidp/core.c
> index 940f5ac..f13a8da 100644
> --- a/net/bluetooth/hidp/core.c
> +++ b/net/bluetooth/hidp/core.c
> @@ -76,25 +76,19 @@ static void hidp_copy_session(struct hidp_session *session, struct hidp_conninfo
>  	ci->flags = session->flags;
>  	ci->state = BT_CONNECTED;
>  
> -	ci->vendor  = 0x0000;
> -	ci->product = 0x0000;
> -	ci->version = 0x0000;
> -
>  	if (session->input) {
>  		ci->vendor  = session->input->id.vendor;
>  		ci->product = session->input->id.product;
>  		ci->version = session->input->id.version;
>  		if (session->input->name)
> -			strncpy(ci->name, session->input->name, 128);
> +			strlcpy(ci->name, session->input->name, 128);
>  		else
> -			strncpy(ci->name, "HID Boot Device", 128);
> -	}
> -
> -	if (session->hid) {
> +			strlcpy(ci->name, "HID Boot Device", 128);
> +	} else if (session->hid) {
>  		ci->vendor  = session->hid->vendor;
>  		ci->product = session->hid->product;
>  		ci->version = session->hid->version;
> -		strncpy(ci->name, session->hid->name, 128);
> +		strlcpy(ci->name, session->hid->name, 128);
>  	}
>  }
>  
> 


-- 
Chen Gang

Asianux Corporation
