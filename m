From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: Fwd: r8169 driver supporting the 8167 dev ID
Date: Sat, 14 Jul 2007 21:40:37 +0200
Message-ID: <20070714194037.GA12223@electric-eye.fr.zoreil.com>
References: <71421f560707091922y60dec801w836e1e4e88c36de2@mail.gmail.com> <71421f560707091923y64565c84wecb1229c219642c4@mail.gmail.com> <20070710212513.GB3436@electric-eye.fr.zoreil.com> <71421f560707101724x42fb6c8ye82bd08a9c7bca5@mail.gmail.com> <71421f560707110605x1bf79d7dj73ce7edd590b58ce@mail.gmail.com> <20070711192850.GA4904@electric-eye.fr.zoreil.com> <71421f560707141002w592a18cfqf8a9ba34745e75c6@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Jonathan Larsen <agentc0re@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from electric-eye.fr.zoreil.com ([213.41.134.224]:54027 "EHLO
	fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1760895AbXGNTlG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 14 Jul 2007 15:41:06 -0400
Content-Disposition: inline
In-Reply-To: <71421f560707141002w592a18cfqf8a9ba34745e75c6@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Jonathan Larsen <agentc0re@gmail.com> :
> >You should read the tutorial until you find the 'Using git for 
> >collaboration'
> >part. You missed a:
> >
> >git clone 
> >git://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux-2.6.git
> 
> Alright sweet, i got somewhere :).  i was able to pull that down, do
> my previous steps and git commit  and then the git format patch and it
> pulled down a whole bunch of .patch files.
> i've seen them before.  they also exist here.
> http://www.fr.zoreil.com/people/francois/backport/r8169/20070604-00/broken-out/
> Im confused as what i would need to do with these files.  would i run
> them as a patch against the r8169.c file?  ie: patch p1 < 'one of the
> patch files.patch'?
>
> the other thing i've ran into trouble with is getting the git kernel
> version for 2.6.16.52.  i've searched for a 2.6.16.52.git file and
> haven't seen anything and also tried using get pull v2.6.16.52 and i
> get a fatal error.  unable to chdir or not a git archive.  i've also
> tried without the .52 and get the same thing.

In the clone directory, try:
$ git remote add 2.6.16.y git://git.kernel.org/pub/scm/linux/kernel/git/stable/linux-2.6.16.y.git
$ git remote fetch 2.6.16.y
$ git checkout -f 2.6.16.52-r8169 v2.6.16.52

You are strongly urged to RTFM to figure what the commands above (and
below) do.

>From here you apply each of the patches which are in the current 'master'
branch but not in the 2.6.16.y branch at v2.6.16.52. You can play with
'git merge-base' and 'git format-patch' to see the flow of r8169 patches
in both branches but there are surely more elaborate tools/commands.

Use 'git am' to apply the patches. The ordering should guide you.
If a patch apply, go on to the compilation step. If the patch does not
apply, you can force it by hand, fix the rejects and add the missing
files until it compiles. 'git {add/update-index}' the added/updated
files and issue 'git am --resolved'. Save the commit somewhere, it
could be useful. If the patch applied but did not compile, you can
'git reset --hard HEAD^', patch -p1, git {add/update-index} and git
commit by hand.

Repeat until illumination.

[...]
> i just want to make sure it was understood that i want try and make
> the r8169 driver that supported my card in 2.6.22 and back port it to
> work in 2.6.16.52.

If 2.6.22 works for you, fine. You could be interested by the post 2.6.22
r8169 patches though.

If you have more questions related to git which are not answered in the man
pages, you should ask them in the git mailing list (git@vger.kernel.org).

-- 
Ueimor
