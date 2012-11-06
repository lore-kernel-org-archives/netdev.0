From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v2] af-packet: fix oops when socket is not present
Date: Tue, 06 Nov 2012 04:42:52 -0800
Message-ID: <1352205772.3140.1025.camel@edumazet-glaptop>
References: <1352201642.3140.880.camel@edumazet-glaptop>
	 <1352203810-957-1-git-send-email-eric@regit.org>
	 <20121106122848.GB20904@kroah.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Eric Leblond <eric@regit.org>, netdev <netdev@vger.kernel.org>,
	stable@vger.kernel.org
To: Greg KH <gregkh@linuxfoundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f174.google.com ([209.85.223.174]:33511 "EHLO
	mail-ie0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751152Ab2KFMmy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Nov 2012 07:42:54 -0500
In-Reply-To: <20121106122848.GB20904@kroah.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2012-11-06 at 13:28 +0100, Greg KH wrote:
> On Tue, Nov 06, 2012 at 01:10:10PM +0100, Eric Leblond wrote:
> > Due to a NULL dereference, the following patch is causing oops
> > in normal trafic condition:
> > 
> > commit c0de08d04215031d68fa13af36f347a6cfa252ca
> > Author: Eric Leblond <eric@regit.org>
> > Date:   Thu Aug 16 22:02:58 2012 +0000
> > 
> >     af_packet: don't emit packet on orig fanout group
> > 
> > This buggy patch was a feature fix and has reached most stable
> > branches.
> > 
> > When skb->sk is NULL and when packet fanout is used, there is a
> > crash in match_fanout_group where skb->sk is accessed.
> > This patch fixes the issue by returning false as soon as the
> > socket is NULL: this correspond to the wanted behavior because
> > the kernel as to resend the skb to all the listening socket in
> > this case.
> > 
> > Signed-off-by: Eric Leblond <eric@regit.org>
> > ---
> >  net/core/dev.c |    2 +-
> >  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> <formletter>
> 
> This is not the correct way to submit patches for inclusion in the
> stable kernel tree.  Please read Documentation/stable_kernel_rules.txt
> for how to do this properly.
> 
> </formletter>

Right.

By the way, David Miller prefers to handle stable submissions himself.

So Eric, I guess you could just do nothing for this particular patch,
since your stable@vger.kernel.org addition in the CC will be void.

(Dont add the Cc: in the patch itself, as David will remove it anyway)

Thanks
