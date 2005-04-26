From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: [1/1] connector/CBUS: new messaging subsystem. Revision number
 next.
Date: Tue, 26 Apr 2005 22:13:25 +0400
Message-ID: <20050426221325.20fbba58@zanzibar.2ka.mipt.ru>
References: <20050411125932.GA19538@uganda.factory.vocord.ru>
	<d120d5000504260857cb5f99e@mail.gmail.com>
	<20050426202437.234e7d45@zanzibar.2ka.mipt.ru>
	<d120d50005042610317961a564@mail.gmail.com>
	<20050426220354.5dd619bf@zanzibar.2ka.mipt.ru>
	<20050426221026.108f3698@zanzibar.2ka.mipt.ru>
Reply-To: johnpol@2ka.mipt.ru
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: dtor_core@ameritech.net, dmitry.torokhov@gmail.com,
	netdev@oss.sgi.com, Greg KH <greg@kroah.com>,
	Jamal Hadi Salim <hadi@cyberus.ca>,
	Kay Sievers <kay.sievers@vrfy.org>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	James Morris <jmorris@redhat.com>,
	Guillaume Thouvenin <guillaume.thouvenin@bull.net>,
	linux-kernel@vger.kernel.org, Andrew Morton <akpm@osdl.org>,
	Thomas Graf <tgraf@suug.ch>, Jay Lan <jlan@engr.sgi.com>
Return-path: <linux-kernel-owner+glk-linux-kernel=40m.gmane.org-S261505AbVDZSOO@vger.kernel.org>
To: johnpol@2ka.mipt.ru
In-Reply-To: <20050426221026.108f3698@zanzibar.2ka.mipt.ru>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 26 Apr 2005 22:10:26 +0400
Evgeniy Polyakov <johnpol@2ka.mipt.ru> wrote:

> > > > There may not be the same work with different data.
> > > > 
> > > 
> > > Ugh, that really blows. Now every user of a particular message type
> > > has to coordinate efforts with other users of the same message type...
> > > 
> > > Imability to "fire and forget" undermines usefulness of whole
> > > connector. How will you for example implement hotplug notification
> > > over connector? Have kobject_hotplug wait and block other instances?
> > > But wait on what?
> > 
> > This is a simple load balancing schema.
> > Netlink messages may be dropped in socket queue when 
> > they are bing delivered to userspace - this is the same - 
> > if work queue can not be scheduled, message will be dropped,
> > but in this case userspace also can not be scheduled
> > and message will be dropped.
> 
> Btw, I belive we see that it is reverse direction...
> So we have reverse load balancing schema here - 
> exactly like userspace socket queueing.
> We basically can not sleep here - it will be DOS.

And yet another btw - netlink is unreliable protocol,
that is why there are seq and ack fields in connector's header - 
connector's users must implement some check on top of
raw connector messages - it could be returned message with
timeout resending and so on.
I wrote it several times and it is in connector's documentation.

	Evgeniy Polyakov

Only failure makes us experts. -- Theo de Raadt
