From: Tom St Denis <tstdenis@elliptictech.com>
Subject: Re: IPsec AH use of ahash
Date: Fri, 18 Jan 2013 21:59:29 -0500 (EST)
Message-ID: <740612402.91931.1358564369618.JavaMail.root@elliptictech.com>
References: <20130119023355.GB10964@lion>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: "Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>,
	David Miller <davem@davemloft.net>,
	steffen klassert <steffen.klassert@secunet.com>,
	herbert@gondor.apana.org.au, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: Michal Kubecek <mkubecek@suse.cz>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20130119023355.GB10964@lion>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

----- Original Message -----
> From: "Michal Kubecek" <mkubecek@suse.cz>
> To: "Tom St Denis" <tstdenis@elliptictech.com>
> Cc: "Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>, "David Miller" <davem@davemloft.net>, "steffen
> klassert" <steffen.klassert@secunet.com>, herbert@gondor.apana.org.au, linux-kernel@vger.kernel.org,
> netdev@vger.kernel.org
> Sent: Friday, 18 January, 2013 9:33:55 PM
> Subject: Re: IPsec AH use of ahash
> 
> On Fri, Jan 18, 2013 at 05:31:45PM -0500, Tom St Denis wrote:
> > My gripe here is suppose I spend professional paid time working on
> > an
> > AH patch to [in my opinion] fix it and then I get
> > ignored/stonewalled/etc because I didn't cross a t or dot an i ...
> ...
> > ... if the likelihood of seeing it in mainline is basically around
> > 0%.
> 
> You received a detailed response from subsystem maintainer who is an
> extremely busy man; that doesn't look like ignoring to me. And as for
> stonewalling, I don't see anything like that either. You were just
> told
> what is wrong and asked to send a fixed version. Once you do that,
> the
> chances of the patch to be accepted are actually very high.

My objection is mostly that the feedback wasn't practical.  [more on that later].

> Yes, kernel rules for submitting and coding style may seem too strict
> at
> the first glance. But there is a good reason for them: linux kernel
> is
> huge and without strict rules it would be one big mess. Part of my
> work
> consists of resolving bugs in various software projects, often these
> are
> projects the sources of I have never seen before. And I wish more (or
> rather as many as possible) had rules similar to the kernel because
> looking for something in code which is badly structured and lacks
> unified coding style, in project without good and descriptive commit
> description, can be a terrible experience.

Having worked with a fair bit of Kernel code I can definitely say there isn't really a unified standard.  About the only thing Kernel developers agree on is they use C and don't comment their code.

> You may call it nitpicking and mock it, you may even feel offended,
> but
> the open source world would be much better place to live in if other
> projects had rules similar to linux kernel (and its networking in
> particular).

Having run several [admittedly much smaller] OSS projects I never turned away contributors with such raw efficiency as what I've seen here.

Sometimes that means you do the bitch work to format things pretty or document API changes or do any number of non-glorious tasks.  I consider it a professional crime that "use the source luke" is not merely a joke but an actual de facto work standard.  
 
> So you consider your time too precious to conform to the kernel
> coding
> style and, on the other hand, the time of subsystem maintainers
> totally
> worthless so that you feel it is their job to tidy up your patches?

Yes.  They're maintainers of code that millions of people use.  If they're too busy to take it on they should take their names off the maintainers list.

You don't get the credit without doing the work.  

> Someone already pointed you to http://patchwork.ozlabs.org/
> Please do take a look there. I just did and found that in last three
> months, about 3500 patches were submitted to this list, i.e. about
> 40 patches per day (including weekends and Christmas). All of these
> need
> to be reviewed by a few maintainers who are also doing their part of
> development. How do they manage to handle it, honestly I don't know.
> And then you come and tell us they should also fix coding style and
> obvious mistakes for everyone who is too lazy to do it themselves.
> Don't you think it would be much more effective if we tried to make
> their work easier rather than put more work on their shoulders?

Maybe the netdev project is too large then?  If they can't maintain it either there isn't enough staff or it's just too large to organize.

The RFC for AH-GMAC is hardly new yet the IPsec AH driver cannot support it.  Furthermore, AEAD is a better match for people [like me] doing hardware acceleration since it means I only have to write one set of drivers.  For instance I do null-cipher ESP through an AEAD driver that implements "ecb(null_cipher),foo" to cut down the code I have to write considerably.  If AH used AEAD I could fully remove my ahash code and have much less to worry about.

So from a user point of view AH is implemented poorly.
 
> Fixing the wrong coding style of existing code would be definitely
> useful but unlike reviewing patches, fixing bugs and developing
> features, it doesn't require detailed knowledge of the code. Using
> highly skilled and experienced developers (which is who subsystem
> maintainers are), that would be a real wasting of resources.

The problem is coding styles are those of the owners.  I don't professionally develop code anything like the Kernel format and I will *never* adopt it.

For instance

if (foo)
   statement;

Is horrible to me.  I've personally seen co-workers cause problems with that format [without the braces].  etc...

So realistically it's not fair to require contributors from all walks of life to adopt some random coding style that isn't even applied to the accepted code.

> > "xcbc.c" for instance was last touched in 2011.  It hasn't been
> > maintained at all apparently.  There were a handful of patches
> > against
> > it ... none which address these "coding standards."
> 
> The fact that there are only few changes doesn't necessarily mean the
> code is unmaintained. It can also mean that it works well and it
> doesn't
> need new features or adjusting to new hardware or protocol versions.
> And
> when the code doesn't change too often, the urge to fix its style is
> rather low. But presence of old badly styled code doesn't justify
> introducing more badly styled code.

That's ironic that you accept "if it works leave it alone" but at the same time maintain that standards exist for a reason and should be adhered to.

More so, I stand by what I said.  As a new contributor if I can't base my original content on existing content as a template for "proper design" then what can I?  How is this not simply "do as I say not as I do?"

Tom
