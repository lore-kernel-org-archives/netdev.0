From: Brenden Blanco <bblanco@plumgrid.com>
Subject: Re: [PATCH v8 06/11] net/mlx4_en: add page recycle to prepare rx
 ring for tx support
Date: Tue, 12 Jul 2016 17:54:27 -0700
Message-ID: <20160713005424.GB13865@gmail.com>
References: <1468309894-26258-1-git-send-email-bblanco@plumgrid.com>
 <1468309894-26258-7-git-send-email-bblanco@plumgrid.com>
 <20160712.141832.634796503160544753.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, jhs@mojatatu.com,
	saeedm@dev.mellanox.co.il, kafai@fb.com, brouer@redhat.com,
	as754m@att.com, alexei.starovoitov@gmail.com, gerlitz.or@gmail.com,
	john.fastabend@gmail.com, hannes@stressinduktion.org,
	tgraf@suug.ch, tom@herbertland.com, daniel@iogearbox.net
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f181.google.com ([209.85.192.181]:35299 "EHLO
	mail-pf0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750816AbcGMAyw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Jul 2016 20:54:52 -0400
Received: by mail-pf0-f181.google.com with SMTP id c2so12536577pfa.2
        for <netdev@vger.kernel.org>; Tue, 12 Jul 2016 17:54:32 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20160712.141832.634796503160544753.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jul 12, 2016 at 02:18:32PM -0700, David Miller wrote:
> From: Brenden Blanco <bblanco@plumgrid.com>
> Date: Tue, 12 Jul 2016 00:51:29 -0700
> 
> > +	mlx4_en_free_resources(priv);
> > +
> >  	old_prog = xchg(&priv->prog, prog);
> >  	if (old_prog)
> >  		bpf_prog_put(old_prog);
> >  
> > -	return 0;
> > +	err = mlx4_en_alloc_resources(priv);
> > +	if (err) {
> > +		en_err(priv, "Failed reallocating port resources\n");
> > +		goto out;
> > +	}
> > +	if (port_up) {
> > +		err = mlx4_en_start_port(dev);
> > +		if (err)
> > +			en_err(priv, "Failed starting port\n");
> 
> A failed configuration operation should _NEVER_ leave the interface in
> an inoperative state like these error paths do.
> 
> You must instead preallocate the necessary resources, and only change
> the chip's configuration and commit to the new settings once you have
> successfully allocated those resources.
I'll see what I can do here.
