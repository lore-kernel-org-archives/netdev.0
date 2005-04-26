From: Dmitry Torokhov <dmitry.torokhov@gmail.com>
Subject: Re: [1/1] connector/CBUS: new messaging subsystem. Revision number next.
Date: Tue, 26 Apr 2005 14:06:36 -0500
Message-ID: <d120d50005042612069b84ef@mail.gmail.com>
References: <20050411125932.GA19538@uganda.factory.vocord.ru>
	 <d120d5000504260857cb5f99e@mail.gmail.com>
	 <20050426202437.234e7d45@zanzibar.2ka.mipt.ru>
	 <20050426203023.378e4831@zanzibar.2ka.mipt.ru>
	 <d120d50005042610342368cd72@mail.gmail.com>
	 <20050426220713.7915e036@zanzibar.2ka.mipt.ru>
	 <d120d50005042611203ce29dd8@mail.gmail.com>
	 <20050426223126.37b7aea1@zanzibar.2ka.mipt.ru>
	 <d120d50005042611426ec326e9@mail.gmail.com>
	 <20050426224833.3b6a0792@zanzibar.2ka.mipt.ru>
Reply-To: dtor_core@ameritech.net
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: netdev@oss.sgi.com, Greg KH <greg@kroah.com>,
	Jamal Hadi Salim <hadi@cyberus.ca>,
	Kay Sievers <kay.sievers@vrfy.org>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	James Morris <jmorris@redhat.com>,
	Guillaume Thouvenin <guillaume.thouvenin@bull.net>,
	linux-kernel@vger.kernel.org, Andrew Morton <akpm@osdl.org>,
	Thomas Graf <tgraf@suug.ch>, Jay Lan <jlan@engr.sgi.com>
Return-path: <linux-kernel-owner+glk-linux-kernel=40m.gmane.org-S261739AbVDZTGn@vger.kernel.org>
To: johnpol@2ka.mipt.ru
In-Reply-To: <20050426224833.3b6a0792@zanzibar.2ka.mipt.ru>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 4/26/05, Evgeniy Polyakov <johnpol@2ka.mipt.ru> wrote:
> On Tue, 26 Apr 2005 13:42:10 -0500
> Dmitry Torokhov <dmitry.torokhov@gmail.com> wrote:
> > Yes, that woudl work, although I would urge you to implement a message
> > queue for callbacks (probably limit it to 1000 messages or so) to
> > allow bursting.
> 
> It already exist, btw, but not exactly in that way -
> we have skb queue, which can not be filled from userspace
> if pressure is so strong so work queue can not be scheduled.
> It is of course different and is influenced by other things
> but it handles bursts quite well - it was tested on both
> SMP and UP machines with continuous flows of forks with
> shape addon of new running tasks [both fith fork bomb and not],
> so I think it can be called real bursty test.
> 

Ok, hear me out and tell me where I am wrong:

By default a socket can receive at least 128 skbs with 258-byte
payload, correct? That means that user of cn_netlink_send, if started
"fresh", 128 average - size connector messages. If sender does not
want to wait for anything (unlike your fork tests that do schedule)
that means that 127 of those 128 messages will be dropped, although
netlink would deliver them in time just fine.

What am I missing?

-- 
Dmitry
