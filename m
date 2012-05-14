From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH] netfilter: xt_HMARK: endian bugs
Date: Mon, 14 May 2012 21:02:11 +0200
Message-ID: <20120514190211.GC14897@1984>
References: <1337002943-16374-1-git-send-email-hans.schillstrom@ericsson.com>
 <201205141809.18174.hans.schillstrom@ericsson.com>
 <1337012674.8512.589.camel@edumazet-glaptop>
 <201205141951.36692.hans.schillstrom@ericsson.com>
 <alpine.DEB.2.00.1205142032570.28548@blackhole.kfki.hu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Hans Schillstrom <hans.schillstrom@ericsson.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Jan Engelhardt <jengelh@inai.de>,
	"kaber@trash.net" <kaber@trash.net>,
	"jengelh@medozas.de" <jengelh@medozas.de>,
	"netfilter-devel@vger.kernel.org" <netfilter-devel@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"dan.carpenter@oracle.com" <dan.carpenter@oracle.com>,
	"hans@schillstrom.com" <hans@schillstrom.com>
To: Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.00.1205142032570.28548@blackhole.kfki.hu>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, May 14, 2012 at 08:35:26PM +0200, Jozsef Kadlecsik wrote:
> On Mon, 14 May 2012, Hans Schillstrom wrote:
> 
> > On Monday 14 May 2012 18:24:34 Eric Dumazet wrote:
> > > On Mon, 2012-05-14 at 18:09 +0200, Hans Schillstrom wrote:
> > > 
> > > > This context can contain both le & be machines,
> > > > so at least in hmark it make sense
> > > 
> > > Before jhash() and its shuffle ? What do you mean ?
> > 
> > I want that a Big endian machine should produce the same
> > hash value independent of flow direction as a Little endian.
> > 
> > OK, I missed ntohl() before calling jhash_3words()
> > 
> > Correct me if I'm wrong here (have no big endian machine available for test)
> > jhash_3words() and __jhash_final() seems to be "endian" safe.
> 
> No, but as Eric wrote: what is the point in forcing the same hash value 
> for the same input on big endian and little endian machines? Are you going 
> to transfer the hash value between machines?

IIRC, Hans wants that, in case you have a cluster composed of system
with different endianess, the hash mark calculated will be the same
in both systems. To ensure that the distribution is consistent with
independency of the endianess.
