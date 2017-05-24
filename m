From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [PATCH net-next 2/4] nfp: register ports as devlink ports
Date: Wed, 24 May 2017 14:35:14 +0200
Message-ID: <20170524123514.GB1908@nanopsycho>
References: <20170523151247.8535-1-jakub.kicinski@netronome.com>
 <20170523151247.8535-3-jakub.kicinski@netronome.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, oss-drivers@netronome.com
To: Jakub Kicinski <jakub.kicinski@netronome.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f45.google.com ([74.125.82.45]:37811 "EHLO
        mail-wm0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S940020AbdEXMfR (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 24 May 2017 08:35:17 -0400
Received: by mail-wm0-f45.google.com with SMTP id d127so66999506wmf.0
        for <netdev@vger.kernel.org>; Wed, 24 May 2017 05:35:16 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20170523151247.8535-3-jakub.kicinski@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Tue, May 23, 2017 at 05:12:45PM CEST, jakub.kicinski@netronome.com wrote:
>Extend nfp_port to contain devlink_port structures.  Register the
>ports to allow users inspecting device ports.
>
>Signed-off-by: Jakub Kicinski <jakub.kicinski@netronome.com>
>Reviewed-by: Simon Horman <simon.horman@netronome.com>
>---

[...]

>+void nfp_devlink_port_unregister(struct nfp_port *port)
>+{
>+	/* Due to unpleasant lock ordering we may see the port go away before
>+	 * we have fully probed.

Could you elaborate on this a bit more please?


>+	 */
>+	if (port->dl_port.registered)
>+		devlink_port_unregister(&port->dl_port);
>+}
