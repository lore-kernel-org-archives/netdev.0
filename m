From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [net-next 03/17] i40e: allow various base numbers in debugfs aq
 commands
Date: Mon, 24 Nov 2014 16:50:58 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6D1C9FA07E@AcuExch.aculab.com>
References: <1416635708-4765-1-git-send-email-jeffrey.t.kirsher@intel.com>
 <1416635708-4765-5-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: Shannon Nelson <shannon.nelson@intel.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"nhorman@redhat.com" <nhorman@redhat.com>,
	"sassmann@redhat.com" <sassmann@redhat.com>,
	"jogreene@redhat.com" <jogreene@redhat.com>
To: 'Jeff Kirsher' <jeffrey.t.kirsher@intel.com>,
	"davem@davemloft.net" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0.aculab.com ([213.249.233.131]:52848 "HELO mx0.aculab.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1751111AbaKXQwD convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Nov 2014 11:52:03 -0500
Received: from mx0.aculab.com ([127.0.0.1])
 by localhost (mx0.aculab.com [127.0.0.1]) (amavisd-new, port 10024) with SMTP
 id 07125-06 for <netdev@vger.kernel.org>;
 Mon, 24 Nov 2014 16:51:53 +0000 (GMT)
In-Reply-To: <1416635708-4765-5-git-send-email-jeffrey.t.kirsher@intel.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher
> From: Shannon Nelson <shannon.nelson@intel.com>
> 
> Use the 'i' rather than the more restrictive 'x' or 'd' in the aq_cmd
> arguments.  This makes the user interface much more forgiving and user
> friendly.
> 
> Change-ID: I5dcd57b9befc047e06b74cf1152a25a3fa9e1309
> Signed-off-by: Shannon Nelson <shannon.nelson@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> ---
>  drivers/net/ethernet/intel/i40e/i40e_debugfs.c | 4 ++--
>  1 file changed, 2 insertions(+), 2 deletions(-)
> 
> diff --git a/drivers/net/ethernet/intel/i40e/i40e_debugfs.c
> b/drivers/net/ethernet/intel/i40e/i40e_debugfs.c
> index 3a3c237..16ac3f8 100644
> --- a/drivers/net/ethernet/intel/i40e/i40e_debugfs.c
> +++ b/drivers/net/ethernet/intel/i40e/i40e_debugfs.c
> @@ -1493,7 +1493,7 @@ static ssize_t i40e_dbg_command_write(struct file *filp,
>  		if (!desc)
>  			goto command_write_done;
>  		cnt = sscanf(&cmd_buf[11],
> -			     "%hx %hx %hx %hx %x %x %x %x %x %x",
> +			     "%hi %hi %hi %hi %i %i %i %i %i %i",

Isn't that an API change?
Anything that used to specify "10" will now get 10 instead of 16.

So if this has been in a release kernel you probably shouldn't change it.

	David

>  			     &desc->flags,
>  			     &desc->opcode, &desc->datalen, &desc->retval,
>  			     &desc->cookie_high, &desc->cookie_low,
> @@ -1541,7 +1541,7 @@ static ssize_t i40e_dbg_command_write(struct file *filp,
>  		if (!desc)
>  			goto command_write_done;
>  		cnt = sscanf(&cmd_buf[20],
> -			     "%hx %hx %hx %hx %x %x %x %x %x %x %hd",
> +			     "%hi %hi %hi %hi %i %i %i %i %i %i %hi",
>  			     &desc->flags,
>  			     &desc->opcode, &desc->datalen, &desc->retval,
>  			     &desc->cookie_high, &desc->cookie_low,
> --
> 1.9.3
> 
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
