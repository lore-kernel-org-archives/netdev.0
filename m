From: Kaigai Kohei <kaigai@ak.jp.nec.com>
Subject: Re: [Lse-tech] Re: A common layer for Accounting packages
Date: Tue, 01 Mar 2005 22:38:25 +0900
Message-ID: <42247051.7070303@ak.jp.nec.com>
References: <4221E548.4000008@ak.jp.nec.com>	 <20050227140355.GA23055@logos.cnet> <42227AEA.6050002@ak.jp.nec.com>	 <1109575236.8549.14.camel@frecb000711.frec.bull.fr>	 <20050227233943.6cb89226.akpm@osdl.org>	 <1109592658.2188.924.camel@jzny.localdomain>	 <20050228132051.GO31837@postel.suug.ch>	 <1109598010.2188.994.camel@jzny.localdomain>	 <20050228135307.GP31837@postel.suug.ch>	 <1109599803.2188.1014.camel@jzny.localdomain>	 <20050228142551.GQ31837@postel.suug.ch>	 <1109604693.1072.8.camel@jzny.localdomain>	 <20050228191759.6f7b656e@zanzibar.2ka.mipt.ru> <1109665299.8594.55.camel@frecb000711.frec.bull.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Cc: Evgeniy Polyakov <johnpol@2ka.mipt.ru>, hadi@cyberus.ca,
        Thomas Graf <tgraf@suug.ch>, Andrew Morton <akpm@osdl.org>,
        marcelo.tosatti@cyclades.com, "David S. Miller" <davem@redhat.com>,
        jlan@sgi.com, LSE-Tech <lse-tech@lists.sourceforge.net>,
        lkml <linux-kernel@vger.kernel.org>, netdev@oss.sgi.com,
        elsa-devel <elsa-devel@lists.sourceforge.net>
To: Guillaume Thouvenin <guillaume.thouvenin@bull.net>
In-Reply-To: <1109665299.8594.55.camel@frecb000711.frec.bull.fr>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hello,

> I tested without user space listeners and the cost is negligible. I will
> test with a user space listeners and see the results. I'm going to run
> the test this week after improving the mechanism that switch on/off the
> sending of the message.

I'm also trying to mesure the process-creation/destruction performance on following three environment.
Archtechture: i686 / Distribution: Fedora Core 3
* Kernel Preemption is DISABLE
* SMP kernel but UP-machine / Not Hyper Threading
[1] 2.6.11-rc4-mm1 normal
[2] 2.6.11-rc4-mm1 with PAGG based Process Accounting Module
[3] 2.6.11-rc4-mm1 with fork-connector notification (it's enabled)

When 367th-fork() was called after fork-connector notification, kernel was locked up.
(User-Space-Listener has been also run until 366th-fork() notification was received)

Does this number have any sort of means ?
In my second trial, kernel was also locked up after 366th-fork() notification.
Currently, I don't know its causition. Is there a person encounted it?

# I wanted to say "[2] is faster than [3]" when process-grouping is enable, but the plan came off.  :(

Thanks.
-- 
Linux Promotion Center, NEC
KaiGai Kohei <kaigai@ak.jp.nec.com>
