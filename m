From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: freeze with interface rename & SIOCGIFNAME
Date: Tue, 25 Jun 2013 09:57:27 -0700
Message-ID: <1372179447.3301.105.camel@edumazet-glaptop>
References: <51C9BB9C.4050405@freebox.fr>
	 <1372176951.3301.103.camel@edumazet-glaptop> <51C9C4FF.1020706@freebox.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	Cong Wang <amwang@redhat.com>
To: Nicolas Schichan <nschichan@freebox.fr>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f44.google.com ([74.125.83.44]:50222 "EHLO
	mail-ee0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751261Ab3FYQ5S (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Jun 2013 12:57:18 -0400
Received: by mail-ee0-f44.google.com with SMTP id c13so6798656eek.17
        for <netdev@vger.kernel.org>; Tue, 25 Jun 2013 09:57:17 -0700 (PDT)
In-Reply-To: <51C9C4FF.1020706@freebox.fr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2013-06-25 at 18:27 +0200, Nicolas Schichan wrote:
> On 06/25/2013 06:15 PM, Eric Dumazet wrote:
> > Nice catch !
> >
> > Please add a helper so that we can use it as well from
> > sock_getbindtodevice(), and submit an official patch ?
> 
> Sure, I'll do that.
> 
> > int netdev_get_name(char *name, int ifindex)
> > {
> > 	struct net_device *dev;
> > 	unsigned int seq;
> >
> > retry:
> >          seq = read_seqcount_begin(&devnet_rename_seq);
> 
> raw_seqcount_begin is required here here. read_seqcount_begin will spin 
> forever as the s->sequence & 1 check will always be true in 
> __read_seqcount_begin(). This will incur some unneed work if a rename is in 
> progress, but that's better than locking the system up.

I am not sure it's needed, because the writer holds a spinlock and is
not allowed to sleep or being preempted.

If it's needed, there is a bug somewhere else...
