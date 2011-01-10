From: David Miller <davem@davemloft.net>
Subject: Re: 2.6.37-rc8: Reported regressions from 2.6.36
Date: Mon, 10 Jan 2011 00:08:13 -0800 (PST)
Message-ID: <20110110.000813.173856001.davem@davemloft.net>
References: <96DQe4a_2tH.A.cFB.l27GNB@chimera>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, maciej.rutecki@gmail.com,
	florian@mickler.org, akpm@linux-foundation.org,
	torvalds@linux-foundation.org, kernel-testers@vger.kernel.org,
	netdev@vger.kernel.org, linux-acpi@vger.kernel.org,
	linux-pm@lists.linux-foundation.org, linux-scsi@vger.kernel.org,
	linux-wireless@vger.kernel.org, dri-devel@lists.freedesktop.org
To: rjw@sisk.pl
Return-path: <linux-scsi-owner@vger.kernel.org>
In-Reply-To: <96DQe4a_2tH.A.cFB.l27GNB@chimera>
Sender: linux-scsi-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Rafael J. Wysocki" <rjw@sisk.pl>
Date: Wed, 29 Dec 2010 23:59:38 +0100 (CET)

> Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=24592
> Subject		: 2.6.37-rc5: NULL pointer oops in selinux_socket_unix_stream_connect
> Submitter	: Jeremy Fitzhardinge <jeremy@goop.org>
> Date		: 2010-12-08 21:09 (22 days old)
> Message-ID	: <4CFFF3F3.90100@goop.org>
> References	: http://marc.info/?l=linux-kernel&m=129184256629712&w=2

This bug is intended to be fixed by:

commit 3610cda53f247e176bcbb7a7cca64bc53b12acdb
Author: David S. Miller <davem@davemloft.net>
Date:   Wed Jan 5 15:38:53 2011 -0800

    af_unix: Avoid socket->sk NULL OOPS in stream connect security hooks.
    
    unix_release() can asynchornously set socket->sk to NULL, and
    it does so without holding the unix_state_lock() on "other"
    during stream connects.
    
    However, the reverse mapping, sk->sk_socket, is only transitioned
    to NULL under the unix_state_lock().
    
    Therefore make the security hooks follow the reverse mapping instead
    of the forward mapping.
    
    Reported-by: Jeremy Fitzhardinge <jeremy@goop.org>
    Reported-by: Linus Torvalds <torvalds@linux-foundation.org>
    Signed-off-by: David S. Miller <davem@davemloft.net>

