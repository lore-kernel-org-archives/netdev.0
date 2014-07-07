From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [PATCH 2/2] hso: fix deadlock when receiving bursts of data
Date: Mon, 7 Jul 2014 09:13:53 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6D1726D5E9@AcuExch.aculab.com>
References: <1404723967-24245-1-git-send-email-olivier@sobrie.be>
 <1404723967-24245-2-git-send-email-olivier@sobrie.be>
Mime-Version: 1.0
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: 'Olivier Sobrie' <olivier@sobrie.be>,
	Jan Dumon <j.dumon@option.com>,
	"linux-usb@vger.kernel.org" <linux-usb@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1404723967-24245-2-git-send-email-olivier@sobrie.be>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Olivier Sobrie
> When the module sends bursts of data, sometimes a deadlock happens in
> the hso driver when the tty buffer doesn't get the chance to be flushed
> quickly enough.
> 
> To avoid this, first, we remove the endless while loop in
> put_rx_bufdata() which is the root cause of the deadlock.
> Secondly, when there is no room anymore in the tty buffer, we set up a
> timer of 100 msecs to give a chance to the upper layer to flush the tty
> buffer and make room for new data.

What is the timer for?
You need to get the sending code woken up by the urb completion.

	David
