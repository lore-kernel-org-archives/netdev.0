From: Jiri Slaby <jslaby@suse.cz>
Subject: Re: [Suggestion] drivers/isdn: about the loop after call isdn_tty_send_msg
Date: Wed, 27 Feb 2013 11:00:44 +0100
Message-ID: <512DD94C.2020008@suse.cz>
References: <512DD2B3.2070404@asianux.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=GB2312
Content-Transfer-Encoding: 7bit
Cc: Greg KH <gregkh@linuxfoundation.org>,
	Alan Cox <alan@lxorguk.ukuu.org.uk>,
	netdev <netdev@vger.kernel.org>
To: Chen Gang <gang.chen@asianux.com>, Jiri Kosina <jkosina@suse.cz>,
	isdn@linux-pingi.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f45.google.com ([74.125.83.45]:49597 "EHLO
	mail-ee0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751792Ab3B0KAs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Feb 2013 05:00:48 -0500
Received: by mail-ee0-f45.google.com with SMTP id b57so296890eek.32
        for <netdev@vger.kernel.org>; Wed, 27 Feb 2013 02:00:46 -0800 (PST)
In-Reply-To: <512DD2B3.2070404@asianux.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 02/27/2013 10:32 AM, Chen Gang wrote:
> Hello Maintainers:
> 
>   do we need break out of the loop after call isdn_tty_send_msg ?
>     p is not increased after finish calling isdn_tty_send_msg.
>     and then will loop back to process the p again.
> 
>   do we intend to scan again the string which appended "+M..." ?

Nope, we should break the for loop because isdn_tty_send_msg is intended
to eat the rest of the string. Evidently nobody tested this path yet.

>   we also assume "+M..." is a NUL terminated string, is it OK ? (it seems ok)

Yes, p should be NUL-terminated.

thanks,
-- 
js
suse labs
