From: Peter Zijlstra <a.p.zijlstra@chello.nl>
Subject: Re: [PATCH 03/10] mm: Add support for a filesystem to control swap
 files
Date: Mon, 12 Sep 2011 11:56:09 +0200
Message-ID: <1315821369.26517.21.camel@twins>
References: <1315566054-17209-1-git-send-email-mgorman@suse.de>
	 <1315566054-17209-4-git-send-email-mgorman@suse.de>
	 <20110909130007.GA11810@infradead.org> <20110909131550.GV14369@suse.de>
	 <20110909133611.GB8155@infradead.org> <1315818285.26517.18.camel@twins>
	 <20110912093058.GA3207@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Cc: Christoph Hellwig <hch@infradead.org>, Linux-MM <linux-mm@kvack.org>,
 Linux-Netdev <netdev@vger.kernel.org>, Linux-NFS
 <linux-nfs@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>, Andrew
 Morton <akpm@linux-foundation.org>,  David Miller <davem@davemloft.net>,
 Trond Myklebust <Trond.Myklebust@netapp.com>, Neil Brown <neilb@suse.de>
To: Mel Gorman <mgorman@suse.de>
Return-path: <owner-linux-mm@kvack.org>
In-Reply-To: <20110912093058.GA3207@suse.de>
Sender: owner-linux-mm@kvack.org
List-Id: netdev.vger.kernel.org

On Mon, 2011-09-12 at 10:34 +0100, Mel Gorman wrote:
> On Mon, Sep 12, 2011 at 11:04:45AM +0200, Peter Zijlstra wrote:
> > On Fri, 2011-09-09 at 09:36 -0400, Christoph Hellwig wrote:
> > > The equivalent of ->direct_IO should be used for both reads and write=
s.
> >=20
> > So the difference between DIO and swapIO is that swapIO needs the block
> > map pinned in memory.. So at the very least you'll need those
> > swap_{activate,deactivate} aops. The read/write-page thingies could
> > indeed be shared with DIO.
> >=20
>=20
> I'm travelling at the moment so it'll be later in the week when I investi=
gate
> properly but I agree swap_[de|a]ctivate are still necessary. NFS does not
> need to pin a block map but it's still necessary for calling xs_set_memal=
loc.

Right.. but I think the hope was that we could replace the current swap
bmap hackery with this and simplify the normal swap bits. But yeah,
networked filesystems don't really bother with block maps on the client
side ;-)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
