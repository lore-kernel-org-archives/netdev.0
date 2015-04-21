From: Simon Xiao <sixiao@microsoft.com>
Subject: RE: [PATCH net-next,1/1] hv_netvsc: call dump_rndis_message() only in
 netvsc debug mode
Date: Tue, 21 Apr 2015 22:14:14 +0000
Message-ID: <CY1PR03MB137672BCD670AF429263C498C4EF0@CY1PR03MB1376.namprd03.prod.outlook.com>
References: <1429657085-23379-1-git-send-email-sixiao@microsoft.com>
 <20150421.174852.1894618346723165016.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: KY Srinivasan <kys@microsoft.com>,
	Haiyang Zhang <haiyangz@microsoft.com>,
	"devel@linuxdriverproject.org" <devel@linuxdriverproject.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bn1bon0140.outbound.protection.outlook.com ([157.56.111.140]:56792
	"EHLO na01-bn1-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S964865AbbDUWOY convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Apr 2015 18:14:24 -0400
In-Reply-To: <20150421.174852.1894618346723165016.davem@davemloft.net>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


> -----Original Message-----
> From: David Miller [mailto:davem@davemloft.net]
> Sent: Tuesday, April 21, 2015 2:49 PM
> To: Simon Xiao
> Cc: KY Srinivasan; Haiyang Zhang; devel@linuxdriverproject.org;
> netdev@vger.kernel.org; linux-kernel@vger.kernel.org
> Subject: Re: [PATCH net-next,1/1] hv_netvsc: call dump_rndis_message() only in
> netvsc debug mode
> 
> From: sixiao@microsoft.com
> Date: Tue, 21 Apr 2015 15:58:05 -0700
> 
> > From: Simon Xiao <sixiao@microsoft.com>
> >
> > Signed-off-by: Simon Xiao <sixiao@microsoft.com>
> > Reviewed-by: K. Y. Srinivasan <kys@microsoft.com>
> > Reviewed-by: Haiyang Zhang <haiyangz@microsoft.com>
> 
> I just gave you feedback on this patch in response to your original submission,
> do not ignore it.

Thanks for your feedback, David.

In current netvsc driver, for each packet received, it will call dump_rndis_message() 
to try to dump the rndis packet information by netdev_dbg(). 
In non-debug mode, dump_rndis_message() will not dump anything 
but it still initialize some local variables and process the switch logic in the function 
of dump_rndis_message(), which is unnecessary, especially in high network throughput situation.

My change is to have a run-time config flag to control the execution of dump_rndis_message() 
and avoid above unnecessary cost in non-debug mode.
In the default case, it will be non-debug mode,
 and rndis_filter_receive() will not call dump_rndis_message() 
which saves the above extra cost for each packet received.
