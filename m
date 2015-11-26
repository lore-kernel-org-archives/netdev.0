From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: 4.3+: Atheros ethernet fails after resume from s2ram, due to
 order 4 allocation
Date: Thu, 26 Nov 2015 22:56:39 +0100
Message-ID: <20151126215638.GA22801@electric-eye.fr.zoreil.com>
References: <20151126163413.GA3816@amd>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: kernel list <linux-kernel@vger.kernel.org>, jcliburn@gmail.com,
        chris.snook@gmail.com, netdev@vger.kernel.org,
        "Rafael J. Wysocki" <rjw@rjwysocki.net>, linux-mm@kvack.org,
        nic-devel@qualcomm.com, ronangeles@gmail.com, ebiederm@xmission.com,
        David Miller <davem@davemloft.net>
To: Pavel Machek <pavel@ucw.cz>
Return-path: <owner-linux-mm@kvack.org>
Content-Disposition: inline
In-Reply-To: <20151126163413.GA3816@amd>
Sender: owner-linux-mm@kvack.org
List-Id: netdev.vger.kernel.org

Pavel Machek <pavel@ucw.cz> :
[...]
> Ok, so what went on is easy.. any ideas how to fix it ?

The driver should 1) prohibit holes in its receive ring, 2) allocate before
pushing data up in the stack 3) drop packets when it can't allocate a
fresh buffer and 4) stop releasing receive buffers - and any resource for
that matter - during suspend.

Really.

-- 
Ueimor

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
