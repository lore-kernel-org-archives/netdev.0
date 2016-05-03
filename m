From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [Question] Should `CAP_NET_ADMIN` be needed when opening `/dev/ppp`?
Date: Tue, 03 May 2016 13:23:34 +0200
Message-ID: <1462274614.1336993.596603129.675ECADD@webmail.messagingengine.com>
References: <2BEB0C68-EBC6-4A8F-A751-DE8F4A2C9D2C@gmail.com>
 <20160503101240.GA1304@alphalink.fr>
 <CAFLxGvyKMbJyfk5oiRZ6-67yHH=f+3mkY=gd3AsZC1G_o0Xhxg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Wang Shanker <shankerwangmiao@gmail.com>, netdev@vger.kernel.org,
	LKML <linux-kernel@vger.kernel.org>
To: Richard Weinberger <richard.weinberger@gmail.com>,
	Guillaume Nault <g.nault@alphalink.fr>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAFLxGvyKMbJyfk5oiRZ6-67yHH=f+3mkY=gd3AsZC1G_o0Xhxg@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, May 3, 2016, at 12:35, Richard Weinberger wrote:
> On Tue, May 3, 2016 at 12:12 PM, Guillaume Nault <g.nault@alphalink.fr>
> wrote:
> > On Sun, May 01, 2016 at 09:38:57PM +0800, Wang Shanker wrote:
> >> static int ppp_open(struct inode *inode, struct file *file)
> >> {
> >>       /*
> >>        * This could (should?) be enforced by the permissions on /dev/ppp.
> >>        */
> >>       if (!capable(CAP_NET_ADMIN))
> >>               return -EPERM;
> >>       return 0;
> >> }
> >> ```
> >>
> >> I wonder why CAP_NET_ADMIN is needed here, rather than leaving it to the
> >> permission of the device node. If there is no need, I suggest that the
> >> CAP_NET_ADMIN check be removed.
> >>
> > If this test was removed here, then it'd have to be added again in the
> > PPPIOCNEWUNIT ioctl, at the very least, because creating a netdevice
> > should require CAP_NET_ADMIN. Therefore that wouldn't help for your
> > case.
> > I don't know why the test was placed in ppp_open() in the first place,
> > but changing it now would have side effects on user space. So I'd
> > rather leave the code as is.
> 
> I think the question is whether we really require having CAP_NET_ADMIN
> in the initial namespace and not just in the current one.
> Is ppp not network namespace aware?

I agree, ns_capable(net->user_ns, CAP_NET_ADMIN), would probably make
more sense.

Bye,
Hannes
