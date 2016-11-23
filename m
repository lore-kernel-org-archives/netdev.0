From: Al Viro <viro@ZenIV.linux.org.uk>
Subject: Re: sendfile from 9p fs into af_alg
Date: Wed, 23 Nov 2016 06:16:28 +0000
Message-ID: <20161123061628.GN1555@ZenIV.linux.org.uk>
References: <20161123035827.GA43786@ast-mbp.thefacebook.com>
 <20161123044625.GL1555@ZenIV.linux.org.uk>
 <20161123045558.GA43893@ast-mbp.thefacebook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
        Daniel Borkmann <daniel@iogearbox.net>,
        Martin KaFai Lau <kafai@fb.com>
To: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20161123045558.GA43893@ast-mbp.thefacebook.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Nov 22, 2016 at 08:55:59PM -0800, Alexei Starovoitov wrote:
> On Wed, Nov 23, 2016 at 04:46:26AM +0000, Al Viro wrote:
> > On Tue, Nov 22, 2016 at 07:58:29PM -0800, Alexei Starovoitov wrote:
> > > Hi Al,
> > > 
> > > it seems the following commit 523ac9afc73a ("switch default_file_splice_read() to use of pipe-backed iov_iter")
> > > breaks sendfile from 9p fs into af_alg socket.
> > > sendfile into af_alg is used by iproute2/tc.
> > > I'm not sure whether it's 9p or crypto or vfs problem, but happy to test any patches.
> > 
> > Could you try -rc6 (or anything that contains 680bb946a1ae04, for that
> > matter)?
> 
> already tested with that patch in the latest net-next. Still broken :(

Joy...  Which transport are you using there?  The interesting part is
whether it's zerocopy or non-zerocopy path in p9_client_read()...
