From: "Filka Michal" <Michal.Filka@sitronicsts.com>
Subject: kernel newbie question on kernel panic
Date: Mon, 21 Jul 2008 17:24:50 +0200
Message-ID: <4474723F928CA640ADB2172099AEAB111B603F@exalfa.stromtelecom.cz>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.strom.cz ([80.95.102.231]:40894 "EHLO mail.strom.cz"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750733AbYGUPiR convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Jul 2008 11:38:17 -0400
Content-class: urn:content-classes:message
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi all,

I try to create my first kernel module.
I have following problem. I have a function rp ... interesting part
follows (just some initialization is ommited - nothing special - the
function is just a skeleton)

int rp( struct sk_buff ** skb)
{
	_filter_rule * rule = NULL;

...

	rule = placebo();
-->	if( rule == NULL)
		printk( KERN_DEBUG "null rule\n");
	return 1;
}

The rp is called (subsequently) in netfilter (prerouting) hook context,
so as far as I know it runs in a SoftIRQ.

The placebo function does nothing - just returns NULL. The problem is in
line selected (-->).Everything goes until I try to somehow access
returned value. The access raises kernel panic, seems that some page
fault happent. If I comment out the line bellow selected (the test), no
kernel panic happens.

Questions are:
- why the page fault happens (some trouble in memory usage, or so?)
- how to avoid it?

Thanks for any help
Michal Filka
