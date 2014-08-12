From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [net 4/6] i40e: Cleaning up missing null-terminate in
 conjunction with strncpy
Date: Tue, 12 Aug 2014 08:43:33 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6D174755A8@AcuExch.aculab.com>
References: <1407832707-26034-1-git-send-email-jeffrey.t.kirsher@intel.com>
 <1407832707-26034-5-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: Rickard Strandqvist <rickard_strandqvist@spectrumdigital.se>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"nhorman@redhat.com" <nhorman@redhat.com>,
	"sassmann@redhat.com" <sassmann@redhat.com>
To: 'Jeff Kirsher' <jeffrey.t.kirsher@intel.com>,
	"davem@davemloft.net" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0.aculab.com ([213.249.233.131]:40634 "HELO mx0.aculab.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1752153AbaHLIpX convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Aug 2014 04:45:23 -0400
Received: from mx0.aculab.com ([127.0.0.1])
 by localhost (mx0.aculab.com [127.0.0.1]) (amavisd-new, port 10024) with SMTP
 id 10003-06 for <netdev@vger.kernel.org>;
 Tue, 12 Aug 2014 09:45:15 +0100 (BST)
In-Reply-To: <1407832707-26034-5-git-send-email-jeffrey.t.kirsher@intel.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher
> From: Rickard Strandqvist <rickard_strandqvist@spectrumdigital.se>
> 
> Replacing strncpy with strlcpy to avoid strings that lacks null terminate.
...
> diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
> index 2ac8f45..871474f 100644
> --- a/drivers/net/ethernet/intel/i40e/i40e_main.c
> +++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
> @@ -4415,13 +4415,13 @@ static void i40e_print_link_message(struct i40e_vsi *vsi, bool isup)
> 
>  	switch (vsi->back->hw.phy.link_info.link_speed) {
>  	case I40E_LINK_SPEED_40GB:
> -		strncpy(speed, "40 Gbps", SPEED_SIZE);
> +		strlcpy(speed, "40 Gbps", SPEED_SIZE);
>  		break;
>  	case I40E_LINK_SPEED_10GB:
> -		strncpy(speed, "10 Gbps", SPEED_SIZE);
> +		strlcpy(speed, "10 Gbps", SPEED_SIZE);
>  		break;
>  	case I40E_LINK_SPEED_1GB:
> -		strncpy(speed, "1000 Mbps", SPEED_SIZE);
> +		strlcpy(speed, "1000 Mbps", SPEED_SIZE);
>  		break;
>  	default:
>  		break;

Could 'speed' be change to be a 'const char *' ?
(and 'fc' below).

	David

> @@ -4429,16 +4429,16 @@ static void i40e_print_link_message(struct i40e_vsi *vsi, bool isup)
> 
>  	switch (vsi->back->hw.fc.current_mode) {
>  	case I40E_FC_FULL:
> -		strncpy(fc, "RX/TX", FC_SIZE);
> +		strlcpy(fc, "RX/TX", FC_SIZE);
>  		break;
>  	case I40E_FC_TX_PAUSE:
> -		strncpy(fc, "TX", FC_SIZE);
> +		strlcpy(fc, "TX", FC_SIZE);
>  		break;
>  	case I40E_FC_RX_PAUSE:
> -		strncpy(fc, "RX", FC_SIZE);
> +		strlcpy(fc, "RX", FC_SIZE);
>  		break;
>  	default:
> -		strncpy(fc, "None", FC_SIZE);
> +		strlcpy(fc, "None", FC_SIZE);
>  		break;
>  	}
> 
> @@ -5839,7 +5839,7 @@ static void i40e_send_version(struct i40e_pf *pf)
>  	dv.minor_version = DRV_VERSION_MINOR;
>  	dv.build_version = DRV_VERSION_BUILD;
>  	dv.subbuild_version = 0;
> -	strncpy(dv.driver_string, DRV_VERSION, sizeof(dv.driver_string));
> +	strlcpy(dv.driver_string, DRV_VERSION, sizeof(dv.driver_string));
>  	i40e_aq_send_driver_version(&pf->hw, &dv, NULL);
>  }
> 
> --
> 1.9.3
> 
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
