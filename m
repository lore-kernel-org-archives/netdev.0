From: Phil Sutter <phil@nwl.cc>
Subject: Re: [PATCH iproute2] man: fix man page warnings
Date: Wed, 5 Apr 2017 16:56:23 +0200
Message-ID: <20170405145623.GN19768@orbyte.nwl.cc>
References: <20170326191114.3756-1-alexander@alemayhu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, stephen@networkplumber.org
To: Alexander Alemayhu <alexander@alemayhu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbyte.nwl.cc ([151.80.46.58]:47667 "EHLO mail.nwl.cc"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1754118AbdDEO4Z (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 5 Apr 2017 10:56:25 -0400
Content-Disposition: inline
In-Reply-To: <20170326191114.3756-1-alexander@alemayhu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Mar 26, 2017 at 09:11:14PM +0200, Alexander Alemayhu wrote:
> While generating PDFs from the man pages, I saw the warning below from
> several files. Compared the tc-matchall.8 with bridge.8 and used .RI
> instead of .R. It should have no effect on the man page rendering.
> 
>     `R' is a string (producing the registered sign), not a macro.
> 
> Signed-off-by: Alexander Alemayhu <alexander@alemayhu.com>

I know this has been applied already, but let me get this straight:

People using '.R' try to force "normal" font, like for every second
parameter to '.IR' but in fact they could just leave the macro away
since lines starting without any macro will get normal font settings
anyway.

With this in mind, I see better solutions for the changes in this patch:

[...]
> @@ -20,7 +20,7 @@ flower \- flow based traffic control filter
>  .B indev
>  .IR ifname " | "
>  .BR skip_sw " | " skip_hw
> -.R " | { "
> +.RI " | { "

Just merge this into previous line:

|  .BR skip_sw " | " skip_hw " | {"

Note the missing space at the end, as that comes for free anyway. :)

[...]
> @@ -13,7 +13,7 @@ IFE - encapsulate/decapsulate metadata
>  .IR SMAC " ] "
>  .RB "[ " type
>  .IR TYPE " ] "
> -.R "[ "
> +.RI "[ "

Same here:

| .IR TYPE " ] ["

[...]
> @@ -7,7 +7,7 @@ matchall \- traffic control filter that matches every packet
>  .ti -8
>  .BR tc " " filter " ... " matchall " [ "
>  .BR skip_sw " | " skip_hw
> -.R " ] [ "
> +.RI " ] [ "

And here as well:

|  .BR skip_sw " | " skip_hw " ] ["

Cheers, Phil
