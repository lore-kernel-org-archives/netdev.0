From: Jiri Benc <jbenc@suse.cz>
Subject: Re: [PATCH 3/6] d80211: fix classify_1d() priority selection
Date: Thu, 14 Dec 2006 12:13:58 +0100
Message-ID: <20061214121358.6bd586b0@griffin.suse.cz>
References: <20061214040227.GA10661@mail.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Jouni Malinen <jkm@devicescape.com>,
	"John W. Linville" <linville@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from styx.suse.cz ([82.119.242.94]:53076 "EHLO mail.suse.cz"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S932528AbWLNLNf (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 14 Dec 2006 06:13:35 -0500
To: yi.zhu@intel.com
In-Reply-To: <20061214040227.GA10661@mail.intel.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 14 Dec 2006 12:02:27 +0800, Zhu Yi wrote:
> I don't see any reason why packets with DSCP=0x40 should have lower IEEE
> 802.1D priority than packets with DSCP=0x20. Spare > Background. No?

Hm, seems so. Jouni, is there any reason for this?

> 
> Signed-off-by: Zhu Yi <yi.zhu@intel.com>
> 
> ---
> 
>  net/d80211/wme.c |    4 ++--
>  1 files changed, 2 insertions(+), 2 deletions(-)
> 
> e1765ea0d80ad86619300d3253e801883fd745a5
> diff --git a/net/d80211/wme.c b/net/d80211/wme.c
> index b9505dc..f26fe6c 100644
> --- a/net/d80211/wme.c
> +++ b/net/d80211/wme.c
> @@ -131,9 +131,9 @@ static inline unsigned classify_1d(struc
>  	dscp = ip->tos & 0xfc;
>  	switch (dscp) {
>  	case 0x20:
> -		return 2;
> -	case 0x40:
>  		return 1;
> +	case 0x40:
> +		return 2;
>  	case 0x60:
>  		return 3;
>  	case 0x80:

Thanks,

 Jiri

-- 
Jiri Benc
SUSE Labs
