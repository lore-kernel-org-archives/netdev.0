From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [PATCH 1/3] Fix ERROR: trailing statements should be on next
 line
Date: Mon, 15 May 2017 14:25:40 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6DCFFF5B0B@AcuExch.aculab.com>
References: <20170514175130.18664-1-macfij7@wp.pl>
        <20170515055700-mutt-send-email-mst@kernel.org>
 <20170514212048.24ee7667@t450s.home>
Mime-Version: 1.0
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: Maciek Fijalkowski <macfij7@wp.pl>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        "virtualization@lists.linux-foundation.org"
        <virtualization@lists.linux-foundation.org>
To: 'Alex Williamson' <alex.williamson@redhat.com>,
        "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170514212048.24ee7667@t450s.home>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Alex Williamson
> Sent: 15 May 2017 04:21
...
> > >  	/* Find end of list, sew whole thing into vi->rq.pages. */
> > > -	for (end = page; end->private; end = (struct page *)end->private);
> > > +	for (end = page; end->private; end = (struct page *)end->private)
> > > +		;
> 
> FWIW, I generally like to put a comment on the next line to make it
> abundantly clear that there's nothing in the body of the loop, it's
> also more aesthetically pleasing than a semi-colon on the line by
> itself, ex. /* Nothing */;  It's just too easy to misinterpret the
> loop otherwise, especially without gratuitous white space.  Thanks,

My preference is to put 'continue;' on a line by itself.
Or even move the termination condition into the loop:
	for (end = page;; end = (struct page *)end->private)
		if (!end->private)
			break;

(oh, is that cast needed??)

	David
