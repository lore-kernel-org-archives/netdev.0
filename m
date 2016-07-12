From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v7 02/11] net: add ndo to setup/query xdp prog in
 adapter rx
Date: Mon, 11 Jul 2016 23:45:53 -0700 (PDT)
Message-ID: <20160711.234553.1347801109908530356.davem@davemloft.net>
References: <1468272598-21390-3-git-send-email-bblanco@plumgrid.com>
	<20160711.231224.1254700854465723599.davem@davemloft.net>
	<20160712063457.GB20499@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jhs@mojatatu.com,
	saeedm@dev.mellanox.co.il, kafai@fb.com, brouer@redhat.com,
	as754m@att.com, alexei.starovoitov@gmail.com, gerlitz.or@gmail.com,
	john.fastabend@gmail.com, hannes@stressinduktion.org,
	tgraf@suug.ch, tom@herbertland.com, daniel@iogearbox.net
To: bblanco@plumgrid.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:37458 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750847AbcGLGp7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Jul 2016 02:45:59 -0400
In-Reply-To: <20160712063457.GB20499@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Brenden Blanco <bblanco@plumgrid.com>
Date: Mon, 11 Jul 2016 23:35:00 -0700

> On Mon, Jul 11, 2016 at 11:12:24PM -0700, David Miller wrote:
>> From: Brenden Blanco <bblanco@plumgrid.com>
>> Date: Mon, 11 Jul 2016 14:29:49 -0700
>> 
>> > +	if (fd >= 0) {
>> > +		prog = bpf_prog_get_type(fd, BPF_PROG_TYPE_XDP);
>> > +		if (IS_ERR(prog))
>> > +			return PTR_ERR(prog);
>> > +	}
>> > +
>> > +	xdp.command = XDP_SETUP_PROG;
>> > +	xdp.prog = prog;
>> > +	err = ops->ndo_xdp(dev, &xdp);
>> > +	if (err < 0 && prog)
>> > +		bpf_prog_put(prog);
>> 
>> I don't understand the reference counting on 'prog' here.
>> 
>> The enumeration documentation states that no matter what, the passed
>> in prog doesn't need to be mangaged by the ->ndo_xdp() method.
>> 
>> Therefore, if that is true, we must always put the 'prog' here if it
>> is non-NULL.  Regardless of the 'err' value.
>> 
> The documentation is unclear then. What I _meant_ to say is that the callee
> is not responsible for putting the program on error, but on success it
> takes ownership of the reference. In context of that, does the code make
> sense? Is there a more conventional way of handling this?

Then please document it more clearly, thanks.
