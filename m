From: Jiri Slaby <jirislaby@gmail.com>
Subject: Re: [PATCH 1/1] NET: wan/x25_asy, move lapb_unregister to x25_asy_close_tty
Date: Thu, 25 Nov 2010 13:07:10 +0100
Message-ID: <4CEE516E.6010006@gmail.com>
References: <1290642894-4577-1-git-send-email-jslaby@suse.cz> <AANLkTi=DEHOKkrvzHUBnW+rAkGz-uhizRqZb2PAuh4k-@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org, slapin@ossfans.org,
	linux-kernel@vger.kernel.org
To: Andrew Hendry <andrew.hendry@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f46.google.com ([209.85.214.46]:42732 "EHLO
	mail-bw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750919Ab0KYMHP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Nov 2010 07:07:15 -0500
In-Reply-To: <AANLkTi=DEHOKkrvzHUBnW+rAkGz-uhizRqZb2PAuh4k-@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/25/2010 12:37 PM, Andrew Hendry wrote:
> Sorry I haven't used this driver so can't fully test it. Looks
> straightforward and compile tested ok.
> 
> On Thu, Nov 25, 2010 at 10:54 AM, Jiri Slaby <jslaby@suse.cz> wrote:
>> We register lapb when tty is created, but unregister it only when the
>> device is UP. So move the lapb_unregister to x25_asy_close_tty after
>> the device is down.

I forgot to mention what it causes. The commit message should add:
The old behaviour causes ldisc switching to fail each second attempt,
because we noted for us that the device is unused, so we use it the
second time, but labp layer still have it registered, so it fails
obviously.

thanks,
-- 
js
