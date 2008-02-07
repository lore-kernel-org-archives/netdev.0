From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: + smack-unlabeled-outgoing-ambient-packets.patch added to -mm
 tree
Date: Thu, 7 Feb 2008 12:04:59 -0800
Message-ID: <20080207120459.d4994f44.akpm@linux-foundation.org>
References: <200802071901.m17J1lAY016751@imap1.linux-foundation.org>
	<200802071450.41529.paul.moore@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: casey@schaufler-ca.com, davem@davemloft.net, jmorris@namei.org,
	mingo@elte.hu, sds@tycho.nsa.gov, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: Paul Moore <paul.moore@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:32794 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1762035AbYBGUFl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Feb 2008 15:05:41 -0500
In-Reply-To: <200802071450.41529.paul.moore@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 7 Feb 2008 14:50:41 -0500
Paul Moore <paul.moore@hp.com> wrote:

> On Thursday 07 February 2008 2:02:06 pm akpm@linux-foundation.org wrote:
> > The patch titled
> >      Smack: unlabeled outgoing ambient packets
> > has been added to the -mm tree.  Its filename is
> >      smack-unlabeled-outgoing-ambient-packets.patch
> >
> > Before you just go and hit "reply", please:
> >    a) Consider who else should be cc'ed
> >    b) Prefer to cc a suitable mailing list as well
> >    c) Ideally: find the original patch on the mailing list and do a
> >       reply-to-all to that, adding suitable additional cc's
> 
> I didn't see this patch hit any of the relevant mailing lists (am I missing 
> one somewhere?) so I'm just CC'ing everyone on the To/CC line, minus 
> mm-commits.

It was on linux-kernel and netdev.  I've restored those cc's.

> > ------------------------------------------------------
> > Subject: Smack: unlabeled outgoing ambient packets
> > From: Casey Schaufler <casey@schaufler-ca.com>
> >
> > Smack uses CIPSO labeling, but allows for unlabeled packets by specifying
> > an "ambient" label that is applied to incoming unlabeled packets.  Because
> > the other end of the connection may dislike IP options, and ssh is one know
> > application that behaves thus, it is prudent to respond in kind.  This
> > patch changes the network labeling behavior such that an outgoing packet
> > that would be given a CIPSO label that matches the ambient label is left
> > unlabeled.
> 
> I suppose you are entitled to use NetLabel however you want, so long as it 
> works and doesn't cause problems for other users, but I think you are 
> starting down a rather ugly road with this patch.  In my mind a cleaner 
> solution would be to make of use of the built-in NetLabel/LSM domain mapping 
> functionality to accomplish the same thing.  In other words, there is already 
> a mechanism to do what you want, it's probably a good idea to make use of it 
> instead of recreating it.
> 
> I would suggest that when you set the NetLabel security attributes for a 
> socket you set the domain field to the smack label (see the SELinux code for 
> an example, if you are unsure see selinux_netlbl_sock_setsid() and 
> security_netlbl_sid_to_secattr()).  Once you do that you should continue to 
> set the default NetLabel domain mapping to send CIPSO tagged packets but also 
> create a new NetLabel domain mapping so that the ambient smack label causes 
> packets to be sent "unlabeled".  The only other change you would have to make 
> is to ensure that the NetLabel domain mappings are kept in sync with any 
> ambient label changes (should be easy enough and a rather infrequent 
> operation in practice).
> 
> This also should have the advantage of making your life easier if/when more 
> advanced labeled network controls are added to Smack (see the SELinux changes 
> made in 2.6.25 and our previous discussions).
> 

