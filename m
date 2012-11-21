From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: team: add broadcast mode
Date: Wed, 21 Nov 2012 10:36:58 +0100
Message-ID: <20121121093658.GA1629@minipsycho.orion>
References: <20121120192307.GA10278@elgon.mountain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jpirko@redhat.com, netdev@vger.kernel.org
To: Dan Carpenter <dan.carpenter@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f46.google.com ([74.125.83.46]:50525 "EHLO
	mail-ee0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752143Ab2KUJhD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Nov 2012 04:37:03 -0500
Received: by mail-ee0-f46.google.com with SMTP id e53so2156273eek.19
        for <netdev@vger.kernel.org>; Wed, 21 Nov 2012 01:37:01 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <20121120192307.GA10278@elgon.mountain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Tue, Nov 20, 2012 at 08:23:07PM CET, dan.carpenter@oracle.com wrote:
>Hello Jiri Pirko,
>
>The patch 5fc889911a99: "team: add broadcast mode" from Jul 11, 2012, 
>leads to the following Smatch warning:
>drivers/net/team/team_mode_broadcast.c:46 bc_transmit()
>	 warn: signedness bug returning '18446744073709551516'
>
>The error message sucks because 18446744073709551516 is -100 as an int,
>and I'm not sure how it figures this returns -100...
>
>But actually there is a signedness bug in bc_transmit().  We return
>error codes from team_dev_queue_xmit() and cast them to 1 as bool.  This
>function is supposed to return 1 on success but instead it returns zero.


Thanks Dan for finding this. You are correct.                            
I'm going to send patch introducing "!" in front of both
team_dev_queue_xmit() calls in bc_transmit(). That will correct this.                          
	                                                                         
Jiri 

>
>regards,
>dan carpenter
>
>--
>To unsubscribe from this list: send the line "unsubscribe netdev" in
>the body of a message to majordomo@vger.kernel.org
>More majordomo info at  http://vger.kernel.org/majordomo-info.html
