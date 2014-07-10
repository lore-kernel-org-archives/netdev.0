From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [PATCH 2/2] hso: fix deadlock when receiving bursts of data
Date: Thu, 10 Jul 2014 14:37:37 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6D17270044@AcuExch.aculab.com>
References: <1404723967-24245-1-git-send-email-olivier@sobrie.be>
 <1404723967-24245-2-git-send-email-olivier@sobrie.be>
 <20140708.161633.2130069042930765600.davem@davemloft.net>
 <20140710142848.GA28056@hposo>
Mime-Version: 1.0
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: "j.dumon@option.com" <j.dumon@option.com>,
	"linux-usb@vger.kernel.org" <linux-usb@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: 'Olivier Sobrie' <olivier@sobrie.be>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0.aculab.com ([213.249.233.131]:51011 "HELO mx0.aculab.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1752056AbaGJOjP convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Jul 2014 10:39:15 -0400
Received: from mx0.aculab.com ([127.0.0.1])
 by localhost (mx0.aculab.com [127.0.0.1]) (amavisd-new, port 10024) with SMTP
 id 22212-09 for <netdev@vger.kernel.org>;
 Thu, 10 Jul 2014 15:39:05 +0100 (BST)
In-Reply-To: <20140710142848.GA28056@hposo>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Olivier Sobrie
...
> The function put_rxbuf_data() is called from the urb completion handler.
> It puts the data of the urb transfer in the tty buffer with
> tty_insert_flip_string_flags() and schedules a work queue in order to
> push the data to the ldisc.
> Problem is that we are in a urb completion handler so we can't wait
> until there is room in the tty buffer.

Surely you can just keep the urb?
Resubmit it later when all the data has been transferred.

	David
