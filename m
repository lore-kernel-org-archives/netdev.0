From: Peter Hurley <peter@hurleysoftware.com>
Subject: Re: [PATCH 3/4] tty: Abstract and encapsulate tty->closing behavior
Date: Mon, 9 Nov 2015 06:58:42 -0500
Message-ID: <56408A72.4050301@hurleysoftware.com>
References: <1447020173-32207-1-git-send-email-peter@hurleysoftware.com>
 <1447020173-32207-4-git-send-email-peter@hurleysoftware.com>
 <20151109091214.GD16715@sig21.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	Jiri Slaby <jslaby@suse.cz>, linux-kernel@vger.kernel.org,
	linux-serial@vger.kernel.org, netdev@vger.kernel.org,
	Karsten Keil <isdn@linux-pingi.de>,
	Martin Schwidefsky <schwidefsky@de.ibm.com>,
	Heiko Carstens <heiko.carstens@de.ibm.com>,
	Jesper Nilsson <jesper.nilsson@axis.com>,
	Mikael Starvik <starvik@axis.com>,
	Jiri Kosina <jikos@kernel.org>,
	David Sterba <dsterba@suse.com>,
	Mark Hounschell <markh@compro.net>
To: Johannes Stezenbach <js@sig21.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f182.google.com ([209.85.213.182]:38877 "EHLO
	mail-ig0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752266AbbKIL6q (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Nov 2015 06:58:46 -0500
Received: by igbxm8 with SMTP id xm8so49609136igb.1
        for <netdev@vger.kernel.org>; Mon, 09 Nov 2015 03:58:45 -0800 (PST)
In-Reply-To: <20151109091214.GD16715@sig21.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/09/2015 04:12 AM, Johannes Stezenbach wrote:
> On Sun, Nov 08, 2015 at 05:02:52PM -0500, Peter Hurley wrote:
>> +void tty_ldisc_closing(struct tty_struct *tty)
>> +{
>> +	struct tty_ldisc *ld = tty_ldisc_ref(tty);
>> +
>> +	if (ld->ops->closing)
>> +		ld->ops->closing(tty);
>> +	if (ld)
>> +		tty_ldisc_deref(ld);
>> +}
> 
> That looks strange.  Do you need to check ld _before_ dereferencing?

Yes. Thanks for noticing.

Regards,
Peter Hurley
