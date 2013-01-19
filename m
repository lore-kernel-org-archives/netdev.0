From: Tom St Denis <tstdenis@elliptictech.com>
Subject: Re: IPsec AH use of ahash
Date: Sat, 19 Jan 2013 05:30:57 -0500 (EST)
Message-ID: <1325444527.92017.1358591457919.JavaMail.root@elliptictech.com>
References: <1358567995.3464.372.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: "Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>,
	David Miller <davem@davemloft.net>,
	steffen klassert <steffen.klassert@secunet.com>,
	herbert@gondor.apana.org.au, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, Michal Kubecek <mkubecek@suse.cz>
To: Eric Dumazet <erdnetdev@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1358567995.3464.372.camel@edumazet-glaptop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



----- Original Message -----
> From: "Eric Dumazet" <erdnetdev@gmail.com>
> To: "Michal Kubecek" <mkubecek@suse.cz>
> Cc: "Tom St Denis" <tstdenis@elliptictech.com>, "Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>, "David
> Miller" <davem@davemloft.net>, "steffen klassert" <steffen.klassert@secunet.com>, herbert@gondor.apana.org.au,
> linux-kernel@vger.kernel.org, netdev@vger.kernel.org
> Sent: Friday, 18 January, 2013 10:59:55 PM
> Subject: Re: IPsec AH use of ahash
> 
> On Sat, 2013-01-19 at 03:33 +0100, Michal Kubecek wrote:
> 
> > Someone already pointed you to http://patchwork.ozlabs.org/
> > Please do take a look there. I just did and found that in last
> > three
> > months, about 3500 patches were submitted to this list, i.e. about
> > 40 patches per day (including weekends and Christmas). All of these
> > need
> > to be reviewed by a few maintainers who are also doing their part
> > of
> > development. How do they manage to handle it, honestly I don't
> > know.
> 
> I want to make here a huge thanks to David Miller, and of course
> to all contributors.
> 
> I truly believe we did very well, and I really hope new contributors
> will come and continue the impressive work.
> 
> Sure, sometime we can react not as good as we could do if we were
> not overloaded. (I mean, 6 hours listening Lance Amstrong confession.
> You really cant avoid such a scoop !)

As someone who maintained (and I mean that in all senses not just applied patches) OSS projects while working full time and still trying to have a life I get it.  That said I never turned away patches solely on "style" issues.  At the same time you should look at the size and scope of the patches I'm talking about.  It took me all of less than an hour to develop and less than a couple of hours to give it a run to see if it works correctly [talking about the CMAC patch].

This *should* be a no-brainer to apply.

> I understand that for a new contributor, it might be difficult to
> catch up with various rules, but reading netdev archives should be
> enough to understand how it really works. Its not like the process
> was a secret.
> 
> Tom, even a maintainer can make errors, thats not a big deal, as long
> as things can go forward.
> 
> If you felt you had 0% chance to get your patch being accepted, then
> you had a wrong feeling.

My problem is the lack of ownership of the task from the maintainers.  For instance, I was surprised that CryptoAPI didn't support CMAC already given that it's a NIST standard (more than XCBC is).  The maintainers of CryptoAPI deemed fit to add all sorts of non-standard nonsense like Serpent and Twofish and heck even VMAC but not CMAC?  Who's goals are they serving here?

Then I get time from my employer to add CMAC to the kernel so I base it off the closest match, XCBC.  I modify one function, add it's name to a table and fire off a patch.  What happens?  It gets ignored.  Then I resubmit it with he maintainers in the cc: and I get an ack [this is during 3.7-rc...].  The 3.8 window opens up and .... the code is nowhere to be found.  I ask again, and then I get "it doesn't match our coding standards, please try again."

> If the patch makes sense and you agree to address reviewers feedback,
> it
> definitely can be accepted. If you think you don't have time to do
> that,
> then maybe the patch is not really needed.

The typical OSS cop-out.  It's not about what *you* deem important.  It's what the customer/users do.  And in this case I went the extra yard and submitted working code.  I shouldn't have to resubmit working code because of "style" issues.  The maintainers should be damn grateful that I submitted [working] code at all and they can spend the time to integrate it into mainline.

The fact is right now *I* have the ability to perform CMAC in the kernel.  Nobody else does.  So aside from annoying some of my users by having them patch their kernel with a patch I provide them we're not missing out on functionality.  It's the rest of the Kernel users (whom I don't interact with) who are now missing functionality.

This gets back to the AH AEAD case.  Suppose I take the existing ah4.c and just re-write the ahash statements to use aead and touch nothing else... if the existing ah4.c doesn't meet coding standards will that patch get tossed out too?  Do you see perhaps how impractical that standard is?

For those of us who do Kernel development during business hours it's hard to justify the work when the path to mainline is convoluted and landmined.  

Tom
