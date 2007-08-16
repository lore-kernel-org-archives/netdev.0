From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: [PATCH] [IPv6]: Invalid semicolon after if statement
Date: Thu, 16 Aug 2007 12:25:55 +0300 (EEST)
Message-ID: <Pine.LNX.4.64.0708161201020.22579@kivilampi-30.cs.helsinki.fi>
References: <Pine.LNX.4.64.0708151509520.15670@kivilampi-30.cs.helsinki.fi>
 <20070815.150814.82381935.davem@davemloft.net> <20070815235219.GA17004@redhat.com>
 <20070815.175128.82362004.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="-696243703-2115071024-1187256355=:22579"
Cc: davej@redhat.com, Netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:57747 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755107AbXHPJZ6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Aug 2007 05:25:58 -0400
In-Reply-To: <20070815.175128.82362004.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---696243703-2115071024-1187256355=:22579
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Content-Transfer-Encoding: 8BIT

On Wed, 15 Aug 2007, David Miller wrote:

> From: Dave Jones <davej@redhat.com>
> Date: Wed, 15 Aug 2007 19:52:20 -0400
> 
> > On Wed, Aug 15, 2007 at 03:08:14PM -0700, David Miller wrote:
> >  > From: "Ilpo_Järvinen" <ilpo.jarvinen@helsinki.fi>
> >  > Date: Thu, 16 Aug 2007 00:57:00 +0300 (EEST)
> >  > 
> >  > > A similar fix to netfilter from Eric Dumazet inspired me to
> >  > > look around a bit by using some grep/sed stuff as looking for
> >  > > this kind of bugs seemed easy to automate. This is one of them
> >  > > I found where it looks like this semicolon is not valid.
> >  > > 
> >  > > Signed-off-by: Ilpo Järvinen <ilpo.jarvinen@helsinki.fi>
> >  > 
> >  > Yikes!  Makes you want to audit the entire tree for these
> >  > things :-)))
> >  
> > Indeed.  Here's another one.
> > 
> > Signed-off-by: Dave Jones <davej@redhat.com>
> 
> That got fixed the other day and is the "A similar fix to netfilter
> from Eric Dumazet" Ilpo is reffering to above :)

...heh, when I said "a bit", I meant that it took a very little effort
to check over the whole tree... :-)

...I've already reported all four things one could find from whole tree 
with this cmd (to the relevant parties), so no need for you to redo the 
effort :-) :

$ for i in `find . -name '*.[ch]'`; do echo $i;
	sed -n -e '/^\t*if *[(].*[)] *; *$/ N'
		-e '/^\(\t*\)if *[(].*[)] *; *\n\1\t/ p' $i; done | tee result

...Basically it checks if the next line has more indentation than the
if line. ...Obviously it will work only if the code follows current 
CodingStyle in indentation. I'm currently experimenting with indent 
preprocessing step... ...but I'm not yet sure if I can pull something 
useful out from that too :-)

...Better cmdlines could be invented, e.g. by manually checking every "if 
();" lines once one has first automated separation of them from "if () 
do_smthg();" lines (I haven't learned myself how to easily count/work with 
parenthesis pairs in a cmdline, which seems necessary here)...

-- 
 i.
---696243703-2115071024-1187256355=:22579--
