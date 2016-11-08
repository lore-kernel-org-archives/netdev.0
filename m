From: Paul Durrant <Paul.Durrant@citrix.com>
Subject: RE: [PATCH v3] xen-netback: prefer xenbus_scanf() over
 xenbus_gather()
Date: Tue, 8 Nov 2016 09:37:34 +0000
Message-ID: <b5d07ded86ba4e3fa262e13302b01a9e@AMSPEX02CL03.citrite.net>
References: <582190C1020000780011CF5C@prv-mh.provo.novell.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: xen-devel <xen-devel@lists.xenproject.org>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Jan Beulich <JBeulich@suse.com>, Wei Liu <wei.liu2@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.eu.citrix.com ([185.25.65.24]:19206 "EHLO
        SMTP.EU.CITRIX.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S933076AbcKHJhg (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 8 Nov 2016 04:37:36 -0500
In-Reply-To: <582190C1020000780011CF5C@prv-mh.provo.novell.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> -----Original Message-----
> From: Jan Beulich [mailto:JBeulich@suse.com]
> Sent: 08 November 2016 07:46
> To: Paul Durrant <Paul.Durrant@citrix.com>; Wei Liu <wei.liu2@citrix.com>
> Cc: xen-devel <xen-devel@lists.xenproject.org>; netdev@vger.kernel.org
> Subject: [PATCH v3] xen-netback: prefer xenbus_scanf() over
> xenbus_gather()
> 
> For single items being collected this should be preferred as being more
> typesafe (as the compiler can check format string and to-be-written-to
> variable match) and more efficient (requiring one less parameter to be
> passed).
> 
> Signed-off-by: Jan Beulich <jbeulich@suse.com>

LGTM

Reviewed-by: Paul Durrant <paul.durrant@citrix.com>

> ---
> v3: For consistency with other code don't consider zero an error
>     (utilizing that xenbus_scanf() at present won't return zero).
> v2: Avoid commit message to continue from subject.
> ---
>  drivers/net/xen-netback/xenbus.c |   12 ++++++------
>  1 file changed, 6 insertions(+), 6 deletions(-)
> 
> --- 4.9-rc4/drivers/net/xen-netback/xenbus.c
> +++ 4.9-rc4-xen-netback-prefer-xenbus_scanf/drivers/net/xen-
> netback/xenbus.c
> @@ -889,16 +889,16 @@ static int connect_ctrl_ring(struct back
>  	unsigned int evtchn;
>  	int err;
> 
> -	err = xenbus_gather(XBT_NIL, dev->otherend,
> -			    "ctrl-ring-ref", "%u", &val, NULL);
> -	if (err)
> +	err = xenbus_scanf(XBT_NIL, dev->otherend,
> +			   "ctrl-ring-ref", "%u", &val);
> +	if (err < 0)
>  		goto done; /* The frontend does not have a control ring */
> 
>  	ring_ref = val;
> 
> -	err = xenbus_gather(XBT_NIL, dev->otherend,
> -			    "event-channel-ctrl", "%u", &val, NULL);
> -	if (err) {
> +	err = xenbus_scanf(XBT_NIL, dev->otherend,
> +			   "event-channel-ctrl", "%u", &val);
> +	if (err < 0) {
>  		xenbus_dev_fatal(dev, err,
>  				 "reading %s/event-channel-ctrl",
>  				 dev->otherend);
> 
> 
