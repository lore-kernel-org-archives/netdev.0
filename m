From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [PATCHv2 net-next] cxgb4: Enhance driver to update FW, when FW
 is too old
Date: Fri, 9 Oct 2015 09:01:54 -0400
Message-ID: <20151009130153.GA4284@hmsreliant.think-freely.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net, leedom@chelsio.com,
	nirranjan@chelsio.com
To: hariprasad@chelsio.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:60318 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752801AbbJINCO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 Oct 2015 09:02:14 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


> 	ret = t4_get_fw_version(adap, &adap->params.fw_vers);
>+	/* Try multiple times before returning error */
>+	for (i = 0; (ret == -EBUSY || ret == -EAGAIN) && i < 3; i++)
>+		ret = t4_get_fw_version(adap, &adap->params.fw_vers);
>+
> 	if (ret)
> 		return ret;


Nit: Just initalize ret to -EBUSY and change the test for i to < 4 rather than <
3.  That way you will only have one call site for t4_get_fw_version, which I
think is more readable.  Alternatively a do..while loop might be appropriate
here.

But I suppose I'm just splitting hairs at this point

Acked-by: Neil Horman <nhorman@tuxdriver.com>

 
