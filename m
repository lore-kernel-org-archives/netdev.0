From: Andy Lutomirski <luto@amacapital.net>
Subject: Re: [PATCH] sfc: Enable accelerated RFS on vlans
Date: Thu, 16 May 2013 12:45:09 -0700
Message-ID: <CALCETrVpEz_WdG9bKjUSR3OKyERd+hMLwK8+_84L5WxepQrS1g@mail.gmail.com>
References: <4bdabd4670b726348cdcdc0d2d635dd660671ee3.1368229353.git.luto@amacapital.net>
 <1368729524.2655.30.camel@bwh-desktop.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: netdev@vger.kernel.org,
	Solarflare linux maintainers <linux-net-drivers@solarflare.com>
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f45.google.com ([209.85.215.45]:43383 "EHLO
	mail-la0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751953Ab3EPTpc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 May 2013 15:45:32 -0400
Received: by mail-la0-f45.google.com with SMTP id ec20so3148527lab.18
        for <netdev@vger.kernel.org>; Thu, 16 May 2013 12:45:31 -0700 (PDT)
In-Reply-To: <1368729524.2655.30.camel@bwh-desktop.uk.solarflarecom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, May 16, 2013 at 11:38 AM, Ben Hutchings
<bhutchings@solarflare.com> wrote:
> On Fri, 2013-05-10 at 16:51 -0700, Andy Lutomirski wrote:
>> As far as I know, the hardware doesn't support matching on both IP
>> fields and vlan tag, but it can at least match on the vlan tag.
>>
>> Signed-off-by: Andy Lutomirski <luto@amacapital.net>
>> ---
>>
>> Tested on the OpenOnload version of the driver, but the patch is the same
>> other than some offset.
>
> This looks correct, but I'll have to actually test it.  So I'll queue
> this up and re-submit along with other sfc patches later on, OK?

Fine with me.  (Is there a combined vlan + IP filter that I don't know about?)

When you resubmit it, it might be worth fixing the blatant typo (vlan
tag -> IP fields) in the description, though :/

>
>> With this patch, accelerated RFS works for me.  (Oddly, some packets end
>> up on otherwise idle cores, even when those cores have weight zero in
>> ethtool --set-rxfh-indir; I'm not sure what's going on there.)
>
> Some packets, or some interrupts?  TX completions and wake-up events (if
> you use user-level networking) are of course not affected by the RX flow
> hash indirection table..

It's TX completions -- I figured that out after I sent this patch.

>
> You might find it useful to dump the complete RX filter table by running
> 'ethtool -d'.  ('ethtool -n' only shows the manually controlled
> filters.)

Thanks -- that's useful.

--Andy
