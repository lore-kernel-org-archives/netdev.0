From: Jiri Benc <jbenc@suse.cz>
Subject: Re: wireless notes / pre d80211 merge
Date: Wed, 15 Nov 2006 11:05:49 +0100
Message-ID: <20061115110549.2fa3866c@griffin.suse.cz>
References: <1163542797.5399.106.camel@johannes.berg>
	<20061115011123.0eb1eff6@logostar.upir.cz>
	<1163582178.2705.16.camel@ux156>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>, Jeff Garzik <jgarzik@pobox.com>,
	"John W. Linville" <linville@tuxdriver.com>,
	Simon Barber <simon@devicescape.com>,
	Michael Buesch <mbuesch@freenet.de>,
	Ivo van Doorn <ivdoorn@gmail.com>,
	Michael Wu <flamingice@sourmilk.net>,
	Jouni Malinen <jkm@devicescape.com>,
	Daniel Drake <dsd@gentoo.org>, Hong Liu <hong.liu@intel.com>,
	"Luis R. Rodriguez" <mcgrof@gmail.com>,
	James Ketrenos <jketreno@linux.intel.com>,
	David Kimdon <david.kimdon@devicescape.com>,
	Udayan Singh <udayan.singh@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from styx.suse.cz ([82.119.242.94]:41622 "EHLO mail.suse.cz")
	by vger.kernel.org with ESMTP id S966727AbWKOKFy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Nov 2006 05:05:54 -0500
To: Johannes Berg <johannes@sipsolutions.net>
In-Reply-To: <1163582178.2705.16.camel@ux156>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 15 Nov 2006 10:16:18 +0100, Johannes Berg wrote:
> > During the "tx handlers" phase that "copy of skb->cb" is extended quite a
> > lot with other information determined in the tx handlers. The result is a
> > structure that doesn't fit into cb anymore. This is a reason for not using
> > cb to pass tx information to drivers.
> 
> Actually, no, it isn't :) The part that is passed to drivers does fit,
> only the internal stuff doesn't.

Sorry, I was wrong here. I rechecked it now and starting from the last
diet (made by me long time ago, grr) it fits.

> > Please note that master interface has been always considered as a hack. Of
> > course, this perception can be changed if it's desirable.
> 
> Has it? Simon seems to disagree ;)

And I disagree with Simon :-)

> > > The master netdev and wiphy create two orthogonal interfaces to
> > > userspace that nonetheless pretty much represent the same thing---the
> > > underlying hardware.
> > 
> > Yup.
> 
> You just say it like that. Aren't you unhappy about that at all?

I wasn't in times when there was no cfg80211. But now... yes, you're
right. The sysfs ieee80211 class exports just some interesting
informations (we already agreed that add_interface and remove_interface
would go away). Feel free to move it wherever you think is appropriate.

> I don't think the master interface matters here at all. It's just an
> additional netdev that users previously didn't have, but so what?

As I said, my pre-cfg80211 arguments are not valid now.

> Let me qualify to externally visible problems :)

Okay :-)

> I've never wanted to change the top part (so far anyway :) ). It's
> orthogonal. And whether d80211 behaves as an 802.11 protocol is
> something that's visible only in the RX path really, struct packet_type
> and associated things.

I just said it's a confusing term, nothing against the idea.

> > >    it becomes too small, we could put a pointer into skb->cb instead and
> > >    do lifetime management with an skb desctructor.
> > 
> > Not very effective but will work.
> 
> Not really less effective than copying it around all the time as we do
> now and then kmalloc()ing it in some circumstances.

That's true.

Thanks,

 Jiri

-- 
Jiri Benc
SUSE Labs
